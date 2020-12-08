-- Тема “Транзакции, переменные, представления”

-- Задание 1. В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных.
-- Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.

START TRANSACTION;
INSERT INTO sample.users
  SELECT * FROM shop.users WHERE id = 1;
DELETE FROM shop.users WHERE id = 1;
COMMIT;

-- Задание 2. Создайте представление, которое выводит название name товарной позиции из таблицы products и
-- соответствующее название каталога name из таблицы catalogs.

CREATE VIEW products_with_catalogs AS
  SELECT products.name AS name, catalogs.name AS `type`
    FROM
      products
      JOIN catalogs 
        ON products.catalog_id = catalogs.id;

SELECT * FROM products_with_catalogs;

-- Задание 3. (По желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года
-- '2018-08-01', '2018-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август,
-- выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.

DROP TABLE IF EXISTS august;
CREATE TABLE august (`day` DATE);
INSERT INTO august VALUES ('2018-08-01'), ('2018-08-04'), ('2018-08-16'), ('2018-08-17');

DROP TABLE IF EXISTS all_days_august;
CREATE TEMPORARY TABLE all_days_august (`day` DATE);

DELIMITER //

CREATE PROCEDURE fill_august ()
BEGIN
	DECLARE `day` DATE DEFAULT '2018-08-01';
	WHILE `day` != '2018-09-01' DO
		INSERT INTO all_days_august (`day`) VALUES (`day`);
		SET `day` = `day` + INTERVAL 1 DAY;
	END WHILE;
END//

DELIMITER ;

CALL fill_august();

SELECT
  `day`,
  `day` IN (SELECT `day` FROM august) AS presence
  FROM all_days_august;

-- Задание 4. (по желанию) Пусть имеется любая таблица с календарным полем created_at.
-- Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.

DROP TABLE IF EXISTS task4;
CREATE TABLE task4 (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  created_at DATE
);

INSERT INTO task4 (created_at) VALUES ('2020-01-01'), ('2020-02-01'), ('2020-03-01'), ('2020-04-01'), ('2020-05-01'), ('2020-06-01'),
                                      ('2020-07-01'), ('2020-08-01'), ('2020-09-01'), ('2020-10-01'), ('2020-11-01'), ('2020-12-01');

DELETE task4
  FROM task4
    LEFT JOIN (SELECT *
          FROM task4
          ORDER BY created_at DESC
          LIMIT 5) AS extra
      ON task4.created_at = extra.created_at
  WHERE extra.created_at IS NULL;

SELECT * FROM task4;


-- Тема “Хранимые процедуры и функции, триггеры"

-- Задание 1. Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток.
-- С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день",
-- с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".

DELIMITER //

DROP FUNCTION IF EXISTS hello//

CREATE FUNCTION hello ()
RETURNS TEXT NO SQL
BEGIN
	DECLARE `time` TIME DEFAULT TIME(NOW());
	CASE
		WHEN `time` BETWEEN '06-00' AND '12-00' THEN
		  RETURN 'Доброе утро';
		WHEN `time` BETWEEN '12-00' AND '18-00' THEN
		  RETURN 'Добрый день';
		WHEN `time` BETWEEN '18-00' AND '00-00' THEN
		  RETURN 'Добрый вечер';
		ELSE
		  RETURN 'Доброй ночи';
	END CASE;
END//

DELIMITER ;

SELECT hello();

-- Задание 2. В таблице products есть два текстовых поля: name с названием товара и description с его описанием.
-- Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема.
-- Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены.
-- При попытке присвоить полям NULL-значение необходимо отменить операцию.

DELIMITER //

DROP TRIGGER IF EXISTS check_not_null_products_insert//
CREATE TRIGGER check_not_null_products_insert BEFORE INSERT ON products
FOR EACH ROW
BEGIN
  IF (NEW.name IS NULL AND NEW.description IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
  END IF;
END//

DROP TRIGGER IF EXISTS check_not_null_products_update//
CREATE TRIGGER check_not_null_products_update BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
  IF (NEW.name IS NULL AND NEW.description IS NULL) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE canceled';
  END IF;
END//

DELIMITER ;

-- Задание 3. (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи.
-- Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел.
-- Вызов функции FIBONACCI(10) должен возвращать число 55.

DELIMITER //

DROP FUNCTION IF EXISTS FIBONACCI//

CREATE FUNCTION FIBONACCI (num INT)
RETURNS INT NO SQL
BEGIN
  DECLARE prev, cur INT;
  SET prev = 0;
  SET cur = 1;
 
  IF (num < 2) THEN
    RETURN num;
  END IF;
 
  WHILE num > 1 DO
    SET cur = prev + cur;
    SET prev = cur - prev;
    SET num = num - 1;
  END WHILE;
 
  RETURN cur;
END//

DELIMITER ;

SELECT FIBONACCI(10);


-- Тема “Администрирование MySQL”

-- Задание 1. Создайте двух пользователей которые имеют доступ к базе данных shop.
-- Первому пользователю shop_read должны быть доступны только запросы на чтение данных,
-- второму пользователю shop — любые операции в пределах базы данных shop.

CREATE USER 'shop_1'@'localhost' IDENTIFIED WITH sha256_password BY 'pass_1';
CREATE USER 'shop_2'@'localhost' IDENTIFIED WITH sha256_password BY 'pass_2';

GRANT SELECT ON shop.* TO 'shop_1'@'localhost';
GRANT ALL ON shop.* TO 'shop_2'@'localhost';

-- Задание 2. (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль.
-- Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name.
-- Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.

DROP TABLE IF EXISTS accounts;
CREATE TABLE accounts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE PRIMARY KEY,
  name VARCHAR(50),
  password VARCHAR(50)
);

INSERT INTO accounts (name, password) VALUES
  ('Petr', 'qwerty'),
  ('Igor', 'asdfg'),
  ('Dima', 'zxcvb');
  
CREATE VIEW username AS SELECT id, name FROM accounts;

CREATE USER 'user_read'@'localhost' IDENTIFIED WITH sha256_password BY 'pass_1';
GRANT SELECT ON shop.username TO 'user_read'@'localhost';
