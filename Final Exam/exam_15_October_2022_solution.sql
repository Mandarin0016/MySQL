create table `products`
(
    `id`    int auto_increment
        primary key,
    `name`  varchar(30) UNIQUE not null,
    `type`  varchar(30)        not null,
    `price` decimal(10, 2)     not null
);

create table `clients`
(
    `id`         int auto_increment
        primary key,
    `first_name` varchar(50) not null,
    `last_name`  varchar(50) not null,
    `birthdate`  date        not null,
    `card`       varchar(50) ,
    `review`     text
);

create table `tables`
(
    `id`       int auto_increment
        primary key,
    `floor`    int     not null,
    `reserved` BOOL ,
    `capacity` int     not null
);

create table `waiters`
(
    `id`         int auto_increment
        primary key,
    `first_name` varchar(50)    not null,
    `last_name`  varchar(50)    not null,
    `email`      varchar(50)    not null,
    `phone`      varchar(50)    ,
    `salary`     decimal(10, 2)
);

create table `orders`
(
    `id`           int auto_increment
        primary key,
    `table_id`     int        not null,
    `waiter_id`    int        not null,
    `order_time`   time       not null,
    `payed_status` tinyint(1) null
);

create table `orders_clients`
(
    `order_id`  int null,
    `client_id` int null,
    KEY (`order_id`, `client_id`),
    constraint `orders_clients_clients_null_fk`
        foreign key (`client_id`) references `clients` (`id`),
    constraint `orders_clients_orders_null_fk`
        foreign key (`order_id`) references `orders` (`id`)
);



create table `orders_products`
(
    `order_id`   int null,
    `product_id` int null,
    KEY (`order_id`, `product_id`),
    constraint `orders_products_orders_null_fk`
        foreign key (`order_id`) references `orders` (`id`),
    constraint `orders_products_products_null_fk`
        foreign key (`product_id`) references `products` (`id`)
);

# 2

INSERT INTO `products`(`name`, `type`, `price`)
SELECT CONCAT(`last_name`, ' ', 'specialty'),
       'Cocktail',
       CEILING(`salary` * 0.01)
FROM `waiters`
WHERE `id` > 6;

# 3

UPDATE `orders`
SET `table_id` = `table_id` - 1
WHERE `orders`.`id` >= 12
  AND `orders`.`id` <= 23;

# 4

DELETE `waiters`
FROM `waiters`
         LEFT JOIN `orders` ON `waiters`.`id` = `orders`.`waiter_id`
WHERE `orders`.`id` IS NULL;

# 5 Clients

SELECT `id`, `first_name`, `last_name`, `birthdate`, `card`, `review`
FROM `clients`
ORDER BY `birthdate` DESC, `id` DESC;

# 6

SELECT `first_name`, `last_name`, `birthdate`, `review`
FROM `clients`
WHERE `card` IS NULL
  AND YEAR(`birthdate`) BETWEEN 1978 AND 1993
ORDER BY `last_name` DESC, `id`
LIMIT 5;

# 7

SELECT CONCAT(`last_name`, `first_name`, LENGTH(`first_name`), 'Restaurant') AS 'username',
       REVERSE(SUBSTR(`email`, 2, 12))                                       AS 'password'
FROM `waiters`
WHERE `salary` IS NOT NULL
ORDER BY `password` DESC;

# 8

SELECT `products`.`id`, `name`, COUNT(`order_id`) AS 'count'
FROM `products`
         INNER JOIN `orders_products` ON `products`.`id` = `orders_products`.`product_id`
         INNER JOIN `orders` ON `orders_products`.`order_id` = `orders`.`id`
GROUP BY `products`.`id`
HAVING `count` >= 5
ORDER BY `count` DESC, `products`.`name`;

# 9

SELECT `tables`.`id`,
       `capacity`,
       COUNT(`client_id`) AS 'count_clients',
       (CASE
            WHEN `capacity` > COUNT(`client_id`) THEN 'Free seats'
            WHEN `capacity` = COUNT(`client_id`) THEN 'Full'
            WHEN `capacity` < COUNT(`client_id`) THEN 'Extra seats'
           END)
FROM `tables`
         INNER JOIN `orders` ON `tables`.`id` = `orders`.`table_id`
         INNER JOIN `orders_clients` ON `orders`.`id` = `orders_clients`.`order_id`
WHERE `floor` = 1
GROUP BY `tables`.`id`
ORDER BY `id` DESC;

# 10 Extract bill

CREATE FUNCTION `udf_client_bill`(`full_name` VARCHAR(50))
    RETURNS DECIMAL(19, 2)
    DETERMINISTIC
BEGIN
    DECLARE `bill` DECIMAL(19, 2);
    SET `bill` := (SELECT SUM(`price`) AS 'bill'
                   FROM `clients`
                            INNER JOIN `orders_clients` ON `clients`.`id` = `orders_clients`.`client_id`
                            INNER JOIN `orders_products` ON `orders_clients`.`order_id` = `orders_products`.`order_id`
                            INNER JOIN `products` ON `orders_products`.`product_id` = `products`.`id`
                   WHERE CONCAT(`first_name`, ' ', `last_name`) LIKE `full_name`
                   GROUP BY `clients`.`id`);
    RETURN `bill`;
END;

# 11

CREATE PROCEDURE `udp_happy_hour`(`given_type` VARCHAR(50))
BEGIN
    UPDATE `products`
    SET `price` = `price` * 0.80
    WHERE `price` >= 10.00
      AND `products`.`type` LIKE `given_type`;
END;

CALL `udp_happy_hour`('Cognac');

SELECT SUBSTR('SoftUni', 1, 4)
FROM `clients`;

SELECT DAY('2000-01-03');

SELECT concat_ws(' ', `birthdate`, `card`, `last_name`)
from `clients`;







