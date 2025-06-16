-- Задание 1. Выведите для каждого покупателя его адрес, город и страну проживания.
select cl."name", cl.address, cl.city, cl.country from customer_list cl
-- Задание 2. С помощью SQL-запроса посчитайте для каждого магазина количество его покупателей.
select s.store_id, count(*) as customer_count from store s join customer c on s.store_id = c.store_id group by s.store_id 
	/*Доработайте запрос и выведите только те магазины, у которых количество покупателей больше 300. Для решения используйте фильтрацию по сгруппированным строкам с 		функцией агрегации. */
select s.store_id, count(*) as customer_count from store s join customer c on s.store_id = c.store_id group by s.store_id having count (*) > 300
--	Доработайте запрос, добавив в него информацию о городе магазина, фамилии и имени продавца, который работает в нём
select s.store_id, cy.city, COUNT(*) as customer_count, (st.first_name::text || ' '::text) || st.last_name::text AS name from store s 
	join customer c on s.store_id = c.store_id
	join staff st on s.store_id = st.store_id
	left join address a on s.address_id = a.address_id 
	left join city cy on a.city_id = cy.city_id 
	group by s.store_id, cy.city, st.first_name, st.last_name
	having  count(*) > 300
-- Задание 3. Выведите топ-5 покупателей, которые взяли в аренду за всё время наибольшее количество фильмов.
select c.customer_id, count(*) as count_c from rental r join customer c on r.customer_id = c.customer_id 
group by c.customer_id order by count_c  desc limit 5
/*Задание 4. Посчитайте для каждого покупателя 4 аналитических показателя:
количество взятых в аренду фильмов;
общую стоимость платежей за аренду всех фильмов (значение округлите до целого числа);
минимальное значение платежа за аренду фильма;
максимальное значение платежа за аренду фильма.*/
select c.customer_id, count(c.customer_id) as "count_rental_film" , 
round(SUM(p.amount)) as "all_summ", min(p.amount) as min_amount, MAX(p.amount) as max_amount from rental r 
join customer c on r.customer_id = c.customer_id
join payment p on r.rental_id  = p.rental_id 
group by c.customer_id order by c.customer_id asc
/*Задание 5. Используя данные из таблицы городов, составьте одним запросом всевозможные пары городов так, чтобы в результате не было пар с одинаковыми названиями городов. Для решения необходимо использовать декартово произведение*/
select c.city , c2.city  from city c cross join city c2 
where c.city_id  <> c2.city_id 
/*Задание 6. Используя данные из таблицы rental о дате выдачи фильма в аренду (поле rental_date) и дате возврата (поле return_date), вычислите для каждого покупателя среднее количество дней, за которые он возвращает фильмы.*/
select round( avg((r.return_date::date - r.rental_date::date)), 2) as avg_rental, r.customer_id  from rental r where r.return_date is not  null  group by customer_id order  by customer_id 
-- Задание 7. Посчитайте для каждого фильма, сколько раз его брали в аренду, а также общую стоимость аренды фильма за всё время.
select f.film_id, count(*) as count_rental, sum(p.amount) as all_sum_rental from film f 
	join inventory i on f.film_id = i.film_id
	join rental r on i.inventory_id  = r.inventory_id
	join  payment p on p.rental_id = r.rental_id
		group by f.film_id order by f.film_id  
-- Задание 8. Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые ни разу не брали в аренду.
select f.film_id, r.*, i.* from film f 
	left join inventory i on f.film_id = i.film_id
	left join rental r on i.inventory_id  = r.inventory_id
	left join  payment p on p.rental_id = r.rental_id
		 where r.rental_id is null and i.inventory_id is null order by f.film_id
/*Задание 9. Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 7 300, то значение в колонке будет «Да», иначе должно быть значение «Нет».*/
select s.staff_id, (s.first_name::text || ' '::text) || s.last_name::text AS name, COUNT(r.rental_id) as count_store,
case when count(r.rental_id) > 7300 then 'Да' else 'Нет' end as "Премия"
	from staff s left join rental r on r.staff_id = s.staff_id  group by  s.staff_id, s.first_name, s.last_name 