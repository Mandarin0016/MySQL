# 1

create table `pictures`
(
    `id`       int auto_increment
        primary key,
    `url`      varchar(100) not null,
    `added_on` datetime     not null
);

create table `categories`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(40) not null,
    constraint `categories_pk`
        unique (`name`)
);

create table `products`
(
    `id`          int auto_increment
        primary key,
    `name`        varchar(40)    not null,
    `best_before` date           null,
    `price`       decimal(10, 2) not null,
    `description` text           null,
    `category_id` int            not null,
    `picture_id`  int            not null,
    constraint `products_pk`
        unique (`name`),
    constraint `products_categories_null_fk`
        foreign key (`category_id`) references `categories` (`id`),
    constraint `products_pictures_null_fk`
        foreign key (`picture_id`) references `pictures` (`id`)
);

create table `towns`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(20) not null,
    constraint `towns_pk`
        unique (`name`)
);

create table `addresses`
(
    `id`      int auto_increment
        primary key,
    `name`    varchar(50) not null,
    `town_id` int         not null,
    constraint `addresses_pk`
        unique (`name`),
    constraint `addresses_towns_null_fk`
        foreign key (`town_id`) references `towns` (`id`)
);

create table `stores`
(
    `id`          int auto_increment
        primary key,
    `name`        varchar(20)          not null,
    `rating`      float                not null,
    `has_parking` tinyint(1) default 0 null,
    `address_id`  int                  not null,
    constraint `stores_pk`
        unique (`name`),
    constraint `stores_addresses_null_fk`
        foreign key (`address_id`) references `addresses` (`id`)
);

create table `products_stores`
(
    `product_id` int not null,
    `store_id`   int not null,
    primary key (`product_id`, `store_id`)
);

create table `employees`
(
    `id`          int auto_increment
        primary key,
    `first_name`  varchar(15)              not null,
    `middle_name` char                     null,
    `last_name`   varchar(20)              not null,
    `salary`      decimal(19, 2) default 0 null,
    `hire_date`   date                     not null,
    `manager_id`  int                      null,
    `store_id`    int                      not null,
    constraint `employees_fk_managers`
        foreign key (`manager_id`) references `employees` (`id`),
    constraint `employees_fk_stores`
        foreign key (`store_id`) references `stores` (`id`)
);

# 2

INSERT INTO `products_stores`(`product_id`, `store_id`)
SELECT `id`,
       1
FROM `products`
         LEFT JOIN `products_stores` ON `products`.`id` = `products_stores`.`product_id`
WHERE `store_id` IS NULL;

# 3

UPDATE `employees`
    INNER JOIN `stores` ON `employees`.`store_id` = `stores`.`id`
SET `manager_id` = 3,
    `salary`     = `salary` - 500
WHERE YEAR(`hire_date`) > 2003
  AND `name` NOT IN ('Cardguard', 'Veribet');

# 4

DELETE `employees`
FROM `employees`
WHERE `manager_id` IS NOT NULL
  AND `salary` >= 6000;

# 5

SELECT `first_name`, `middle_name`, `last_name`, `salary`, `hire_date`
FROM `employees`
ORDER BY `hire_date` DESC;

# 6

SELECT `name`, `price`, `best_before`, CONCAT(LEFT(`description`, 10), '...') AS 'short_description', `url`
FROM `products`
         INNER JOIN `pictures` `p` on `products`.`picture_id` = `p`.`id`
WHERE LENGTH(`description`) > 100
  AND YEAR(`added_on`) < 2019
  AND `price` > 20
ORDER BY `price` DESC;

# 7

SELECT `s`.`name` AS 'name', COUNT(`products`.`id`) AS 'product_count', ROUND(AVG(`price`), 2) AS 'avg'
FROM `stores` `s`
         LEFT JOIN `products_stores` ON `s`.`id` = `products_stores`.`store_id`
         LEFT JOIN `products` ON `products_stores`.`product_id` = `products`.`id`
GROUP BY `s`.`id`
ORDER BY `product_count` DESC, `avg` DESC, `s`.`id`;

# 8

SELECT CONCAT(`first_name`, ' ', `last_name`) AS 'Full_name',
       `s`.`name`                             AS 'Store_name',
       `a`.`name`                             AS 'address',
       `salary`
FROM `employees`
         INNER JOIN `stores` `s` on `employees`.`store_id` = `s`.`id`
         INNER JOIN `addresses` `a` on `s`.`address_id` = `a`.`id`
WHERE `salary` < 4000
  AND `a`.`name` LIKE '%5%'
  AND LENGTH(`s`.`name`) > 5
  AND `last_name` LIKE '%n';

# 9

SELECT REVERSE(`stores`.`name`)                               AS 'reversed_name',
       CONCAT(UPPER(`towns`.`name`), '-', `addresses`.`name`) AS 'full_address',
       COUNT(`employees`.`id`)                                AS 'employees_count'
FROM `stores`
         INNER JOIN `addresses` ON `stores`.`address_id` = `addresses`.`id`
         INNER JOIN `employees` ON `stores`.`id` = `employees`.`store_id`
         INNER JOIN `towns` ON `addresses`.`town_id` = `towns`.`id`
GROUP BY `stores`.`id`
HAVING `employees_count` >= 1
ORDER BY `full_address`;

# 10

CREATE FUNCTION `udf_top_paid_employee_by_store`(`store_name` VARCHAR(50))
    RETURNS VARCHAR(100)
    DETERMINISTIC
BEGIN
    DECLARE `answer` VARCHAR(100);
    SET `answer` := (SELECT CONCAT(`first_name`, ' ', `middle_name`, '. ', `last_name`, ' works in store for ',
                                   2020 - YEAR(`hire_date`), ' years')
                     FROM `employees`
                              INNER JOIN `stores` `s` on `employees`.`store_id` = `s`.`id`
                     WHERE `name` LIKE `store_name`
                     ORDER BY `salary` DESC
                     LIMIT 1);
    RETURN `answer`;
END;

# 11

CREATE PROCEDURE `udp_update_product_price`(`address_name` VARCHAR(50))
BEGIN
    UPDATE `products`
        INNER JOIN `products_stores` ON `products`.`id` = `products_stores`.`product_id`
        INNER JOIN `stores` ON `products_stores`.`store_id` = `stores`.`id`
        INNER JOIN `addresses` ON `stores`.`address_id` = `addresses`.`id`
    SET `price` = `price` + (IF(LEFT(`address_name`, 1) LIKE '0', 100, 200))
    WHERE `addresses`.`name` LIKE `address_name`;
END;

