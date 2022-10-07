USE `soft_uni`;

# 1

SELECT `employee_id`, `job_title`, `addresses`.`address_id`, `address_text`
FROM `employees`
         JOIN `addresses`
              ON `employees`.`address_id` = `addresses`.`address_id`
ORDER BY `address_id`
LIMIT 5;

# 2

SELECT `e`.`first_name`, `e`.`last_name`, `t`.`name` AS 'town', `a`.`address_text`
FROM `employees` as `e`
         JOIN `addresses` AS `a` ON `e`.`address_id` = `a`.`address_id`
         JOIN `towns` AS `t` ON `a`.`town_id` = `t`.`town_id`
ORDER BY `first_name`, `last_name`
LIMIT 5;

# 3

SELECT `e`.`employee_id`, `e`.`first_name`, `e`.`last_name`, `d`.`name` AS 'department_name'
FROM `employees` AS `e`
         INNER JOIN `departments` AS `d`
                    ON `e`.`department_id` = `d`.`department_id`
WHERE `d`.`name` = 'Sales'
ORDER BY `e`.`employee_id` DESC;

# 4

SELECT `e`.`employee_id`, `e`.`first_name`, `e`.`salary`, `d`.`name` AS 'department_name'
FROM `employees` AS `e`
         INNER JOIN `departments` AS `d`
                    ON `e`.`department_id` = `d`.`department_id`
WHERE `salary` > 15000
ORDER BY `d`.`department_id` DESC
LIMIT 5;

# 5

SELECT `employees`.`employee_id`, `first_name`
FROM `employees`
         LEFT JOIN `employees_projects` ON `employees`.`employee_id` = `employees_projects`.`employee_id`
WHERE `project_id` IS NULL
ORDER BY `employee_id` DESC
LIMIT 3;

# 6

SELECT `first_name`, `last_name`, `hire_date`, `name` AS 'dept_name'
FROM `employees`
         INNER JOIN `departments`
                    ON `employees`.`department_id` = `departments`.`department_id`
WHERE `hire_date` > DATE('1999-01-01')
  AND `name` IN ('Sales', 'Finance')
ORDER BY `hire_date`;

