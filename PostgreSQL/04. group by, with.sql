--ЗАДАНИЕ 1
--Напишите запрос к таблицам в схеме «booking», который
--вернет суммарное количество рейсов (перелетов) по каждому
--типу самолета, посуточно за январь 2017 года.
SELECT 
	ad.model->>'ru' as aircraft_model,
	f.scheduled_departure::date,
	COUNT(*) AS flights_count	
FROM bookings.flights AS f
JOIN bookings.aircrafts_data AS ad
	USING(aircraft_code)
WHERE f.scheduled_departure::date BETWEEN '2017-01-01' AND '2017-01-31'
GROUP BY ad.model, f.scheduled_departure::date;


--Напишите запрос из таблиц в схеме «booking» который вернет
--общую сумму бронирований и среднее значение
--бронирований посуточно за январь 2017 года.
SELECT 
	b.book_date::date,
	SUM(b.total_amount),
	AVG(b.total_amount)
FROM bookings.bookings AS b
WHERE b.book_date::date BETWEEN '2017-01-01' AND '2017-01-31'
GROUP BY b.book_date::date
ORDER BY SUM(b.total_amount) DESC;


--ЗАДАНИЕ 2
--1. ВОЗВРАЩЕНИЕ ВСЕХ ПРЯМЫХ ПОДЧИНЕННЫХ, БЕЗ УЧЕТА ТЕХ У КОГО НЕТ ПОДЧИНЕННЫХ 
WITH RECURSIVE subordinate AS 
(
	SELECT id, fio, post, parent_id
	FROM public.staff
	WHERE id = 1 

	UNION ALL

	SELECT s.id, s.fio, s.post, s.parent_id
	FROM public.staff AS s
	JOIN subordinate AS sub
		ON sub.id = s.parent_id
)
SELECT 
	--sub.id, sub.fio, sub.post
	s.id, s.fio, s.post, COUNT(s.id) as count_direct_subordinates
FROM public.staff as s
JOIN subordinate AS sub
	ON sub.parent_id = s.id 
GROUP BY s.id
ORDER BY s.id

--1. ВОЗВРАЩЕНИЕ ВСЕХ ПРЯМЫХ ПОДЧИНЕННЫХ, С УЧЕТОМ ТЕХ У КОГО НЕТ ПОДЧИНЕННЫХ,
--В ТАБЛИЦЕ У НИХ БУДЕТ УКАЗАНО 0 ПОДЧИНЕННЫХ (Создадим VIEW для следующего задания)
CREATE OR REPLACE VIEW public.v_direct_subordinates AS
	WITH RECURSIVE subordinate AS 
	(
		SELECT id, fio, post, parent_id
		FROM public.staff
		WHERE id = 1 

		UNION ALL

		SELECT s.id, s.fio, s.post, s.parent_id
		FROM public.staff AS s
		JOIN subordinate AS sub
			ON sub.id = s.parent_id
	)
	SELECT 
		s.id,
		s.parent_id,
		s.fio, 
		s.post, 
		CASE WHEN MIN(sub.id) IS NULL
			THEN 0
			ELSE COUNT(s.id)
		END AS count_direct_subordinates
	FROM public.staff as s
	LEFT JOIN subordinate AS sub
		ON sub.parent_id = s.id 
	GROUP BY s.id
	ORDER BY s.id;

SELECT * 
FROM public.v_direct_subordinates

--2*. посчитать сколько у каждого человека сотрудников 
--в подчинении, и непосредственных, и косвенных.
--Используется view из прошлого задания
WITH RECURSIVE r AS
(
	SELECT 
		ds.id,
		ds.count_direct_subordinates,
		ds.id AS root_id
	FROM public.v_direct_subordinates AS ds
	
	UNION ALL
	
	SELECT 
		ds2.id,
		ds2.count_direct_subordinates,
		r.root_id
	FROM public.v_direct_subordinates AS ds2
	JOIN r ON ds2.parent_id = r.id
)
SELECT ds.id,
       ds.parent_id,
       ds.fio,
	   ds.post,
       ds.count_direct_subordinates,
       s.all_count
FROM public.v_direct_subordinates AS ds
JOIN 
	(SELECT 
		root_id,
		SUM(count_direct_subordinates) AS all_count
	FROM r
    GROUP BY root_id) AS s
ON ds.id = s.root_id
ORDER BY ds.id
