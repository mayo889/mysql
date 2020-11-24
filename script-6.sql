USE vk;

-- Задание 1. Создать и заполнить таблицы лайков и постов

-- Таблица лайков
DROP TABLE IF EXISTS likes;
CREATE TABLE likes (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  target_id INT UNSIGNED NOT NULL,
  target_type_id INT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Таблица типов лайков
DROP TABLE IF EXISTS target_types;
CREATE TABLE target_types (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL UNIQUE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO target_types (name) VALUES 
  ('messages'),
  ('users'),
  ('media'),
  ('posts');

-- Заполняем лайки
INSERT INTO likes 
  SELECT 
    id, 
    FLOOR(1 + (RAND() * 100)), 
    FLOOR(1 + (RAND() * 100)),
    FLOOR(1 + (RAND() * 4)),
    CURRENT_TIMESTAMP 
  FROM messages;

-- Создадим таблицу постов
DROP TABLE IF EXISTS posts;
CREATE TABLE posts (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  community_id INT UNSIGNED,
  head VARCHAR(255),
  body TEXT NOT NULL,
  media_id INT UNSIGNED,
  is_public BOOLEAN DEFAULT TRUE,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Заполняем таблицу постов
-- с помощью фейкера. Код в отдельном файле fill_posts.sql, чтобы не перегружать визуально этот скрипт


-- Задание 2. Создать все необходимые внешние ключи и диаграмму отношений.

ALTER TABLE profiles
  ADD CONSTRAINT profiles_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

ALTER TABLE messages
  ADD CONSTRAINT messages_from_user_id_fk
  	FOREIGN KEY (from_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_to_user_id_fk
  	FOREIGN KEY (to_user_id) REFERENCES users(id),
  ADD CONSTRAINT messages_media_id_fk
  	FOREIGN KEY (media_id) REFERENCES media(id);

ALTER TABLE communities_users
  ADD CONSTRAINT communities_users_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT communities_users_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE;

ALTER TABLE friendship
  ADD CONSTRAINT friendship_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT friendship_friend_id_fk
    FOREIGN KEY (friend_id) REFERENCES users(id)
      ON DELETE CASCADE,
  ADD CONSTRAINT friendship_status_id_fk
  	FOREIGN KEY (status_id) REFERENCES friendship_statuses(id);

ALTER TABLE media
  ADD CONSTRAINT media_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT media_media_type_id_fk
    FOREIGN KEY (media_type_id) REFERENCES media_types(id);
    
UPDATE posts SET updated_at = NOW() WHERE updated_at < created_at;
ALTER TABLE posts
  ADD CONSTRAINT posts_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT posts_community_id_fk
    FOREIGN KEY (community_id) REFERENCES communities(id),
  ADD CONSTRAINT posts_media_id_fk
    FOREIGN KEY (media_id) REFERENCES media(id);
  
ALTER TABLE likes
  ADD CONSTRAINT likes_user_id_fk
    FOREIGN KEY (user_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_id_fk
    FOREIGN KEY (target_id) REFERENCES users(id),
  ADD CONSTRAINT likes_target_type_id_fk
    FOREIGN KEY (target_type_id) REFERENCES target_types(id);

   
-- Задание 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?   

SELECT
  COUNT(*) as total,
  (SELECT gender FROM profiles WHERE likes.user_id = profiles.user_id) AS gender
FROM likes
GROUP BY gender
ORDER BY total DESC
LIMIT 1;

-- Задание 4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

SELECT
  SUM(likes_10_youngest.number_likes) as total
FROM (
  SELECT
    COUNT(*) as number_likes,
    ANY_VALUE((SELECT TIMESTAMPDIFF(YEAR, birthday, NOW()) FROM profiles WHERE likes.target_id = profiles.user_id)) AS age
  FROM likes
  GROUP BY target_id
  ORDER BY age
  LIMIT 10) AS likes_10_youngest;


-- Задание 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

-- Перечисленные критерии активности суммируются. Пользователи с наименьшими суммами являются менее активными
--   кол-во созданных постов
--   кол-во отправленных сообщений
--   кол-во поставленных лайков
--   кол-во загруженных медиа файлов
--   кол-во сообществ, в которых пользователь состоит

SELECT
	activities.full_name,
	(activities.number_posts + activities.number_messages + activities.number_likes + activities.number_files + activities.number_communities + activities.number_friends) AS activity
FROM (
  SELECT
	  CONCAT(first_name, ' ', last_name) AS full_name,
	  (SELECT COUNT(*) FROM posts WHERE users.id = posts.user_id) AS number_posts,
	  (SELECT COUNT(*) FROM messages WHERE users.id = messages.from_user_id) AS number_messages,
	  (SELECT COUNT(*) FROM likes WHERE users.id = likes.user_id) AS number_likes,
	  (SELECT COUNT(*) FROM media WHERE users.id = media.user_id) AS number_files,
	  (SELECT COUNT(*) FROM communities_users WHERE users.id = communities_users.user_id) AS number_communities,
	  (SELECT COUNT(*) FROM friendship WHERE (users.id = friendship.user_id OR users.id = friendship.friend_id) AND
	      status_id = (SELECT id FROM friendship_statuses WHERE name = 'confirmed')) as number_friends
  FROM users
  ORDER BY id) AS activities
ORDER BY activity
LIMIT 10;
