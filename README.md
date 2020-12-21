# mysql
Курсовая работа
База данных (прототип сайт https://www.kinopoisk.ru/)

Было создано 15 таблиц, 4 из которых являются малыми справочниками (media_types, genres, professions, reviews).

В базе данных хранится следующая информация:
  1. Пользователи, зарегистрировавшиеся на сайте (users, profiles);
  2. Взаимоотношения между пользователями (friendship). Статус отношений не вынесен в отдельную справочную таблицу, так как вводить новые статусы взаимоотношений        не планируется в будущем.
      - Каждый пользователь может подписаться на другого (friendship.status = subscription)
      - Если другой пользователь подпишется в ответ, то пользователи начинают дружить (friendship.status = confirmed)
  3. Фильмы (movies, about_movies). Жанры фильмов перечислены в справочной таблице genres;
  4. Звезды: актеры, режиссеры, сценаристы и продюссеры.
      - Личная информация о звездах хранится в таблице stars
      - Их профессии описаны в справочной таблице professions
      - В таблице stars_movies содержится информация о том, в создании каких фильмов принимали участие звезды
  5. Рецензии (reviews). Каждый пользователь может написать рецензию к фильму.
  6. Комментарии к рецензиям (comments). Каждый пользователь может написать комментарий к рецензии.
  7. Поставленные оценки (raitings). Пользователь может оценить три сущности. Типы сущностей перечислены в справочной таблице (target_types)
      - Оценка фильма (от 1 до 10)
      - Оценка рецензии (-1 или 1)
      - Оценка комментария к рецензии (-1 или 1)
    Важно, что пользователь может изменить свою оценку.
  8. Медиа файлы (media). Есть 3 типа медиа файлов, которые перечислены в справочной таблице (media_types)
      - Фотографии профиля пользователей или звезд
      - Фотографии постеров к фильмам
      - Видео трейлеров к фильмам
      
Создано 4 представления, в которых подсчитыватся актуальные оценки:
    - Для фильмов это среднее арифмитическое оценок.
    - Для рецензий и комментариев это сумма оценок. Рейтинг рецензии или комментария может быть отрицательным.
    - Для звезд рейтинг это среднее арифмитическое оценок фильмов, в создании которых он принимал участие.

Создано 4 функции, которые обновляют столбец raiting для всех записей в таблицах movies, reviews, comments и stars.
    Функции берут информацию из представлений.

Создано событие, которое каждый час запускает 4 функции. Это сделано с целью, чтобы уменьшить нагрузку на базу данных и не пересчитывать рейтинги после появляения каждой новой записи или после обновления какой-либо записи.

Создана 2 триггера на вставку и обновления записей в таблице raiting. Их задача:
    - Отклонять запрос, если новая оценка не попадает в заданный диапазон: для фильмов от 1 до 10, а для рецензий или комментариев от 1 до 10.
    - Отклонять запрос, если оценка ставится не существующей записи в таблице movies, reviews или comments.

Описание загруженных файлов:
  1. tables.sql - Структура БД
  2. keys_indexes.sql - Внешние ключи и индексы БД
  3. ERDiagram.png - ERDiagram для БД
  4. filling_DB.sql - Заполнение БД с помощью фейкера
  5. correction_data.sql - Исправление неправильно внесенных данных
  6. triggers_procedures_views.sql - Триггеры, представления и процедуры
  7. shedule_event_update.sql - Создание события, которое запускает процедуры
  8. samples.sql - Характерные выборки (включающие группировки, JOIN'ы, вложенные таблицы)
  9. final_dump_kinopoisk.sql - Дамп БД
