-- Задание 1. Проанализировать какие запросы могут выполняться наиболее
-- часто в процессе работы приложения и добавить необходимые индексы.

CREATE INDEX users_first_name_last_name_idx ON users(first_name, last_name);

CREATE INDEX profiles_birthday_idx ON profiles(birthday);
CREATE INDEX profiles_city_idx ON profiles(city);
CREATE INDEX profiles_country_idx ON profiles(country);

CREATE INDEX friendship_user_id_friend_id_idx ON friendship(user_id, friend_id);

CREATE INDEX messages_from_user_id_to_user_id_idx ON messages (from_user_id, to_user_id);

CREATE INDEX media_filename_idx ON media(filename);
CREATE INDEX media_size_idx ON media(size);

CREATE INDEX communities_users_user_id_community_idx ON communities_users(user_id, community_id);

CREATE INDEX posts_head_idx ON posts(head);

SHOW INDEX FROM users;
SHOW INDEX FROM profiles;
SHOW INDEX FROM friendship;
SHOW INDEX FROM messages;
SHOW INDEX FROM media;
SHOW INDEX FROM posts;
SHOW INDEX FROM communities;
SHOW INDEX FROM communities_users;
SHOW INDEX FROM likes;

-- Задание 2. Задание на оконные функции
-- Построить запрос, который будет выводить следующие столбцы:
--   имя группы;
--   среднее количество пользователей в группах;
--   самый молодой пользователь в группе;
--   самый старший пользователь в группе;
--   общее количество пользователей в группе;
--   всего пользователей в системе;
--   отношение в процентах (общее количество пользователей в группе / всего пользователей в системе) * 100.
    
SELECT DISTINCT
  communities.name AS name_of_community,
  COUNT(*) OVER() / (SELECT COUNT(*) FROM communities) AS average_number_users_in_community,
  FIRST_VALUE(CONCAT(users.first_name, ' ', users.last_name)) OVER(PARTITION BY communities.id ORDER BY profiles.birthday DESC) AS yongest_user,
  FIRST_VALUE(CONCAT(users.first_name, ' ', users.last_name)) OVER(PARTITION BY communities.id ORDER BY profiles.birthday) AS oldest_user,
  COUNT(*) OVER w AS users_in_the_community,
  (SELECT COUNT(*) FROM users) AS total__users,
  COUNT(*) OVER w / (SELECT COUNT(*) FROM users) * 100 AS '%'
  FROM communities
    JOIN communities_users
      ON communities.id = communities_users.community_id
    JOIN profiles
      ON communities_users.user_id = profiles.user_id
    JOIN users
      ON profiles.user_id = users.id
  WINDOW w AS (PARTITION BY communities.id);
