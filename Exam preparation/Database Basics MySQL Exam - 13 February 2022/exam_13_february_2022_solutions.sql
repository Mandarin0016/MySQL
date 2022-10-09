# 1 Table Design

create table `brands`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(40) not null,
    constraint `brands_pk`
        unique (`name`)
);

create table `categories`
(
    `id`   int auto_increment
        primary key,
    `name` varchar(40) not null,
    constraint `categories_pk`
        unique (`name`)
);

create table `reviews`
(
    `id`           int auto_increment
        primary key,
    `content`      text           null,
    `rating`       decimal(10, 2) not null,
    `picture_url`  varchar(80)    not null,
    `published_at` datetime       not null
);

create table `products`
(
    `id`                int auto_increment
        primary key,
    `name`              varchar(40)    not null,
    `price`             decimal(19, 2) not null,
    `quantity_in_stock` int            null,
    `description`       text           null,
    `brand_id`          int            not null,
    `category_id`       int            not null,
    `review_id`         int            null,
    constraint `products_brands_null_fk`
        foreign key (`brand_id`) references `brands` (`id`),
    constraint `products_categories_null_fk`
        foreign key (`category_id`) references `categories` (`id`),
    constraint `products_reviews_null_fk`
        foreign key (`review_id`) references `reviews` (`id`)
);

create table `customers`
(
    `id`            int auto_increment
        primary key,
    `first_name`    varchar(20)      not null,
    `last_name`     varchar(20)      not null,
    `phone`         varchar(30)      not null,
    `address`       varchar(60)      not null,
    `discount_card` bit(1) default 0 not null,
    constraint `customers_pk`
        unique (`phone`)
);

create table `orders`
(
    `id`             int auto_increment
        primary key,
    `order_datetime` datetime not null,
    `customer_id`    int      not null,
    constraint `orders_customers_null_fk`
        foreign key (`customer_id`) references `customers` (`id`)
);

create table `orders_products`
(
    `order_id`   int null,
    `product_id` int null,
    constraint `orders_products_orders_null_fk`
        foreign key (`order_id`) references `orders` (`id`),
    constraint `orders_products_products_null_fk`
        foreign key (`product_id`) references `products` (`id`)
);

# 2 Insert

INSERT INTO `reviews`(`content`, `picture_url`, `published_at`, `rating`)
SELECT LEFT(`description`, 15),
       REVERSE(`name`),
       '2010-10-10',
       `price` / 8
FROM `products`
WHERE `id` >= 5;

# 3 Update

UPDATE `products`
SET `quantity_in_stock` = `quantity_in_stock` - 5
WHERE `quantity_in_stock` BETWEEN 60 AND 70;

# 4 Delete

DELETE `customers`
FROM `customers`
         LEFT JOIN `orders`
                   ON `customers`.`id` = `orders`.`customer_id`
WHERE `orders`.`id` IS NULL;

# 5 Categories

SELECT `id`, `name`
FROM `categories`
ORDER BY `name` DESC;

# 6 Quantity

SELECT `id`, `brand_id`, `name`, `quantity_in_stock`
FROM `products`
WHERE `price` > 1000
  AND `quantity_in_stock` < 30
ORDER BY `quantity_in_stock`, `id`;

# 7 Review

SELECT `id`, `content`, `rating`, `picture_url`, `published_at`
FROM `reviews`
WHERE `content` LIKE 'My%'
  AND LENGTH(`content`) > 61
ORDER BY `rating` DESC;

# 8 First customers

SELECT CONCAT(`first_name`, ' ', `last_name`) AS 'full_name', `address`, `order_datetime`
FROM `customers`
         INNER JOIN `orders` `o` on `customers`.`id` = `o`.`customer_id`
WHERE YEAR(`order_datetime`) <= 2018
ORDER BY `full_name` DESC;

# 9 Best categories

SELECT COUNT(`p`.`id`) AS 'items_count', `c`.`name`, SUM(`quantity_in_stock`) AS 'total_quantity'
FROM `products` `p`
         INNER JOIN `categories` `c` ON `p`.`category_id` = `c`.`id`
GROUP BY `category_id`
ORDER BY `items_count` DESC, `total_quantity`
LIMIT 5;

# 10 Extract client cards count

CREATE FUNCTION `udf_customer_products_count`(`name` VARCHAR(30))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `total_products` INT;
    SET `total_products` := (SELECT COUNT(`orders`.`id`)
                             FROM `customers`
                                      INNER JOIN `orders` ON `customers`.`id` = `orders`.`customer_id`
                                      INNER JOIN `orders_products` ON `orders`.`id` = `orders_products`.`order_id`
                             WHERE `first_name` = `name`);
    RETURN `total_products`;
END;

# 11 Reduce price

CREATE PROCEDURE `udp_reduce_price`(`category_name` VARCHAR(50))
BEGIN
    UPDATE `products` `p`
        INNER JOIN `reviews` `r` ON `p`.`review_id` = `r`.`id`
        INNER JOIN `categories` `c` ON `p`.`category_id` = `c`.`id`
    SET `price` = `price` * 0.70
    WHERE `c`.`name` = `category_name`
      AND `rating` < 4;
END;

CALL `udp_reduce_price`('Phones and tablets');