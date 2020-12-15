-- Задание 1. Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products
-- в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.

DROP TABLE IF EXISTS logs;
CREATE TABLE logs (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT UNIQUE,
  table_name CHAR(10),
  primary_key_id INT UNSIGNED NOT NULL,
  name VARCHAR(255),
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP 
) ENGINE=Archive;

DELIMITER //

DROP TRIGGER IF EXISTS users_insert_logs//
CREATE TRIGGER users_insert_logs AFTER INSERT ON users
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key_id, name) VALUES
    ('users', NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS catalogs_insert_logs//
CREATE TRIGGER catalogs_insert_logs AFTER INSERT ON catalogs
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key_id, name) VALUES
    ('catalogs', NEW.id, NEW.name);
END//

DROP TRIGGER IF EXISTS products_insert_logs//
CREATE TRIGGER products_insert_logs AFTER INSERT ON products
FOR EACH ROW
BEGIN
  INSERT INTO logs (table_name, primary_key_id, name) VALUES
    ('products', NEW.id, NEW.name);
END//

DELIMITER ;

-- Задание 2. (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.

DELIMITER //

DROP FUNCTION IF EXISTS create_name//
CREATE FUNCTION create_name ()
RETURNS TEXT NO SQL
BEGIN
  DECLARE i, len TINYINT;
  DECLARE capital_letter, small_letter CHAR(30);
  SET i = 0;
  SET len = FLOOR(RAND() * 6 + 3);
  SET capital_letter = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  SET small_letter = 'abcdefghijklmnopqrstuvwxyz';
  SET @name = SUBSTRING(capital_letter, FLOOR(RAND() * 26 + 1), 1);
  WHILE i != len DO
    SET @name = CONCAT(@name, SUBSTRING(small_letter, FLOOR(RAND() * 26 + 1), 1));
    SET i = i + 1;
  END WHILE;    
  RETURN @name;
END//

DROP PROCEDURE IF EXISTS users_insert_million//
CREATE PROCEDURE users_insert_million ()
BEGIN
  DECLARE i INT UNSIGNED DEFAULT 0;
  WHILE i != 1000000 DO
    INSERT INTO users (name, birthday_at) VALUES (
      (SELECT create_name()),
      (DATE_FORMAT(FROM_UNIXTIME(FLOOR(RAND() * UNIX_TIMESTAMP(NOW()))), '%Y-%m-%d')));
    SET i = i + 1;
  END WHILE;
END//

DELIMITER ;

CALL users_insert_million();
