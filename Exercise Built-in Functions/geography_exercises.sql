USE `geography`;

# 10

SELECT `country_name`, `iso_code`
FROM `countries`
WHERE LOWER(`country_name`) LIKE '%a%a%a%'
ORDER BY `iso_code`;

# 11

SELECT `peak_name`, `river_name`, CONCAT(LOWER(`peak_name`), LOWER(SUBSTR(`river_name`, 2))) AS `mix`
FROM `peaks`,
     `rivers`
WHERE LOWER(RIGHT(`peak_name`, 1)) = LOWER(LEFT(`river_name`, 1))
ORDER BY `mix`;
