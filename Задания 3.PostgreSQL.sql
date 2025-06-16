/*Задание 1. Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
Пронумеруйте все платежи от 1 до N по дате
Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате
Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна быть сперва по дате платежа, а затем по сумме платежа от наименьшей к большей
Пронумеруйте платежи для каждого покупателя по стоимости платежа от наибольших к меньшим так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.*/
select *, row_number() over (partition by payment_date::date ) as number_date_p_1,  
row_number() over (partition by p.customer_id order by p.payment_date) as number_customer_p_2,
SUM(p.amount) over (partition by customer_id order by p.payment_date, p.amount ) as "Накопительная сумма_3",
rank() over (partition by customer_id order by p.amount) as "number_customer_p_4"
from payment p order by customer_id 
/*Задание 2. С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.*/
select *, lag(p.amount,1,0.0) over (partition by customer_id) as pl from payment p 
--Задание 3. С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.
select *, lead(p.amount,1,0.0) over (partition by customer_id)  - p.amount as pl from payment p
--Задание 4. С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.
select * from (select *, row_number() over (partition by customer_id order by p.payment_date desc)  as ran from payment p ) t where ran = 1
/*Задание 5. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.*/
select *, date(payment_date), SUM(p.amount) over (partition by staff_id order by payment_date::date) from payment p where p.payment_date  >= '2005-08-01' AND p.payment_date  < '2005-09-01'
/*Задание 6. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.*/
select * from (select  *, row_number() over (partition by p.staff_id order by p.payment_date ) as rn from payment p where DATE(payment_date) = '2005-08-20') t where rn % 100 = 0
/*Задание 7. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
	покупатель, арендовавший наибольшее количество фильмов;
	покупатель, арендовавший фильмов на самую большую сумму;
	покупатель, который последним арендовал фильм.*/
select * from (
select country_id, customer_id, max(count_r) over (partition by country_id) as max_c, 
	max(sum_r) over (partition by country_id) as sum_c, 
	max(t.rental_date ) over (partition by country_id) as laf_p,
	row_number() over (partition by country_id) as rn from (
		select c.country, c.country_id , c3.customer_id, r.rental_id, r.rental_date, p.amount,
			COUNT(r.rental_id) over (partition by c.country_id, c3.customer_id) as count_r,
			SUM(p.amount) over (partition by c.country_id, c3.customer_id) as sum_r
			from country c 
				join city c2 on c2.country_id = c.country_id
				join address a on a.city_id = c2.city_id
				join customer c3 on c3.address_id = a.address_id
				join rental r on r.customer_id = c3.customer_id
				join payment p  on p.rental_id = r.rental_id ) t order by country_id ) t2
				where rn = 1