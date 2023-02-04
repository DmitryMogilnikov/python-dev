--ЗАДАНИЕ 1
CREATE OR REPLACE VIEW public.v_flights AS
SELECT
	f.flight_no,
	f.scheduled_departure, 
	f.departure_airport,
	apd1.city AS departure_city,
	apd1.airport_name AS departure_airport_name,
	f.scheduled_arrival, 
	f.arrival_airport,
	apd2.city AS arrival_city,
	apd2.airport_name AS arrival_airport_name,
	acd.model
FROM bookings.flights AS f
JOIN bookings.airports_data AS apd1
	ON f.departure_airport = apd1.airport_code
JOIN bookings.airports_data AS apd2 
	ON f.arrival_airport = apd2.airport_code
JOIN bookings.aircrafts_data AS acd
	USING(aircraft_code)
WHERE 
	((apd1.city ->> 'en' = 'Moscow') OR
	(apd1.city ->>  'en' = 'St. Petersburg')) AND
	(CAST(f.scheduled_departure AS time) < '12:00:00');


--ЗАДАНИЕ 2
--Создаем view для объединения таблиц, чтобы проще обращаться к результату
CREATE OR REPLACE VIEW public.v_tags AS
SELECT 
	tags.tag_name,
	u.unit_name,
	ms.measurement_date,
	ms.measurement_value
FROM tag_data.tags
JOIN tag_data.units as u
	USING(unit_id)
JOIN tag_data.measurements as ms
	USING(tag_id)

--Создаем итоговый view с результатами по трем тегам
CREATE OR REPLACE VIEW public.v_tags_last_measurements AS
(SELECT *
FROM public.v_tags
WHERE tag_name = 'G43-107:FCA3-260.F'
ORDER BY measurement_date DESC
LIMIT 10)
UNION
(SELECT *
FROM public.v_tags
WHERE tag_name = 'GOBKK:AI017.Q'
ORDER BY measurement_date DESC
LIMIT 10)
UNION
(SELECT *
FROM public.v_tags
WHERE tag_name = 'AVT6:FIRC0964.F'
ORDER BY measurement_date DESC
LIMIT 10)
ORDER BY tag_name, measurement_date;


--ЗАДАНИЕ 3
CREATE TABLE public.programming_languages1
	(
	id SMALLSERIAL NOT NULL,
	name VARCHAR(32) NOT NULL,
	CONSTRAINT pl1_name_ukey UNIQUE(name),
	CONSTRAINT pl1_pkey PRIMARY KEY(id)
	);
	
CREATE TABLE public.programming_languages2
	(
	id SMALLSERIAL NOT NULL,
	name VARCHAR(32) NOT NULL,
	CONSTRAINT pl2_name_ukey UNIQUE(name),
	CONSTRAINT pl2_pkey PRIMARY KEY(id)
	);
	
INSERT INTO public.programming_languages1(name) 
VALUES 
('Java'), ('C#'), ('Python'),
('Pascal'), ('C++'), ('C'),
('Rust'), ('R'), ('JavaScript'),
('Go');
INSERT INTO public.programming_languages2(name) 
VALUES 
('Python'), ('TypeScript'), ('SQL'),
('1C'), ('C++'), ('Swift'),
('Ruby'), ('Scala'), ('Java'),
('Haskell');

--Общие элементы таблиц
SELECT pl1.name 
FROM public.programming_languages1 AS pl1
INTERSECT 
SELECT pl2.name 
FROM public.programming_languages2 AS pl2
ORDER BY name;

--Элементы, которые есть в первой таблице, но нет во второй
CREATE OR REPLACE VIEW public.v_pl1_unique AS
SELECT pl1.name 
FROM public.programming_languages1 AS pl1
EXCEPT
SELECT pl2.name 
FROM public.programming_languages2 AS pl2
ORDER BY name;

--Элементы, которые есть в первой таблице, но нет во второй
CREATE OR REPLACE VIEW public.v_pl2_unique AS
SELECT pl2.name 
FROM public.programming_languages2 AS pl2
EXCEPT
SELECT pl1.name 
FROM public.programming_languages1 AS pl1
ORDER BY name;

--Объединение уникальных элементов из каждой таблицы
SELECT * FROM public.v_pl1_unique
UNION
SELECT * FROM public.v_pl2_unique;

