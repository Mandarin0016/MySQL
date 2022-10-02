USE `geography`;

# 1

CREATE TABLE `passports`
(
    `passport_id`     INT AUTO_INCREMENT PRIMARY KEY,
    `passport_number` VARCHAR(50) UNIQUE
);

INSERT INTO `passports`(`passport_id`, `passport_number`)
VALUES (101, 'N34FG21B'),
       (102, 'K65LO4R7'),
       (103, 'ZE657QP2');

CREATE TABLE `people`
(
    `person_id`   INT AUTO_INCREMENT PRIMARY KEY,
    `first_name`  VARCHAR(50),
    `salary`      DECIMAL(9, 2),
    `passport_id` INT UNIQUE,
    FOREIGN KEY (`passport_id`) REFERENCES `passports` (`passport_id`)
);

INSERT INTO `people`(`first_name`, `salary`, `passport_id`)
VALUES ('Roberto', 43300.00, 102),
       ('Tom', 56100.00, 103),
       ('Yana', 60200.00, 101);

# 2

CREATE TABLE `manufacturers`
(
    `manufacturer_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name`            VARCHAR(20),
    `established_on`  DATE
);

INSERT INTO `manufacturers`(`name`, `established_on`)
VALUES ('BMW', '1916/03/01'),
       ('Tesla', '2003/01/01'),
       ('Lada', '1966/05/01');

CREATE TABLE `models`
(
    `model_id`        INT AUTO_INCREMENT PRIMARY KEY,
    `name`            VARCHAR(20),
    `manufacturer_id` INT,
    CONSTRAINT `fk_man_mod`
        FOREIGN KEY (`manufacturer_id`) REFERENCES `manufacturers` (`manufacturer_id`)
);

INSERT INTO `models`(`model_id`, `name`, `manufacturer_id`)
VALUES (101, 'X1', 1),
       (102, 'i6', 1),
       (103, 'Model S', 2),
       (104, 'Model X', 2),
       (105, 'Model 3', 2),
       (106, 'Nova', 3);


# 3

CREATE TABLE `exams`
(
    `exam_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name`    VARCHAR(50)
);

INSERT INTO `exams`(`exam_id`, `name`)
VALUES (101, 'Spring MVC'),
       (102, 'Neo4j'),
       (103, 'Oracle 11g');

CREATE TABLE `students`
(
    `student_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(50)
);

INSERT INTO `students`(`name`)
VALUES ('Mila'),
       ('Toni'),
       ('Ron');

CREATE TABLE `students_exams`
(
    `student_id` INT NOT NULL,
    `exam_id`    INT NOT NULL,
    PRIMARY KEY (`student_id`, `exam_id`),
    CONSTRAINT `student_fk_id`
        FOREIGN KEY `student_fk_id` (`student_id`) REFERENCES `students` (`student_id`)
            ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT `exam_fk_id`
        FOREIGN KEY `exam_fk_id` (`exam_id`) REFERENCES `exams` (`exam_id`)
            ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO `students_exams`(`student_id`, `exam_id`)
VALUES (1, 101),
       (1, 102),
       (2, 101),
       (3, 103),
       (2, 102),
       (2, 103);

# 4

CREATE TABLE `teachers`
(
    `teacher_id` INT AUTO_INCREMENT PRIMARY KEY,
    `name`       VARCHAR(50) NOT NULL,
    `manager_id` INT
);

INSERT INTO `teachers`(`teacher_id`, `name`, `manager_id`)
VALUES (101, 'John', NULL),
       (102, 'Maya', 106),
       (103, 'Silvia', 106),
       (104, 'Ted', 105),
       (105, 'Mark', 101),
       (106, 'Greta', 101);

ALTER TABLE `teachers`
    ADD FOREIGN KEY (`manager_id`) REFERENCES `teachers` (`teacher_id`);

# 5

CREATE TABLE `cities`
(
    `city_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`    VARCHAR(50)
);

CREATE TABLE `item_types`
(
    `item_type_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`         VARCHAR(50)
);

CREATE TABLE `customers`
(
    `customer_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name`        VARCHAR(50),
    `birthday`    DATE,
    `city_id`     INT,
    FOREIGN KEY (`city_id`)
        REFERENCES `cities` (`city_id`)
);

CREATE TABLE `orders`
(
    `order_id`    INT PRIMARY KEY AUTO_INCREMENT,
    `customer_id` INT NOT NULL,
    FOREIGN KEY (`customer_id`)
        REFERENCES `customers` (`customer_id`)
);

CREATE TABLE `items`
(
    `item_id`      INT PRIMARY KEY AUTO_INCREMENT,
    `name`         VARCHAR(50),
    `item_type_id` INT NOT NULL,
    FOREIGN KEY (`item_type_id`)
        REFERENCES `item_types` (`item_type_id`)
);

CREATE TABLE `order_items`
(
    `order_id` INT NOT NULL,
    `item_id`  INT NOT NULL,
    PRIMARY KEY (`order_id`, `item_id`),
    FOREIGN KEY (`order_id`)
        REFERENCES `orders` (`order_id`),
    FOREIGN KEY (`item_id`)
        REFERENCES `items` (`item_id`)
);