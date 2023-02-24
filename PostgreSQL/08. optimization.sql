--Запрос ищет пассажиров кто должен был лететь бизнесом и кому не повезло, 
--их рейсы отменили или задержали более одного раза и сумму брони по ним

--попробуйте ускорить данный запрос
--время выполнения ~800 mc
SELECT
	sel.passenger_name,
    SUM(sel.total_amount)	
FROM
	(
    SELECT 
      COUNT(*) OVER (PARTITION BY t.passenger_name) AS cnt,
      b.total_amount,
      t.passenger_name
    FROM bookings.tickets AS t
    JOIN  bookings.ticket_flights AS tf
        ON tf.ticket_no = t.ticket_no
    JOIN bookings.flights AS f
        ON f.flight_id = tf.flight_id 
    JOIN bookings.bookings AS b
        ON b.book_ref = t.book_ref
    WHERE f.status IN ('Delayed','Cancelled')
        AND tf.fare_conditions = 'Business'
    ) AS sel
WHERE sel.cnt > 1
GROUP BY sel.passenger_name;
----
--Ничего не изменилось, кажется стало только медленнее. С большим количеством WITH еще хуже)
WITH delayed_flights AS
	(
    SELECT flight_id 
    FROM bookings.flights AS f
    WHERE f.status IN ('Delayed','Cancelled')
    )
SELECT
	sel.passenger_name,
    SUM(sel.total_amount)	
FROM
	(
    SELECT 
      COUNT(*) OVER (PARTITION BY t.passenger_name) AS cnt,
      b.total_amount,
      t.passenger_name
    FROM bookings.tickets AS t
    JOIN  bookings.ticket_flights AS tf
        ON tf.ticket_no = t.ticket_no
    JOIN bookings.bookings AS b
        ON b.book_ref = t.book_ref
	JOIN delayed_flights USING(flight_id) 
	WHERE tf.fare_conditions = 'Business'
    ) AS sel
WHERE sel.cnt > 1
GROUP BY sel.passenger_name;

--этот индекс ускорил запрос изначальный запрос в 2 раза ~400мс
CREATE INDEX idx_ticket_flights_fare_conditions ON bookings.ticket_flights (fare_conditions);

--этот индекс ускорил изначальный запрос еще в 2 раза ~200мc
CREATE INDEX idx_ticket_flight_id ON bookings.ticket_flights (flight_id);

--так что используем изначальный запрос и эти два индекса ~200мc
--хотя даже один индекс по flight_id дает почти такой же результат ~250мс
SELECT
	sel.passenger_name,
    SUM(sel.total_amount)	
FROM
	(
    SELECT 
      COUNT(*) OVER (PARTITION BY t.passenger_name) AS cnt,
      b.total_amount,
      t.passenger_name
    FROM bookings.tickets AS t
    JOIN  bookings.ticket_flights AS tf
        ON tf.ticket_no = t.ticket_no
    JOIN bookings.flights AS f
        ON f.flight_id = tf.flight_id 
    JOIN bookings.bookings AS b
        ON b.book_ref = t.book_ref
    WHERE f.status IN ('Delayed','Cancelled')
        AND tf.fare_conditions = 'Business'
    ) AS sel
WHERE sel.cnt > 1
GROUP BY sel.passenger_name;

-- после изменения random_page_cost = 4.0 -> random_page_cost = 1.0
--измененный запрос отрабатывает быстрее на 60 мс
/* ******************************************************************* */
DROP INDEX bookings.idx_ticket_flights_fare_conditions;
DROP INDEX bookings.idx_ticket_flight_id;
--Запрос считает общее количество мест в самолете и количество проданных билетов на рейсы

--попробуйте ускорить данный запрос ~4 минуты 20 cекунд. ОГО, думал не дождусь))
EXPLAIN ANALYZE
SELECT  
	f.scheduled_departure::date as vilet,
    f.flight_no,
	a1.airport_name AS from_air,
	a2.airport_name AS to_air,
	(SELECT COUNT(*) FROM bookings.seats AS s WHERE s.aircraft_code = f.aircraft_code) AS vsego_mest,
	(SELECT COUNT(*) FROM bookings.ticket_flights AS tf WHERE tf.flight_id = f.flight_id) AS zanyato_mest
FROM bookings.flights AS f
JOIN bookings.airports AS a1 
	ON a1.airport_code = f.departure_airport
JOIN bookings.airports as a2 
	ON a2.airport_code = f.arrival_airport
ORDER BY vilet
LIMIT 100;

--этот индекс ускорил изначальный запрос в 600 раз!! ~420мc, это уже очень чувствуется конечно
CREATE INDEX idx_ticket_flight_id ON bookings.ticket_flights (flight_id);

--этот индекс не дал большого ускорения ~ 390мс, т.к. там индексом выступает primary key
CREATE INDEX idx_seats_aircraft_code ON bookings.seats (aircraft_code);
DROP INDEX bookings.idx_seats_aircraft_code


--Запрос показывает рассадку пассажиров в бизнес-классе в Аэробасе Боинг 737-300
DROP INDEX bookings.idx_ticket_flight_id;

--попробуйте ускорить данный запрос ~1m 45c
SELECT 
    f.flight_no,
    f.scheduled_departure,
    a.model,
    t.passenger_name,
    bp.ticket_no,
    bp.seat_no
FROM bookings.flights AS f
JOIN bookings.aircrafts AS a ON a.aircraft_code = f.aircraft_code
JOIN bookings.ticket_flights AS tf ON tf.flight_id = f.flight_id
JOIN bookings.boarding_passes AS bp ON bp.flight_id = tf.flight_id AND bp.ticket_no = tf.ticket_no
JOIN bookings.tickets AS t ON t.ticket_no = tf.ticket_no
WHERE a.model = 'Боинг 737-300'
	AND tf.fare_conditions = 'Business'
ORDER BY f.scheduled_departure DESC, bp.seat_no ASC
LIMIT 100;

--этот индекс ускорил изначальный запрос в 2 раза, ~54c
CREATE INDEX idx_ticket_flight_id ON bookings.ticket_flights (flight_id);

--вынесем проверку модели, время выполнения ~2,5 c, ускорение еще в 20 раз
--если выносить еще проверку business то немного замедляется
EXPLAIN ANALYZE
WITH model AS
(
	SELECT aircraft_code, model
	FROM bookings.aircrafts
	WHERE model = 'Боинг 737-300'
)
SELECT 
    f.flight_no,
    f.scheduled_departure,
    m.model,
    t.passenger_name,
    bp.ticket_no,
    bp.seat_no
FROM bookings.flights AS f
JOIN model AS m USING(aircraft_code)
JOIN bookings.ticket_flights AS tf ON tf.flight_id = f.flight_id
JOIN bookings.boarding_passes AS bp ON bp.flight_id = tf.flight_id AND bp.ticket_no = tf.ticket_no
JOIN bookings.tickets AS t ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
	ORDER BY f.scheduled_departure DESC, bp.seat_no ASC
LIMIT 100;

--не дает ускорения
CREATE INDEX idx_ticket_flights_fare_conditions ON bookings.ticket_flights (fare_conditions);
DROP INDEX bookings.idx_ticket_flights_fare_conditions
--не дает ускорения
CREATE INDEX idx_ticket_flights_ticket_no ON bookings.ticket_flights (ticket_no);
DROP INDEX bookings.idx_ticket_flights_ticket_no
