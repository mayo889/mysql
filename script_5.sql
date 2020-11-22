DROP DATABASE shop;
CREATE DATABASE shop;
USE shop;
SHOW TABLES;

-- Часть 1. Задание 1.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  birthday_at DATE,
  created_at DATETIME,
  updated_at DATETIME
);

INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', NULL, NULL),
  ('Наталья', '1984-11-12', NULL, NULL),
  ('Александр', '1985-05-20', NULL, NULL),
  ('Сергей', '1988-02-14', NULL, NULL),
  ('Иван', '1998-01-12', NULL, NULL),
  ('Мария', '1992-08-29', NULL, NULL);

DESC users;
SELECT * FROM users;
UPDATE users SET created_at = NOW(), updated_at = NOW();

-- Часть 1. Задание 2.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  birthday_at DATE,
  created_at VARCHAR(255),
  updated_at VARCHAR(255)
);

INSERT INTO
  users (name, birthday_at, created_at, updated_at)
VALUES
  ('Геннадий', '1990-10-05', '01.01.2020 12:00', '01.01.2020 12:00'),
  ('Наталья', '1984-11-12', '02.01.2020 12:00', '02.01.2020 12:00'),
  ('Александр', '1985-05-20', '03.01.2020 12:00', '03.01.2020 12:00'),
  ('Сергей', '1988-02-14', '04.01.2020 12:00', '04.01.2020 12:00'),
  ('Иван', '1998-01-12', '05.01.2020 12:00', '05.01.2020 12:00'),
  ('Мария', '1992-08-29', '06.01.2020 12:00', '06.01.2020 12:00');

DESC users;
SELECT * FROM users;
UPDATE users SET
	created_at = STR_TO_DATE(created_at, '%d.%m.%Y %H:%i'),
	updated_at = STR_TO_DATE(updated_at, '%d.%m.%Y %H:%i');
ALTER TABLE users MODIFY COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE users MODIFY COLUMN updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP;

-- Часть 1. Задание 3.
DROP TABLE IF EXISTS storehouses_products;
CREATE TABLE storehouses_products (
  id SERIAL PRIMARY KEY,
  storehouse_id INT UNSIGNED,
  product_id INT UNSIGNED,
  value INT UNSIGNED COMMENT 'Запас товарной позиции на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) COMMENT = 'Запасы на складе';

INSERT INTO storehouses_products (storehouse_id, product_id, value) VALUES
	(1, 1, 10),
	(1, 2, 5),
	(1, 3, 0),
	(1, 4, 15),
	(1, 5, 0);

DESC storehouses_products;
SELECT * FROM storehouses_products ORDER BY IF (value > 0, 0, 1), value;

-- Часть 1. Задание 4.
DROP TABLE IF EXISTS users;
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255),
  birthday_at DATE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)
	
INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-10-05'),
  ('Александр', '1985-05-20'),
  ('Сергей', '1988-02-14'),
  ('Иван', '1998-01-12'),
  ('Мария', '1992-08-29');

DESC users;
SELECT * FROM users WHERE MONTHNAME(birthday_at) IN ('may', 'august'); 
SELECT * FROM users WHERE DATE_FORMAT(birthday_at, '%M') IN ('may', 'august');
SELECT * FROM users WHERE birthday_at LIKE '_____05%' OR birthday_at LIKE '_____08%';
SELECT * FROM users WHERE birthday_at RLIKE '^[[:digit:]]{4}-(05|08)-[[:digit:]]{2}';

-- Часть 1. Задание 5
DROP TABLE IF EXISTS catalogs;
CREATE TABLE catalogs (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE
);

INSERT INTO catalogs (name) VALUES
  ('Процессоры'),
  ('Материнские платы'),
  ('Видеокарты'),
  ('Жесткие диски'),
  ('Оперативная память');

DESC catalogs;
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY
	IF (id = 5, 0, 1),
	IF (id = 1, 0, 1),
	IF (id = 2, 0, 1);
SELECT * FROM catalogs WHERE id IN (5, 1, 2) ORDER BY FIELD(id, 5, 1, 2);

-- Часть 2. Задание 1.
DESC users;
SELECT * FROM users;
SELECT
	AVG(
		(YEAR(NOW()) - YEAR(birthday_at)) -
		(DATE_FORMAT(birthday_at,'%m%d') > DATE_FORMAT(NOW(), '%m%d'))
	) AS avg_age
FROM
	users;
SELECT AVG(TIMESTAMPDIFF(YEAR, birthday_at, NOW())) as avg_age FROM users;

-- Часть 2. Задание 2.
INSERT INTO users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-10-05'),
  ('Александр', '1985-05-20');

SELECT
	COUNT(*) as total,
	DATE_FORMAT(CONCAT(YEAR(NOW()), '-', MONTH(birthday_at), '-', DAY(birthday_at)) , '%W') as weekday
FROM
	users
GROUP BY
	weekday

-- Часть 2. Задание 3.
DROP TABLE IF EXISTS product_numbers;
CREATE TABLE product_numbers (
	id SERIAL PRIMARY KEY,
	value BIGINT
);
INSERT INTO product_numbers (value) VALUES (1), (2), (4), (8), (16);
SELECT ROUND(EXP(SUM(LN(value)))) AS product FROM product_numbers;

 
