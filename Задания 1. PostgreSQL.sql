-- Задание 1. Выведите уникальные названия городов из таблицы городов.
select distinct c.city from city c
/*Задание 2. Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города, названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.*/
select distinct c.city from city c where c.city  ~ '^L[^\s]*a$'
/*Задание 3. Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно и стоимость которых превышает 1.00. Платежи нужно отсортировать по дате платежа.*/
select p.* from payment p where p.payment_date >= '2005-06-17' and p.payment_date <= '2005-06-19'and p.amount > 1.0 order by p.payment_date
-- Задание 4. Выведите информацию о 10-ти последних платежах за прокат фильмов.
select p.* from payment p order by p.payment_date desc limit 10
/*Задание 5. Выведите следующую информацию по покупателям:
Фамилия и имя (в одной колонке через пробел)
Электронная почта
Длину значения поля email
Дату последнего обновления записи о покупателе (без времени)
 Каждой колонке задайте наименование на русском языке.*/
select (c.first_name::text || ' '::text) || c.last_name::text AS "Фамилия и имя", c.email as "Электронная почта", CHAR_LENGTH(c.email) as "Длина",
	c.last_update::date as "Дата последнего обновления"
from customer c
/*Задание 6. Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE. Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.*/
select c.customer_id, c.store_id, lower(c.first_name), lower(c.last_name), c.email l, c.address_id, 
	c.activebool, c.create_date, c.last_update, c.active 
from customer c where c.active = 1 and c.first_name ~ 'KELLY|WILLIE'
/*Задание 7. Выведите одним запросом информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.*/
select * from film f where (f.rating = 'R' and f.rental_rate >= 0.0 and f.rental_rate <= 3.0) or (f.rating = 'PG-13' and f.rental_rate >= 4.0)
--Задание 8. Получите информацию о трёх фильмах с самым длинным описанием фильма.
select *, CHAR_LENGTH(f.description) as len_d from film f  order by len_d desc limit 3
/*Задание 9. Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
в первой колонке должно быть значение, указанное до @,
во второй колонке должно быть значение, указанное после @.*/
select c.customer_id , split_part(c.email, '@', 1) as first_email, split_part(c.email, '@', 2) as last_email  from customer c
-- Задание 10. Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: первая буква должна быть заглавной, остальные строчными.
select c.customer_id , substr(split_part(c.email, '@', 1), 1, 1) || lower(substr(split_part(c.email, '@', 1), 2)) as first_email, 
	UPPER(substr(split_part(c.email, '@', 2), 1, 1))  || substr(split_part(c.email, '@', 2), 2) as last_email  from customer c 