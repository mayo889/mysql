-- Переписать запросы, заданые к ДЗ урока 6, с использованием JOIN

-- Удаление неправильного внешнего ключа
ALTER TABLE likes DROP FOREIGN KEY likes_target_id_fk;


-- Задание 3. Определить кто больше поставил лайков (всего) - мужчины или женщины?   

SELECT 
  COUNT(*) as total,
  profiles.gender
  FROM
    likes
    JOIN profiles
      ON profiles.user_id = likes.user_id
  GROUP BY gender
  ORDER BY total DESC
  LIMIT 1;

 
-- Задание 4. Подсчитать общее количество лайков десяти самым молодым пользователям (сколько лайков получили 10 самых молодых пользователей).

SELECT
  SUM(tbl.total_likes)
  FROM (
    SELECT
      profiles.user_id, profiles.birthday, COUNT(likes.id) as total_likes
    FROM profiles
      LEFT JOIN likes
        ON profiles.user_id = likes.target_id 
          AND target_type_id = 2
    GROUP BY profiles.user_id
    ORDER BY profiles.birthday DESC
    LIMIT 10) AS tbl;

   
-- Задание 5. Найти 10 пользователей, которые проявляют наименьшую активность в использовании социальной сети
-- (критерии активности необходимо определить самостоятельно).

-- Перечисленные критерии активности суммируются. Пользователи с наименьшими суммами являются менее активными
--   кол-во созданных постов
--   кол-во отправленных сообщений
--   кол-во поставленных лайков
--   кол-во загруженных медиа файлов
--   кол-во сообществ, в которых пользователь состоит
--   кол-во друзей
 
SELECT
  CONCAT(first_name, ' ', last_name) AS full_name,
  ( COUNT(DISTINCT(posts.id)) +
    COUNT(DISTINCT(messages.id)) + 
    COUNT(DISTINCT(likes.id)) + 
    COUNT(DISTINCT(media.id)) +
    COUNT(DISTINCT(communities_users.community_id)) +
    COUNT(DISTINCT(friendship.user_id))
  ) AS activity
  FROM users
    LEFT JOIN posts
      ON users.id = posts.user_id
    LEFT JOIN messages
      ON users.id = messages.from_user_id
    LEFT JOIN likes
      ON users.id = likes.user_id
    LEFT JOIN media
      ON users.id = media.user_id
    LEFT JOIN communities_users
      ON users.id = communities_users.user_id
    LEFT JOIN friendship
      ON (users.id = friendship.user_id
        OR users.id = friendship.friend_id)
        AND status_id = 2
  GROUP BY users.id
  ORDER BY activity, full_name
  LIMIT 10; 
