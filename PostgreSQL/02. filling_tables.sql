--Создадим временную таблицу, повторяющую структуру в файле
CREATE TABLE tag_data.tmp
	(
	device_type_name VARCHAR(16) NOT NULL,
	tag_name VARCHAR(32) NOT NULL,
	tag_description VARCHAR(64) NOT NULL,
	params_name VARCHAR(16) NOT NULL,
	unit_name VARCHAR(12) NOT NULL,
	measurement_date TIMESTAMP NOT NULL,
	measurement_value FLOAT NOT NULL
	);

--Скопируем данные в эту таблицу
COPY tag_data.tmp 
FROM 'C:/DataImportExport/tag_data.csv' 
WITH (FORMAT CSV, DELIMITER ';', ENCODING 'UTF8', HEADER);

--Заполним таблицу device_types
INSERT INTO tag_data.device_types(device_type_name)
SELECT DISTINCT(device_type_name) 
FROM tag_data.tmp;

--Заполним таблицу measured_params
INSERT INTO tag_data.measured_params(params_name)
SELECT DISTINCT(params_name) 
FROM tag_data.tmp;

--Заполним таблицу units
INSERT INTO tag_data.units(unit_name)
SELECT DISTINCT(unit_name)
FROM tag_data.tmp;

--Заполним таблицу tags
INSERT INTO tag_data.tags(
	tag_name, 
	tag_description, 
	device_type_id, 
	params_id, 
	unit_id)
SELECT 
	DISTINCT(tmp.tag_name), 
	tmp.tag_description, 
	d.device_type_id, 
	mp.params_id, 
	u.unit_id
FROM 
	tag_data.tmp,
	tag_data.device_types as d,
	tag_data.measured_params as mp,
	tag_data.units as u
WHERE
	(d.device_type_name = tmp.device_type_name) AND
	(mp.params_name = tmp.params_name) AND
	(u.unit_name = tmp.unit_name);
	
--Заполним таблицу measurements
INSERT INTO tag_data.measurements(
	measurement_date, 
	measurement_value, 
	tag_id)
SELECT 
	tmp.measurement_date, 
	tmp.measurement_value, 
	tags.tag_id
FROM 
	tag_data.tmp,
	tag_data.tags
WHERE tags.tag_name = tmp.tag_name;

--Запрос, который вернет из ваших таблиц данные в исходном виде (как в файле)
SELECT 	
	d.device_type_name,
	tags.tag_name,
	tags.tag_description,
	mp.params_name,
	u.unit_name,
	ms.measurement_date,
	ms.measurement_value
FROM
	tag_data.device_types as d,
	tag_data.tags,
	tag_data.measured_params as mp,
	tag_data.units as u,
	tag_data.measurements as ms
WHERE
	(ms.tag_id = tags.tag_id) AND
	(d.device_type_id = tags.device_type_id) AND
	(mp.params_id = tags.params_id) AND
	(u.unit_id = tags.unit_id);
	
--Удаление временной таблицы
DROP TABLE tag_data.tmp;
