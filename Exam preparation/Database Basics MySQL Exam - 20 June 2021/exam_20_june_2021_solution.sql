# 1 Table Design

create table `addresses`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(100) not null
);

create table `categories`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(10) not null
);

create table `clients`
(
    `id`           int auto_increment
        primary key,
    `full_name`    varchar(50) not null,
    `phone_number` varchar(20) not null
);

create table `drivers`
(
    `id`         int auto_increment
        primary key,
    `first_name` varchar(30)       not null,
    `last_name`  varchar(30)       not null,
    `age`        int               not null,
    `rating`     float default 5.5 null
);

create table `cars`
(
    `id`          int auto_increment
        primary key,
    `make`        varchar(20)   not null,
    `model`       varchar(20)   null,
    `year`        int default 0 not null,
    `mileage`     int default 0 null,
    `condition`   char          not null,
    `category_id` int           not null,
    constraint `cars_categories_null_fk`
        foreign key (`category_id`) references `categories` (`id`)
);

create table `courses`
(
    `id`              int auto_increment
        primary key,
    `from_address_id` int                       not null,
    `start`           datetime                  not null,
    `bill`            decimal(10, 2) default 10 null,
    `car_id`          int                       not null,
    `client_id`       int                       not null,
    constraint `courses_addresses_null_fk`
        foreign key (`from_address_id`) references `addresses` (`id`),
    constraint `courses_cars_null_fk`
        foreign key (`car_id`) references `cars` (`id`),
    constraint `courses_clients_null_fk`
        foreign key (`client_id`) references `clients` (`id`)
);

create table `cars_drivers`
(
    `car_id`    int not null,
    `driver_id` int not null,
    primary key (`car_id`, `driver_id`),
    constraint `cars_drivers_cars_null_fk`
        foreign key (`car_id`) references `cars` (`id`),
    constraint `cars_drivers_drivers_null_fk`
        foreign key (`driver_id`) references `drivers` (`id`)
);

# 2 Insert

INSERT INTO `clients`(`full_name`, `phone_number`)
SELECT CONCAT(`first_name`, ' ', `last_name`),
       CONCAT('(088) 9999', `id` * 2)
FROM `drivers`
WHERE `id` BETWEEN 10 AND 20;

# 3 Update

UPDATE `cars`
SET `condition` = 'C'
WHERE (`mileage` >= 800000
    OR `mileage` IS NULL)
  AND `year` <= 2010
  AND `make` NOT IN ('Mercedes-Benz');

# 4 Delete

DELETE `clients`
FROM `clients`
         LEFT JOIN `courses` ON `clients`.`id` = `courses`.`client_id`
WHERE `courses`.`id` IS NULL
  AND LENGTH(`full_name`) > 3;

# 5 Cars

SELECT `make`, `model`, `condition`
FROM `cars`
ORDER BY `id`;

# 6 Drivers and Cars

SELECT `first_name`, `last_name`, `make`, `model`, `mileage`
FROM `drivers`
         INNER JOIN `cars_drivers` `cd` on `drivers`.`id` = `cd`.`driver_id`
         INNER JOIN `cars` ON `cd`.`car_id` = `cars`.`id`
WHERE `mileage` IS NOT NULL
ORDER BY `mileage` DESC, `first_name`;

# 7 Number of courses for each car

SELECT `c`.`id`              AS 'car_id',
       `make`,
       `mileage`,
       COUNT(`courses`.`id`) AS 'count_of_courses',
       ROUND(AVG(`bill`), 2) AS 'avg_bill'
FROM `cars` `c`
         LEFT JOIN `courses` ON `c`.`id` = `courses`.`car_id`
GROUP BY `c`.`id`
HAVING `count_of_courses` <> 2
ORDER BY `count_of_courses` DESC, `c`.`id`;

# 8 Regular clients

SELECT `full_name` AS `full_name`, COUNT(`cars`.`id`) AS `count_of_cars`, SUM(`bill`) AS `total_sum`
FROM `clients`
         INNER JOIN `courses` ON `clients`.`id` = `courses`.`client_id`
         INNER JOIN `cars` ON `courses`.`car_id` = `cars`.`id`
WHERE SUBSTR(`full_name`, 2, 1) LIKE 'a'
GROUP BY `full_name`
HAVING `count_of_cars` > 1
ORDER BY `full_name`;

# 9 Full info for courses

SELECT `addresses`.`name`,
       (IF(HOUR(`start`) BETWEEN 6 AND 20, 'Day', 'Night')) AS 'day_time',
       `bill`,
       `clients`.`full_name`,
       `make`,
       `model`,
       `categories`.`name`                                  AS 'category_name'
FROM `courses`
         INNER JOIN `addresses` ON `courses`.`from_address_id` = `addresses`.`id`
         INNER JOIN `clients` ON `courses`.`client_id` = `clients`.`id`
         INNER JOIN `cars` ON `courses`.`car_id` = `cars`.`id`
         INNER JOIN `categories` ON `cars`.`category_id` = `categories`.`id`
ORDER BY `courses`.`id`;

# 10 Find all courses by client’s phone number

CREATE FUNCTION `udf_courses_by_client`(`phone_num` VARCHAR(20))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `count` INT;
    SET `count` := (SELECT COUNT(`courses`.`id`) AS 'count'
                    FROM `courses`
                             INNER JOIN `clients` `c` on `courses`.`client_id` = `c`.`id`
                    WHERE `phone_number` LIKE `phone_num`);
    RETURN `count`;
END;

# 11 Full info for address

CREATE PROCEDURE `udp_courses_by_address`(`address_name` VARCHAR(100))
BEGIN
    SELECT `a`.`name`,
           `full_name`,
           (CASE
                WHEN `bill` <= 20 THEN 'Low'
                WHEN `bill` <= 30 THEN 'Medium'
                ELSE 'High'
               END
               )       AS 'level_of_bill',
           `make`,
           `condition`,
           `c3`.`name` AS 'cat_name'
    FROM `clients`
             INNER JOIN `courses` `c`
                        on `clients`.`id` = `c`.`client_id`
             INNER JOIN `addresses` `a` on `c`.`from_address_id` = `a`.`id`
             INNER JOIN `cars` `c2` on `c`.`car_id` = `c2`.`id`
             INNER JOIN `categories` `c3` on `c2`.`category_id` = `c3`.`id`
    WHERE `a`.`name` LIKE `address_name`
    ORDER BY `make`, `full_name`;
END;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');