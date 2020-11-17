USE vk;

SHOW TABLES;

SELECT * FROM users;
UPDATE users SET updated_at = NOW() WHERE created_at > updated_at;

SELECT * FROM profiles;
DESC profiles;
ALTER TABLE profiles MODIFY COLUMN gender ENUM('M', 'F') NOT NULL;
UPDATE profiles SET updated_at = NOW() WHERE created_at > updated_at;

SELECT * FROM messages;
DESC messages;
ALTER TABLE messages ADD COLUMN media_id INT UNSIGNED AFTER body;
UPDATE messages SET media_id = FLOOR(1 + RAND() * 100);

SELECT * FROM media;
UPDATE media SET updated_at = NOW() WHERE created_at > updated_at;
UPDATE media SET filename = CONCAT(
		'http://dropbox/vk/musics/',
		filename,
		'.',
		(SELECT name FROM extensions_music ORDER BY RAND() LIMIT 1))
	WHERE media_type_id = 1;
UPDATE media SET size = FLOOR(10000 + RAND() * 100000000) WHERE size < 10000;
UPDATE media SET metadata = CONCAT(
	'{"owner":"',
	(SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE media.user_id = users.id),
	'"}'
);

CREATE TEMPORARY TABLE extensions_photo(name VARCHAR(10));
INSERT INTO extensions_photo VALUES ('jpeg'), ('png');
CREATE TEMPORARY TABLE extensions_video(name VARCHAR(10));
INSERT INTO extensions_video VALUES ('mpg'), ('avi'), ('mov'), ('wmv');
CREATE TEMPORARY TABLE extensions_music(name VARCHAR(10));
INSERT INTO extensions_music VALUES ('mp3'), ('wav')

SELECT * FROM media_types;
UPDATE media_types SET updated_at = NOW() WHERE created_at > updated_at;

SELECT * FROM friendship;
ALTER TABLE friendship DROP COLUMN requested_at;
UPDATE friendship SET confirmed_at = NOW() WHERE status_id = 2 AND confirmed_at < created_at;
UPDATE friendship SET confirmed_at = NULL WHERE status_id != 2;


SELECT * FROM friendship_statuses;
UPDATE friendship_statuses SET updated_at = NOW() WHERE created_at > updated_at;

SELECT * FROM communities;
UPDATE communities SET updated_at = NOW() WHERE created_at > updated_at;

SELECT * FROM communities_users;






