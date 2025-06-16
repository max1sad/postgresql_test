-- Задание 1. Напишите SQL-запрос, который выводит всю информацию о фильмах со специальным атрибутом (поле special_features) равным “Behind the Scenes”.
select * from film f where 'Behind the Scenes' = any(f.special_features)
-- Задание 2. Напишите ещё 2 варианта поиска фильмов с атрибутом “Behind the Scenes”, используя другие функции или операторы языка SQL для поиска значения в массиве.
select * from (
select *, generate_subscripts(f.special_features, 1) AS id_e from film f ) t
where t.special_features[t.id_e] = 'Behind the Scenes';
select * from film f where  array['Behind the Scenes'] && f.special_features 
/*Задание 3. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в CTE.*/
with spec_f  as (
	select * from film f where 'Behind the Scenes' = any(f.special_features)
)
select  c.customer_id, (c.first_name::text || ' '::text) || c.last_name::text AS name, count(c.customer_id) from spec_f f
 	join inventory i on f.film_id = i.film_id
	join rental r on i.inventory_id  = r.inventory_id
	join customer c on r.customer_id = c.customer_id
		group by c.customer_id, c.first_name,c.last_name order by c.customer_id
/*Задание 4. Для каждого покупателя посчитайте, сколько он брал в аренду фильмов со специальным атрибутом “Behind the Scenes”.
Обязательное условие для выполнения задания: используйте запрос из задания 1, помещённый в подзапрос, который необходимо использовать для решения задания.*/
select  c.customer_id, (c.first_name::text || ' '::text) || c.last_name::text AS name, count(c.customer_id) from film f
 	join inventory i on f.film_id = i.film_id
	join rental r on i.inventory_id  = r.inventory_id
	join customer c on r.customer_id = c.customer_id
	where f.film_id in (	
		select film_id from film f where 'Behind the Scenes' = any(f.special_features)) 
	group by c.customer_id, c.first_name,c.last_name  order by c.customer_id 
-- Задание 5. Создайте материализованное представление с запросом из предыдущего задания и напишите запрос для обновления материализованного представления.
create  MATERIALIZED VIEW customer_film AS
select  c.customer_id, (c.first_name::text || ' '::text) || c.last_name::text AS name, count(c.customer_id) from film f
 	join inventory i on f.film_id = i.film_id
	join rental r on i.inventory_id  = r.inventory_id
	join customer c on r.customer_id = c.customer_id
	where f.film_id in (	
		select film_id from film f where 'Behind the Scenes' = any(f.special_features)) 
	group by c.customer_id, c.first_name,c.last_name  order by c.customer_id 
	-- обновление материализованного представления
REFRESH MATERIALIZED VIEW customer_film
/*Задание 6. С помощью explain analyze проведите анализ скорости выполнения запросов из предыдущих заданий и ответьте на вопросы:
с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания, поиск значения в массиве происходит быстрее;
какой вариант вычислений работает быстрее: с использованием CTE или с использованием подзапроса.*/
Поиск в массе происходит быстрее через использование функции поиска в массиве ANY или ALL в зависимости от условия поиска.
При вычислениях через CTE или подзапрос время выполнения практически одинаковое, но с использованием CTE чуть по быстрее происходит выполнение.
-- Задание 7. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
select * from (
	select * , row_number() over (partition by s.staff_id order by r.rental_date asc) as rn from staff s join rental r on r.staff_id = s.staff_id)
where rn = 1
/*Задание 8. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.*/
with day_data as (
	select s.store_id , date(r.rental_date) as day_r, 
	count (r.rental_date::date) over (partition by s.store_id, r.rental_date::date) as count_rentl, p.amount, 
	sum (p.amount) over (partition by s.store_id, r.rental_date::date) as sum_rental_d from store s 
		left join customer c on c.store_id = s.store_id
		left join rental r on r.customer_id = c.customer_id
		left join payment p on p.rental_id = r.rental_id ),
max_rental_dey as (
	select day_r as day_max_r, count_rentl from day_data order by count_rentl desc limit 1 )
select * from (
	select day_r as day_min_sum, sum_rental_d  from day_data order by sum_rental_d asc limit 1) t, max_rental_dey