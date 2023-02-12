--Написать два варианта скалярной функции, с IF и CASE,
--принимающих на вход номер месяца и возвращающих номер
--квартала.
CREATE OR REPLACE FUNCTION public.f_get_quarter(_month_num INT)
RETURNS VARCHAR AS
$$
DECLARE 
	_result VARCHAR;
BEGIN
	IF _month_num BETWEEN 1 AND 3 THEN _result := '1';
	ELSIF _month_num BETWEEN 4 AND 6 THEN _result := '2';
	ELSIF _month_num BETWEEN 7 AND 9 THEN _result := '3';
	ELSE _result := '4';
	END IF;
	
	_result := CONCAT(_result, ' квартал');
	
	RETURN _result;
END;
$$
LANGUAGE PLPGSQL;

SELECT f_get_quarter(6);


CREATE OR REPLACE FUNCTION public.f_get_quarter_v2(_month_num INT)
RETURNS VARCHAR AS
$$
DECLARE 
	_result VARCHAR;
BEGIN
	CASE _month_num
	WHEN 1, 2, 3 THEN _result := '1';
	WHEN 4, 5, 6 THEN _result := '2';
	WHEN 7, 8, 9 THEN _result := '3';
	ELSE _result := '4';
	END CASE;
	
	_result := CONCAT(_result, ' квартал');
	
	RETURN _result;
END;
$$
LANGUAGE PLPGSQL;

SELECT f_get_quarter_v2(6);


--Написать функцию, принимающую на вход номер месяца и
--город вылета, возвращающую списком (не таблицей) номера
--рейсов. Используйте данные в схеме booking.
CREATE OR REPLACE FUNCTION public.f_get_flight_numbers(_month_num INT, _departure_city VARCHAR)
RETURNS SETOF CHAR(6)
AS
$$
BEGIN
	RETURN QUERY
	SELECT DISTINCT(f.flight_no)
	FROM bookings.flights AS f
	JOIN bookings.airports_data as ad
	ON f.departure_airport = ad.airport_code
	WHERE 
		(DATE_PART('MONTH', f.scheduled_departure) = _month_num) AND
		(ad.city->>'ru' =_departure_city);
END;
$$
LANGUAGE PLPGSQL;

SELECT * from public.f_get_flight_numbers(11,'Нижневартовск')


--Написать процедуру, которая будет записывать новые данные
--в таблицу «prodmag.products». Данные будем записывать в
--формате JSON.
CREATE TYPE public.ct_products AS
	(
		product_id INT,
		products_name VARCHAR(24),
		food_type_id SMALLINT,
		unit_id SMALLINT,
		qty INTEGER,
		price NUMERIC(6,2),
		seller_id INTEGER,
		deadline SMALLINT
	);

CREATE OR REPLACE PROCEDURE public.p_set_products_json(input_values JSON) AS
$$
BEGIN

	INSERT INTO prodmag.products(product_id, products_name, food_type_id , unit_id, qty, price, seller_id, deadline) 
    SELECT *
    FROM JSON_POPULATE_RECORDSET(NULL::public.ct_products, input_values) AS t;
    
END;
$$
LANGUAGE PLPGSQL;

CALL public.p_set_products_json(
	'[{"product_id":1,
	   "products_name":"Авокадо",
	   "food_type_id":10, 
	   "unit_id":2, 
	   "qty":24,
	   "price":115.50, 
	   "seller_id":1,
	   "deadline":20}]');
	  
	  
--Написать функцию, принимающую на вход массив Numeric и
--считающую с помощью цикла среднее арифметическое всех
--его элементов.
CREATE OR REPLACE FUNCTION public.f_get_avg_value_from_array(_nums NUMERIC[])
RETURNS NUMERIC AS
$$
DECLARE 
	res NUMERIC := 0;
	cnt INT := 0;
	i INT; 
BEGIN
	
	FOREACH i IN ARRAY $1
	LOOP
		res := res + i; 
		cnt := cnt + 1;
	END LOOP;
	
	res = ROUND(res / cnt, 2);
	RETURN res;
END;
$$
LANGUAGE PLPGSQL;

SELECT public.f_get_avg_value_from_array('{1,2,2,3,4}')

