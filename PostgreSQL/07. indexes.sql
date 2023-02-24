-------bookings.book_date------
--делаем выборку на определенную дату, без индекса ~ 374мс
SELECT * 
FROM bookings.bookings
WHERE book_date = '15.08.2017 17:56:00+03';

--создадим индекс по полю с датой типа B-Tree ~ 2с
CREATE INDEX idx_index_book_date_1 ON bookings.bookings(book_date);

--делаем выборку на определенную дату, с индексом ~ 187мс
SELECT * 
FROM bookings.bookings
WHERE book_date = '15.08.2017 17:56:00+03';

--индекс типа B-Tree занимает ~27mb места на диске
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_book_date_1'));

DROP INDEX bookings.idx_index_book_date_1;

--создадим индекс по полю с датой диапазонного типа BRIN ~ 601мс
CREATE INDEX idx_index_book_date_2 ON bookings.bookings USING BRIN (book_date); 

--делаем выборку на определенную дату, с индексом ~ 220мс 
--(прирост по времени меньше, вероятно из-за того, что даты неупорядочены, 
--но занимает намного меньше места, поэтому данное значение оптимальнее)
EXPLAIN
SELECT * 
FROM bookings.bookings
WHERE book_date = '15.08.2017 17:56:00+03';

--индекс типа BRIN занимает на диске всего 48kb
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_book_date_2'));

DROP INDEX bookings.idx_index_book_date_2;




-------tickets.passenger_id------
--делаем выборку на определенный id, без индекса ~ 7с
SELECT *
FROM bookings.tickets
WHERE passenger_id = '9999 985697';

--создадим индекс по полю с passenger_id типа B-Tree
CREATE INDEX idx_index_passenger_id_1 ON bookings.tickets(passenger_id); 

--выборка по текстовому полю с индексом B-Tree ~150мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_id = '9999 985697';

--индекс типа B-Tree занимает на диске ~89mb
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_id_1'));

DROP INDEX bookings.idx_index_passenger_id_1;

--создадим индекс по полю с passenger_id типа HASH
CREATE INDEX idx_index_passenger_id_2 ON bookings.tickets USING HASH (passenger_id);

--выборка по текстовому полю с индексом HASH ~159мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_id = '9999 985697';

--индекс типа HASH занимает на диске ~80mb, значит можем использовать его, как более оптимальный
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_id_2'));

DROP INDEX bookings.idx_index_passenger_id_2;

--создадим индекс по полю с passenger_id типа GIN ~50c
CREATE INDEX idx_index_passenger_id_3 ON bookings.tickets USING GIN (passenger_id);

--выборка по текстовому полю с индексом GIN ~192мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_id = '9999 985697';

--индекс типа GIN занимает на диске ~204mb, и работает медленнее, значит оставляем HASH
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_id_3'));

DROP INDEX bookings.idx_index_passenger_id_3;




-------tickets.passenger_name------
--делаем выборку на определенный name, без индекса ~ 510мс
SELECT *
FROM bookings.tickets
WHERE passenger_name = 'ALEKSEY NOVIKOV'

--создадим индекс по полю с passenger_name типа B-Tree
CREATE INDEX idx_index_passenger_name_1 ON bookings.tickets(passenger_name); 

--выборка по текстовому полю с индексом B-Tree ~280мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_name = 'ALEKSEY NOVIKOV'

--индекс типа B-Tree занимает на диске ~21mb
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_name_1'));

DROP INDEX bookings.idx_index_passenger_name_1;

--создадим индекс по полю с passenger_name типа HASH
CREATE INDEX idx_index_passenger_name_2 ON bookings.tickets USING HASH (passenger_name);

--выборка по текстовому полю с индексом HASH ~511мс - нет ускорения
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_name = 'ALEKSEY NOVIKOV'

--индекс типа HASH занимает на диске ~114 - точно не используем здесь, дефолтный лучше
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_name_2'));

DROP INDEX bookings.idx_index_passenger_name_2;

--создадим индекс по полю с passenger_name типа B-Tree с использованием латинской локали
CREATE INDEX idx_index_passenger_name_3 ON bookings.tickets(passenger_name COLLATE "C"); 

--выборка по текстовому полю с индексом B-Tree ~87мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE passenger_name = 'ALEKSEY NOVIKOV'

--индекс типа B-Tree с латинской локалью занимает на диске ~21mb, 
--самый оптимальный, для данного столбца используем его 
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_passenger_name_3'));

DROP INDEX bookings.idx_index_passenger_name_3;




-------tickets.contact_data------
--делаем выборку на определенный contact_data, без индекса ~ 1с
SELECT *
FROM bookings.tickets
WHERE contact_data = '{"phone": "+70001171617"}'

--создадим индекс по полю с contact_data типа B-Tree ~25c
CREATE INDEX idx_index_contact_data_1 ON bookings.tickets(contact_data); 

--выборка по текстовому полю с индексом B-Tree ~200мс
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE contact_data = '{"phone": "+70001171617"}'

--индекс типа B-Tree занимает на диске ~226mb
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_contact_data_1'));

DROP INDEX bookings.idx_index_contact_data_1;

--создадим индекс по полю с passenger_name типа GIN
CREATE INDEX idx_index_contact_data_2 ON bookings.tickets USING GIN(contact_data); 

--выборка по текстовому полю с индексом B-Tree не дает выигрыша
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE contact_data = '{"phone": "+70001171617"}'

--индекс типа GIN занимает на диске ~381mb, и не дает выигрыша во времени, не используем его здесь 
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_contact_data_2'));

DROP INDEX bookings.idx_index_contact_data_2;

--создадим индекс по полю с passenger_name типа HASH
CREATE INDEX idx_index_contact_data_3 ON bookings.tickets USING HASH (contact_data);

--выборка по текстовому полю с индексом HASH ~200мс - нет ускорения
EXPLAIN
SELECT *
FROM bookings.tickets
WHERE contact_data = '{"phone": "+70001171617"}'

--индекс типа HASH занимает на диске ~80mb - используем здесь, справляется лучше остальных
SELECT pg_size_pretty(pg_total_relation_size('bookings.idx_index_contact_data_3'));

DROP INDEX bookings.idx_index_contact_data_3;
