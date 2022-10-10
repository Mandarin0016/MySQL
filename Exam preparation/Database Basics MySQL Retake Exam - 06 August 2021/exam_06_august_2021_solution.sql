# 1 Table Design

create table `addresses`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(50) not null
);

create table `categories`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(10) not null
);

create table `offices`
(
    `id`                 int auto_increment
        primary key,
    `workspace_capacity` int         not null,
    `website`            varchar(50) null,
    `address_id`         int         not null,
    constraint `offices_addresses_null_fk`
        foreign key (`address_id`) references `addresses` (`id`)
);

create table `employees`
(
    `id`              int auto_increment
        primary key,
    `first_name`      varchar(30)    not null,
    `last_name`       varchar(30)    not null,
    `age`             int            not null,
    `salary`          decimal(10, 2) not null,
    `job_title`       varchar(20)    not null,
    `happiness_level` char           not null
);

create table `teams`
(
    `id`        int auto_increment
        primary key,
    `name`      varchar(40) not null,
    `office_id` int         not null,
    `leader_id` int         not null,
    constraint `teams_pk`
        unique (`leader_id`),
    constraint `teams_employees_null_fk`
        foreign key (`leader_id`) references `employees` (`id`),
    constraint `teams_offices_null_fk`
        foreign key (`office_id`) references `offices` (`id`)
);

create table `games`
(
    `id`           int auto_increment
        primary key,
    `name`         varchar(50)       not null,
    `description`  text              null,
    `rating`       float default 5.5 not null,
    `budget`       decimal(10, 2)    not null,
    `release_date` date              null,
    `team_id`      int               not null,
    constraint `games_pk`
        unique (`name`),
    constraint `games_teams_null_fk`
        foreign key (`team_id`) references `teams` (`id`)
);

create table `games_categories`
(
    `game_id`     int not null,
    `category_id` int not null,
    primary key (`game_id`, `category_id`)
);

# 2 Insert

INSERT INTO `games`(`name`, `rating`, `budget`, `team_id`)
SELECT REVERSE(LOWER(SUBSTRING(`name`, 2))),
       `id`,
       `leader_id` * 1000,
       `id`
FROM `teams`
WHERE `id` BETWEEN 1 AND 9;

# 3 Update

UPDATE `employees`
    INNER JOIN `teams` ON `employees`.`id` = `teams`.`leader_id`
SET `salary` = `salary` + 1000
WHERE `age` < 40
  AND `salary` < 5000;

# 4 Delete

DELETE `games`
FROM `games`
         LEFT JOIN `games_categories` ON `games`.`id` = `games_categories`.`game_id`
WHERE `release_date` IS NULL
  AND `category_id` IS NULL;

# 5 Employees

SELECT `first_name`, `last_name`, `age`, `salary`, `happiness_level`
FROM `employees`
ORDER BY `salary`, `id`;

# 6 Addresses of the teams

SELECT `t`.`name` AS 'team_name', `a`.`name` AS 'address_name', LENGTH(`a`.`name`) AS 'count_of_characters'
FROM `teams` `t`
         INNER JOIN `offices` `o` ON `t`.`office_id` = `o`.`id`
         INNER JOIN `addresses` `a` on `o`.`address_id` = `a`.`id`
WHERE `website` IS NOT NULL
ORDER BY `team_name`, `address_name`;

# 7 Categories Info

SELECT `categories`.`name`     AS 'name',
       COUNT(`games`.`id`)     AS 'games_count',
       ROUND(AVG(`budget`), 2) AS 'avg_budget ',
       MAX(`rating`)           AS 'max_rating'
FROM `games`
         INNER JOIN `games_categories` ON `games`.`id` = `games_categories`.`game_id`
         INNER JOIN `categories` ON `games_categories`.`category_id` = `categories`.`id`
GROUP BY `categories`.`name`
HAVING `max_rating` >= 9.5
ORDER BY `games_count` DESC, `name`;

# 8 Games of 2022

SELECT `games`.`name`,
       `release_date`,
       CONCAT(LEFT(`description`, 10), '...') AS 'summary',
       (
           CASE
               WHEN MONTH(`release_date`) IN (1, 2, 3) THEN 'Q1'
               WHEN MONTH(`release_date`) IN (4, 5, 6) THEN 'Q2'
               WHEN MONTH(`release_date`) IN (7, 8, 9) THEN 'Q3'
               ELSE 'Q4'
               END
           )                                  AS 'quarter',
       `t`.`name`
FROM `games`
         INNER JOIN `teams` `t` on `games`.`team_id` = `t`.`id`
WHERE YEAR(`release_date`) = 2022
  AND MOD(MONTH(`release_date`), 2) = 0
  AND `games`.`name` LIKE '%2'
ORDER BY `quarter`;

# 9 Full info for games

SELECT `games`.`name`                                               AS 'name',
       IF(`budget` < 50000, 'Normal budget', 'Insufficient budget') AS 'budget_level',
       `teams`.`name`                                               AS 'team_name',
       `addresses`.`name`                                           AS 'address_name '
FROM `games`
         INNER JOIN `teams` ON `games`.`team_id` = `teams`.`id`
         INNER JOIN `offices` ON `teams`.`office_id` = `offices`.`id`
         INNER JOIN `addresses` ON `offices`.`address_id` = `addresses`.`id`
         LEFT JOIN `games_categories` ON `games`.`id` = `games_categories`.`game_id`
WHERE `release_date` IS NULL
  AND `category_id` IS NULL
ORDER BY `name`;

# 10 Find all basic information for a game

CREATE FUNCTION `udf_game_info_by_name`(`game_name` VARCHAR(20))
    RETURNS TEXT
    DETERMINISTIC
BEGIN
    DECLARE `answer` TEXT;
    SET `answer` := (SELECT CONCAT('The ', `games`.`name`, ' is developed by a ', `teams`.`name`,
                                   ' in an office with an address ',
                                   `addresses`.`name`)
                     FROM `games`
                              INNER JOIN `teams` ON `games`.`team_id` = `teams`.`id`
                              INNER JOIN `offices` ON `teams`.`office_id` = `offices`.`id`
                              INNER JOIN `addresses` ON `offices`.`address_id` = `addresses`.`id`
                     WHERE `games`.`name` = `game_name`);
    RETURN `answer`;
END;

# 11 Update Budget of the Games

CREATE PROCEDURE `udp_update_budget`(`min_game_rating` FLOAT)
BEGIN
    UPDATE `games`
        LEFT JOIN `games_categories` `gc` on `games`.`id` = `gc`.`game_id`
    SET `budget`       = (`budget` + 100000),
        `release_date` = ADDDATE(`release_date`, INTERVAL 1 YEAR)
    WHERE `category_id` IS NULL
      AND `release_date` IS NOT NULL
      AND `rating` > `min_game_rating`;
END;
