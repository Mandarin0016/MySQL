# 1 Table Design

create table `countries`
(
    `id`        int auto_increment
        primary key,
    `name`      varchar(30) not null,
    `continent` varchar(30) not null,
    `currency`  VARCHAR(5)  not null,
    constraint `countries_pk`
        unique (`name`)
);

create table `actors`
(
    `id`         int auto_increment
        primary key,
    `first_name` varchar(50) not null,
    `last_name`  varchar(50) not null,
    `birthdate`  date        not null,
    `height`     int         null,
    `awards`     int         null,
    `country_id` int         not null,
    constraint `actors_countries_null_fk`
        foreign key (`country_id`) references `countries` (`id`)
);

create table `genres`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(50) not null,
    constraint `genres_pk`
        unique (`name`)
);

create table `movies_additional_info`
(
    `id`            int            not null
        primary key,
    `rating`        decimal(10, 2) not null,
    `runtime`       int            not null,
    `picture_url`   varchar(80)    not null,
    `budget`        decimal(10, 2) null,
    `release_date`  date           not null,
    `has_subtitles` TINYINT(1)     null,
    `description`   TEXT           null
);

create table `movies`
(
    `id`            int auto_increment
        primary key,
    `title`         varchar(70) not null,
    `country_id`    int         not null,
    `movie_info_id` int         not null,
    constraint `movies_pk`
        unique (`title`),
    constraint unique (`movie_info_id`),
    constraint `movies_countries_null_fk`
        foreign key (`country_id`) references `countries` (`id`),
    constraint `movies_movies_additional_info_null_fk`
        foreign key (`movie_info_id`) references `movies_additional_info` (`id`)
);

create table `genres_movies`
(
    `genre_id` int null,
    `movie_id` int null,
    constraint `genres_movies_genres_null_fk`
        foreign key (`genre_id`) references `genres` (`id`),
    constraint `genres_movies_movies_null_fk`
        foreign key (`movie_id`) references `movies` (`id`)
);

create table `movies_actors`
(
    `movie_id` int null,
    `actor_id` int null,
    constraint `movies_actors_actors_null_fk`
        foreign key (`actor_id`) references `actors` (`id`),
    constraint `movies_actors_movies_null_fk`
        foreign key (`movie_id`) references `movies` (`id`)
);


# 2 Insert

INSERT INTO `actors`(`first_name`, `last_name`, `birthdate`, `height`, `awards`, `country_id`)
SELECT REVERSE(`first_name`),
       REVERSE(`last_name`),
       DATE_SUB(`birthdate`, INTERVAL 2 DAY),
       `height` + 10,
       `country_id`,
       (SELECT `id`
        FROM `countries`
        WHERE `name` = 'Armenia')
FROM `actors`
WHERE `actors`.`id` <= 10;

# 3 Update

UPDATE `movies_additional_info`
SET `runtime` = `runtime` - 10
WHERE `movies_additional_info`.`id` BETWEEN 15 AND 25;

# 4 Delete

DELETE `countries`
FROM `countries`
         LEFT JOIN `movies`
                   ON `countries`.`id` = `movies`.`country_id`
WHERE `movies`.`id` IS NULL;

# 5 Countries

SELECT `id`, `name`, `continent`, `currency`
FROM `countries`
ORDER BY `currency` DESC, `id`;

# 6 Old movies

SELECT `m`.`id`, `m`.`title`, `runtime`, `budget`, `release_date`
FROM `movies_additional_info`
         INNER JOIN `movies` `m` on `movies_additional_info`.`id` = `m`.`movie_info_id`
WHERE YEAR(`release_date`) BETWEEN 1996 AND 1999
ORDER BY `runtime`, `id`
LIMIT 20;

# 7 Movie casting

SELECT CONCAT(`first_name`, ' ', `last_name`)                           AS 'full_name',
       (CONCAT(REVERSE(`last_name`), LENGTH(`last_name`), '@cast.com')) AS `email`,
       (2022 - YEAR(`birthdate`))                                       AS `age`,
       `height`

FROM `actors`
         LEFT JOIN `movies_actors` `ma` ON `actors`.`id` = `ma`.`actor_id`
WHERE `ma`.`movie_id` IS NULL
ORDER BY `height`;

# 8 International festival

SELECT `name`, COUNT(`movies`.`id`) AS `movies_count`
FROM `countries`
         LEFT JOIN `movies` ON `countries`.`id` = `movies`.`country_id`
GROUP BY `name`
HAVING `movies_count` >= 7
ORDER BY `name` DESC;

# 9 Rating system

SELECT `title`,
       (
           CASE
               WHEN `mai`.`rating` <= 4 THEN 'poor'
               WHEN `mai`.`rating` <= 7 THEN 'good'
               WHEN `mai`.`rating` > 7 THEN 'excellent'
               ELSE 'poor'
               END)                                  AS `rating`,
       (IF(`has_subtitles` IS TRUE, 'english', '-')) AS 'subtitles',
       `budget`
FROM `movies`
         INNER JOIN `movies_additional_info` `mai` ON `movies`.`movie_info_id` = `mai`.`id`
ORDER BY `budget` DESC;

# 10 History movies

CREATE FUNCTION `udf_actor_history_movies_count`(`full_name` VARCHAR(50))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `history_movies` INT;
    SET `history_movies` := (SELECT COUNT(`movies`.`id`) AS 'history_movies'
                             FROM `actors`
                                      INNER JOIN `movies_actors` ON `actors`.`id` = `movies_actors`.`actor_id`
                                      INNER JOIN `movies` ON `movies_actors`.`movie_id` = `movies`.`id`
                                      INNER JOIN `genres_movies` ON `movies`.`id` = `genres_movies`.`movie_id`
                                      INNER JOIN `genres` ON `genres_movies`.`genre_id` = `genres`.`id`
                             WHERE `genres`.`name` = 'History'
                               AND CONCAT(`first_name`, ' ', `last_name`) = `full_name`);
    RETURN `history_movies`;
END;

# 11 Movie awards

CREATE PROCEDURE `udp_award_movie`(`movie_title` VARCHAR(50))
BEGIN
    UPDATE `actors`
        INNER JOIN `movies_actors` ON `actors`.`id` = `movies_actors`.`actor_id`
        INNER JOIN `movies` ON `movies_actors`.`movie_id` = `movies`.`id`
    SET `awards` = `awards` + 1
    WHERE `title` = `movie_title`;
END;






