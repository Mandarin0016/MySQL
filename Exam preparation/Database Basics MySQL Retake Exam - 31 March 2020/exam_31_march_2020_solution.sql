# 1 Table Design

CREATE TABLE `users`
(
    `id`        INT PRIMARY KEY AUTO_INCREMENT,
    `username`  VARCHAR(30) NOT NULL UNIQUE,
    `password`  VARCHAR(30) NOT NULL,
    `email`     VARCHAR(50) NOT NULL,
    `gender`    CHAR(1)     NOT NULL,
    `age`       INT         NOT NULL,
    `job_title` VARCHAR(40) NOT NULL,
    `ip`        VARCHAR(30) NOT NULL
);

CREATE TABLE `addresses`
(
    `id`      INT PRIMARY KEY AUTO_INCREMENT,
    `address` VARCHAR(30) NOT NULL,
    `town`    VARCHAR(30) NOT NULL,
    `country` VARCHAR(30) NOT NULL,
    `user_id` INT         NOT NULL,
    CONSTRAINT `fk_address_user`
        FOREIGN KEY (`user_id`)
            REFERENCES `users` (`id`)
);

CREATE TABLE `photos`
(
    `id`          INT PRIMARY KEY AUTO_INCREMENT,
    `description` TEXT     NOT NULL,
    `date`        DATETIME NOT NULL,
    `views`       INT      NOT NULL DEFAULT 0
);

CREATE TABLE `comments`
(
    `id`       INT PRIMARY KEY AUTO_INCREMENT,
    `comment`  VARCHAR(255) NOT NULL,
    `date`     DATETIME     NOT NULL,
    `photo_id` INT          NOT NULL,
    CONSTRAINT `fk_comment_photo`
        FOREIGN KEY (`photo_id`)
            REFERENCES `photos` (`id`)
);

CREATE TABLE `users_photos`
(
    `user_id`  INT NOT NULL,
    `photo_id` INT NOT NULL,
    KEY `pk_users_photos` (`user_id`, `photo_id`),
    CONSTRAINT `fk_user`
        FOREIGN KEY (`user_id`)
            REFERENCES `users` (`id`),
    CONSTRAINT `fk_photo`
        FOREIGN KEY (`photo_id`)
            REFERENCES `photos` (`id`)
);

CREATE TABLE `likes`
(
    `id`       INT PRIMARY KEY AUTO_INCREMENT,
    `photo_id` INT,
    `user_id`  INT,
    CONSTRAINT `fk_like_photo`
        FOREIGN KEY (`photo_id`)
            REFERENCES `photos` (`id`),
    CONSTRAINT `fk_like_user`
        FOREIGN KEY (`user_id`)
            REFERENCES `users` (`id`)
);

# 2 Insert

INSERT INTO `addresses`(`address`, `town`, `country`, `user_id`)
SELECT `username`,
       `password`,
       `ip`,
       `age`
FROM `users`
WHERE `gender` LIKE 'M';

# 3 Update

UPDATE `addresses`
SET `country` = (
    CASE
        WHEN LEFT(`country`, 1) LIKE 'B' THEN 'Blocked'
        WHEN LEFT(`country`, 1) LIKE 'T' THEN 'Test'
        WHEN LEFT(`country`, 1) LIKE 'P' THEN 'In Progress'
        ELSE `country`
        END);

# 4 Delete

DELETE `addresses`
FROM `addresses`
WHERE MOD(`id`, 3) LIKE 0;

# 5 Users

SELECT `username`, `gender`, `age`
FROM `users`
ORDER BY `age` DESC, `username`;

# 6 Extract 5 most commented photos

SELECT `photos`.`id`, `photos`.`date` AS 'date_and_time', `description`, COUNT(`comments`.`id`) AS 'commentsCount'
FROM `photos`
         LEFT JOIN `comments` ON `photos`.`id` = `comments`.`photo_id`
GROUP BY `photos`.`id`
ORDER BY `commentsCount` DESC, `id`
LIMIT 5;

# 7 Lucky Users

SELECT CONCAT(`id`, ' ', `username`) AS 'id_username', `email`
FROM `users`
         INNER JOIN `users_photos` ON `users`.`id` = `users_photos`.`user_id`
WHERE `id` LIKE `users_photos`.`photo_id`
ORDER BY `id`;

# 8 Count likes and comments

SELECT `id`                                    AS 'photo_id',
       (SELECT COUNT(`li`.`id`)
        FROM `likes` `li`
        WHERE `li`.`photo_id` = `photos`.`id`) AS 'likes_count',
       (SELECT COUNT(`co`.`id`)
        FROM `comments` `co`
        WHERE `co`.`photo_id` = `photos`.`id`) AS 'comments_count'
FROM `photos`
GROUP BY `id`
ORDER BY `likes_count` DESC, `comments_count` DESC, `id`;


# 9 The photo on the tenth day of the month

SELECT CONCAT(LEFT(`description`, 30), '...'), `date`
FROM `photos`
WHERE DAY(`date`) LIKE 10
ORDER BY `date` DESC;

# 10 Get user’s photos count

CREATE FUNCTION `udf_users_photos_count`(`username` VARCHAR(30))
    RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `count` INT;
    SET `count` := (SELECT COUNT(`photo_id`)
                    FROM `users_photos`
                             INNER JOIN `users` ON `users_photos`.`user_id` = `users`.`id`
                    WHERE `users`.`username` = `username`);
    RETURN `count`;
END;


# 11 Increase user age

CREATE PROCEDURE `udp_modify_user`(`address` VARCHAR(30), `town` VARCHAR(30))
BEGIN
    UPDATE `users`
        INNER JOIN `addresses` ON `users`.`id` = `addresses`.`user_id`
    SET `age` = `age` + 10
    WHERE `addresses`.`address` LIKE `address`
      AND `addresses`.`town` LIKE `town`;
END;