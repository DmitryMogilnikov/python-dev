--создадим схему
CREATE SCHEMA tag_data;

--создадим таблицу для установок
CREATE TABLE  tag_data.device_types
	(
	device_type_id SMALLSERIAL NOT NULL,
	device_type_name VARCHAR(16) NOT NULL,
	CONSTRAINT device_types_ukey UNIQUE(device_type_name),
	CONSTRAINT device_types_pkey PRIMARY KEY(device_type_id)
	);
	
--создадим таблицу для измеряемых параметров
CREATE TABLE tag_data.measured_params
	(
	params_id SMALLSERIAL NOT NULL,
	params_name VARCHAR(16) NOT NULL,
	CONSTRAINT params_ukey UNIQUE(params_name),
	CONSTRAINT params_pkey PRIMARY KEY(params_id)
	);

--создадим таблицу для единиц измерения
CREATE TABLE tag_data.units
	(
	unit_id SMALLSERIAL NOT NULL,
	unit_name VARCHAR(12) NOT NULL,
	CONSTRAINT units_ukey UNIQUE(unit_name),
	CONSTRAINT units_pkey PRIMARY KEY(unit_id)
	);
	
--создадим таблицу для имен тегов и их описаний, ссылается на первую по полю device_type_id, 
--вторую по полю params_id и третью по полю unit_id
CREATE TABLE tag_data.tags
	(
	tag_id SMALLSERIAL NOT NULL,
	tag_name VARCHAR(32) NOT NULL,
	tag_description VARCHAR(64) NOT NULL,
	device_type_id SMALLINT NOT NULL,
	params_id SMALLINT NOT NULL,
	unit_id SMALLINT NOT NULL,
		
	CONSTRAINT tag_name_ukey UNIQUE(tag_name),
	CONSTRAINT tag_pkey PRIMARY KEY(tag_id),
	
	CONSTRAINT device_type_id_fk FOREIGN KEY (device_type_id)
		REFERENCES tag_data.device_types(device_type_id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
	
	CONSTRAINT params_id_fk FOREIGN KEY (params_id)
		REFERENCES tag_data.measured_params(params_id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION,
		
	CONSTRAINT unit_id_fk FOREIGN KEY (unit_id)
		REFERENCES tag_data.units(unit_id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
	);

--таблица дат и значений тегов, ссылается на таблицу tags по полю tag_id
CREATE TABLE tag_data.measurements
	(
	measurement_id SERIAL NOT NULL,
	measurement_date TIMESTAMP NOT NULL,
	measurement_value FLOAT NOT NULL,
	tag_id SMALLINT NOT NULL,

	CONSTRAINT measurement_id_pkey PRIMARY KEY(measurement_id),
		
	CONSTRAINT tag_id_fk FOREIGN KEY (tag_id)
		REFERENCES tag_data.tags(tag_id)
		ON DELETE NO ACTION
		ON UPDATE NO ACTION
	);
