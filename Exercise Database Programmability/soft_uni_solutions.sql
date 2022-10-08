USE `soft_uni`;

# 1

CREATE PROCEDURE `usp_get_employees_salary_above_35000`()
BEGIN
    SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` > 35000
    ORDER BY `first_name`, `last_name`, `employee_id`;
END;

# 2

CREATE PROCEDURE `usp_get_employees_salary_above`(`@salary` DECIMAL(20, 4))
BEGIN
    SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE `salary` >= `@salary`
    ORDER BY `first_name`, `last_name`, `employee_id`;
END;

# 3

CREATE PROCEDURE `usp_get_towns_starting_with`(`town_prefix` VARCHAR(50))
BEGIN
    SELECT `name`
    FROM `towns`
    WHERE LEFT(`name`, LENGTH(`town_prefix`)) = `town_prefix`
    ORDER BY `name`;
END;

# 4

CREATE PROCEDURE `usp_get_employees_from_town`(`town_name` VARCHAR(50))
BEGIN
    SELECT `first_name`, `last_name`
    FROM `employees`
             INNER JOIN `addresses` USING (`address_id`)
             INNER JOIN `towns` USING (`town_id`)
    WHERE `name` = `town_name`
    ORDER BY `first_name`, `last_name`, `employee_id`;
END;

# 5

CREATE FUNCTION `ufn_get_salary_level`(`salary_data` DECIMAL(20, 2))
    RETURNS VARCHAR(50)
    DETERMINISTIC
BEGIN
    DECLARE `salary_Level` VARCHAR(50);
    SET `salary_Level` :=
            CASE
                WHEN `salary_data` < 30000 THEN 'Low'
                WHEN `salary_data` BETWEEN 30000 AND 50000 THEN 'Average'
                ELSE 'High'
                END;
    RETURN `salary_Level`;
END;

# 6

CREATE PROCEDURE `usp_get_employees_by_salary_level`(`salaty_level` VARCHAR(50))
BEGIN
    SELECT `first_name`, `last_name`
    FROM `employees`
    WHERE CASE
              WHEN `salaty_level` = 'low' THEN `salary` < 30000
              WHEN `salaty_level` = 'average' THEN `salary` BETWEEN 30000 AND 50000
              WHEN `salaty_level` = 'high' THEN `salary` > 50000
              END
    ORDER BY `first_name` DESC, `last_name` DESC;
END;

# 7

CREATE FUNCTION `ufn_is_word_comprised`(`set_of_letters` varchar(50), `word` varchar(50))
    RETURNS INTEGER
    DETERMINISTIC
BEGIN
    RETURN REGEXP_LIKE(lower(`word`), CONCAT('^[', lower(`set_of_letters`), ']+$'));
END;

# 8

CREATE PROCEDURE `usp_get_holders_full_name`()
BEGIN
    SELECT concat_ws(' ', `first_name`, `last_name`) AS `full_name`
    FROM `account_holders`
    ORDER BY `full_name`;
END;

# 9

CREATE PROCEDURE `usp_get_holders_with_balance_higher_than`(`balance` DECIMAL(12, 4))
BEGIN
    SELECT `first_name`, `last_name`
    FROM `account_holders` AS `h`
             LEFT JOIN `accounts` AS `a`
                       ON `h`.`id` = `a`.`account_holder_id`
    GROUP BY `first_name`, `last_name`
    HAVING sum(`a`.`balance`) > `balance`;
END;

# 10

CREATE FUNCTION `ufn_calculate_future_value`(`sum` DECIMAL(19, 4), `yearly_interest` DOUBLE, `yers` INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN
    DECLARE `future_sum` DECIMAL(19, 4);
    SET `future_sum` := `sum` * pow(1 + `yearly_interest`, `yers`);
    RETURN `future_sum`;
END;

# 11

CREATE FUNCTION `ufn_calculate_future_value`(`sum` DECIMAL(19, 4), `yearly_interest` DECIMAL(19, 4), `yers` INT)
    RETURNS DECIMAL(19, 4)
    DETERMINISTIC
BEGIN
    DECLARE `future_sum` DECIMAL(19, 4);
    SET `future_sum` := `sum` * pow(1 + `yearly_interest`, `yers`);
    RETURN `future_sum`;
END;

CREATE PROCEDURE `usp_calculate_future_value_for_account`(`id` INT, `interest` DECIMAL(19, 4))
BEGIN
    SELECT `a`.`id`,
           `first_name`,
           `last_name`,
           `a`.`balance`                                              AS `current_balance`,
           `ufn_calculate_future_value`(`a`.`balance`, `interest`, 5) AS `balance_in_5_years`
    FROM `account_holders` AS `h`
             LEFT JOIN `accounts` AS `a`
                       ON `h`.`id` = `a`.`account_holder_id`
    WHERE `a`.`id` = `id`;
END;

# 12

CREATE PROCEDURE `usp_deposit_money`(`account_id` INT, `money_amount` DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF (`money_amount` <= 0) THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` + `money_amount`
        WHERE `id` = `account_id`;
        COMMIT;
    END IF;
END;

# 13

CREATE PROCEDURE `usp_withdraw_money`(`account_id` INT, `money_amount` DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF (`money_amount` <= 0 OR (SELECT `balance` FROM `accounts` WHERE `id` = `account_id`) < `money_amount`) THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` - `money_amount`
        WHERE `id` = `account_id`;
    END IF;
END;

# 14

CREATE PROCEDURE `usp_transfer_money`(`from_account_id` INT, `to_account_id` INT, `amount` DECIMAL(19, 4))
BEGIN
    START TRANSACTION;
    IF (`amount` <= 0
        OR (SELECT `balance` FROM `accounts` WHERE `id` = `from_account_id`) < `amount`
        OR (SELECT count(`id`) FROM `accounts` WHERE `id` = `from_account_id`) <> 1
        OR (SELECT count(`id`) FROM `accounts` WHERE `id` = `to_account_id`) <> 1
        OR `from_account_id` = `to_account_id`) THEN
        ROLLBACK;
    ELSE
        UPDATE `accounts`
        SET `balance` = `balance` - `amount`
        WHERE `id` = `from_account_id`;

        UPDATE `accounts`
        SET `balance` = `balance` + `amount`
        WHERE `id` = `to_account_id`;
        COMMIT;
    END IF;
END;

# 15

CREATE TABLE `logs`
(
    `log_id`     INT PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT            NOT NULL,
    `old_sum`    DECIMAL(19, 4) NOT NULL,
    `new_sum`    DECIMAL(19, 4) NOT NULL
);

CREATE TRIGGER `tr_change_balance`
    AFTER UPDATE
    ON `accounts`
    FOR EACH ROW
BEGIN
    INSERT INTO `logs`(`account_id`, `old_sum`, `new_sum`)
    VALUES (`OLD`.`id`, `OLD`.`balance`, `NEW`.`balance`);
END;

# 16

CREATE TABLE `logs`
(
    `log_id`     INT PRIMARY KEY AUTO_INCREMENT,
    `account_id` INT            NOT NULL,
    `old_sum`    DECIMAL(19, 4) NOT NULL,
    `new_sum`    DECIMAL(19, 4) NOT NULL
);

CREATE TRIGGER `tr_change_balance`
    AFTER UPDATE
    ON `accounts`
    FOR EACH ROW
BEGIN
    INSERT INTO `logs`(`account_id`, `old_sum`, `new_sum`)
    VALUES (`OLD`.`id`, `OLD`.`balance`, `NEW`.`balance`);
END;

CREATE TABLE `notification_emails`
(
    `id`        INT PRIMARY KEY AUTO_INCREMENT,
    `recipient` INT NOT NULL,
    `subject`   TEXT,
    `body`      TEXT
);

CREATE TRIGGER `tr_email_on_change_balance`
    AFTER INSERT
    ON `logs`
    FOR EACH ROW
BEGIN
    INSERT INTO `notification_emails`(`recipient`, `subject`, `body`)
    VALUES (`NEW`.`account_id`, concat_ws(' ', 'Balance change for account:', `NEW`.`account_id`),
            concat_ws(' ', 'On', NOW(), 'your balance was changed from', `NEW`.`old_sum`, 'to', `NEW`.`new_sum`, '.'));
END;