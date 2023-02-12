--Задание №1
------------
--Создаем функцию для записи логов
CREATE TABLE prodmag.products_log
	(
	product_id SERIAL NOT NULL,
	products_name VARCHAR(24) NOT NULL,
	food_type_id SMALLINT NOT NULL,
	unit_id SMALLINT NOT NULL,
	qty INTEGER NOT NULL DEFAULT 0,
	price NUMERIC(6,2) NOT NULL,
	cost NUMERIC(10,2) NOT NULL,
	deadline SMALLINT NOT NULL,
	seller_id INTEGER NOT NULL,
	add_date DATE NOT NULL,
	operation VARCHAR(10) NOT NULL,
	row VARCHAR(3) NOT NULL
	);

--создаем триггерную функцию
CREATE OR REPLACE FUNCTION prodmag.trg() RETURNS TRIGGER AS
$$
DECLARE
	rec RECORD;
	str TEXT := '';
BEGIN
	
	IF TG_LEVEL = 'ROW' --TG_LEVEL уровень строка или операция
	THEN
	
		CASE TG_OP --TG_OP имя оператора
		WHEN 'INSERT' THEN 
			rec := NEW;
			str := NEW::TEXT;
			INSERT INTO prodmag.products_log
			VALUES(
				NEW.product_id, NEW.products_name, NEW.food_type_id,
				NEW.unit_id, NEW.qty, NEW.price,
				NEW.cost, NEW.deadline, NEW.seller_id,
				current_date, 'insert', 'new'
			);
		WHEN 'UPDATE' THEN 
			rec := NEW;
			str := OLD || ' -> ' || NEW;
			INSERT INTO prodmag.products_log
			VALUES(
				OLD.product_id, OLD.products_name, OLD.food_type_id,
				OLD.unit_id, OLD.qty, OLD.price,
				OLD.cost, OLD.deadline, OLD.seller_id,
				current_date, 'update', 'old'
			);
			INSERT INTO prodmag.products_log
			VALUES(
				NEW.product_id, NEW.products_name, NEW.food_type_id,
				NEW.unit_id, NEW.qty, NEW.price,
				NEW.cost, NEW.deadline, NEW.seller_id,
				current_date, 'update', 'new'
			);
		WHEN 'DELETE' THEN 
			rec := OLD;
			str := OLD::TEXT;
			INSERT INTO prodmag.products_log
			VALUES(
				OLD.product_id, OLD.products_name, OLD.food_type_id,
				OLD.unit_id, OLD.qty, OLD.price,
				OLD.cost, OLD.deadline, OLD.seller_id,
				current_date, 'delete', 'old'
			);
		END CASE;
		
	END IF;
		
	RAISE NOTICE '% % % %: %', 
		TG_TABLE_NAME, --имя таблицы, на которой сработал триггер
		TG_WHEN, --условие фильтра
		TG_OP, --имя оператора
		TG_LEVEL, --уровень строка или операция
		str;
		
	RETURN rec;

END;
$$
LANGUAGE PLPGSQL;

--создаем триггер на уровне оператора AFTER ROW
CREATE TRIGGER tr_after_row
AFTER INSERT OR UPDATE OR DELETE  --события
ON prodmag.products               --таблица
FOR EACH ROW                      --уровень
EXECUTE FUNCTION prodmag.trg();   --функция

--Проверяем вставку (изначально таблица пустая)
INSERT INTO prodmag.products 
	(
	products_name,
	food_type_id,
	unit_id,
	qty,
	price,
	deadline,
	seller_id
	)
VALUES
(
	'Авокадо', 
	(SELECT food_type_id FROM prodmag.food_types WHERE food_type_name = 'Фрукты'),
	(SELECT unit_id FROM prodmag.units WHERE unit_name = 'кг'),
	24,
	115.50,
	30,
	(SELECT seller_id FROM prodmag.sellers WHERE seller_name = 'ВнешПлодИмпорт')
	),
	(
	'Ананас',
	(SELECT food_type_id FROM prodmag.food_types WHERE food_type_name = 'Фрукты'),
	(SELECT unit_id FROM prodmag.units WHERE unit_name = 'кг'),
	65,
	325.50,
	20,
	(SELECT seller_id FROM prodmag.sellers WHERE seller_name = 'ВнешПлодИмпорт')
	),
	(
	'Бананы',
	(SELECT food_type_id FROM prodmag.food_types WHERE food_type_name = 'Фрукты'),
	(SELECT unit_id FROM prodmag.units WHERE unit_name = 'кг'),
	360,
	81.10,
	15,
	(SELECT seller_id FROM prodmag.sellers WHERE seller_name = 'ВнешПлодИмпорт')
	);

--Проверяем апдейт
UPDATE prodmag.products SET products_name = 'Апельсин' WHERE product_id = 1;

--Проверяем удаление
DELETE FROM prodmag.products WHERE product_id > 1;

--Смотрим записи логов 
SELECT * FROM prodmag.products_log;



--Задание №2
------------
CREATE OR REPLACE FUNCTION prodmag.check_trg() RETURNS TRIGGER AS
$$
DECLARE
	rec RECORD;
	str TEXT := '';
BEGIN
	
	IF TG_LEVEL = 'ROW' 
	THEN
		IF (NEW.products_name = '')
			THEN
				RAISE EXCEPTION 'Название продукта не может быть пустым';
			END IF;
			
			IF NEW.price <= 0
			THEN
				RAISE EXCEPTION 'Стоимость продукта не может быть <= 0: %', NEW.price
				USING HINT = 'Введите правильную стоимость', ERRCODE = 12882;
			END IF;
			
		CASE TG_OP
		WHEN 'INSERT' THEN 
			rec := NEW;
			str := NEW::TEXT;
			
		WHEN 'UPDATE' THEN 
			rec := NEW;
			str := OLD || ' -> ' || NEW;
		END CASE;
		
	END IF;
		
	RAISE NOTICE '% % % %: %', 
		TG_TABLE_NAME,
		TG_WHEN,
		TG_OP, 
		TG_LEVEL, 
		str;
		
	RETURN rec;

END;
$$
LANGUAGE PLPGSQL;

CREATE TRIGGER tr_before_row
BEFORE INSERT OR UPDATE OR DELETE 
ON prodmag.products                
FOR EACH ROW                      
EXECUTE FUNCTION prodmag.check_trg();  

--Проверим первый exception во вставке
INSERT INTO prodmag.products 
	(
	products_name,
	food_type_id,
	unit_id,
	qty,
	price,
	deadline,
	seller_id
	)
VALUES
	(
	'',
	(SELECT food_type_id FROM prodmag.food_types WHERE food_type_name = 'Консервы'),
	(SELECT unit_id FROM prodmag.units WHERE unit_name = 'шт'),
	150,
	100,
	2500,
	(SELECT seller_id FROM prodmag.sellers WHERE seller_name = 'РусАгро')
	);

--Проверим второй exception во вставке
INSERT INTO prodmag.products 
	(
	products_name,
	food_type_id,
	unit_id,
	qty,
	price,
	deadline,
	seller_id
	)
VALUES
	(
	'some_product',
	(SELECT food_type_id FROM prodmag.food_types WHERE food_type_name = 'Консервы'),
	(SELECT unit_id FROM prodmag.units WHERE unit_name = 'шт'),
	150,
	-100,
	2500,
	(SELECT seller_id FROM prodmag.sellers WHERE seller_name = 'РусАгро')
	);

--Проверим первый exception в апдейте
UPDATE prodmag.products SET products_name = '' WHERE product_id = 1;

--Проверим второй exception в апдейте
UPDATE prodmag.products SET price = -10 WHERE product_id = 1;
