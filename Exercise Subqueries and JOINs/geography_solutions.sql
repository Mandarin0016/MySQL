USE `geography`;

# 12

SELECT `mc`.`country_code`, `m`.`mountain_range`, `p`.`peak_name`, `p`.`elevation`
FROM `mountains_countries` `mc`
         INNER JOIN `mountains` `m` ON `mc`.`mountain_id` = `m`.`id`
         INNER JOIN `peaks` `p` USING (`mountain_id`)
WHERE `mc`.`country_code` = 'BG'
  AND `p`.`elevation` > 2835
ORDER BY `p`.`elevation` DESC;


# 13

SELECT `country_code`, COUNT(*) AS 'mountain_range'
FROM `mountains_countries`
WHERE `country_code` IN ('BG', 'RU', 'US')
GROUP BY `country_code`
ORDER BY `mountain_range` DESC;

# 14

SELECT `c`.`country_name`, `river_name`
FROM `countries` `c`
         LEFT JOIN `countries_rivers` `cr` USING (`country_code`)
         LEFT JOIN `rivers` `r` ON `cr`.`river_id` = `r`.`id`
WHERE `continent_code` = 'AF'
ORDER BY `country_name`
LIMIT 5;

# 15

SELECT `continent_code`, `currency_code`, COUNT(`currency_code`) AS `currency_usage`
FROM `countries` `c1`
GROUP BY `continent_code`, `currency_code`
HAVING `currency_usage` = (SELECT COUNT(`currency_code`) AS `count`
                           FROM `countries` `c2`
                           WHERE `c2`.`continent_code` = `c1`.`continent_code`
                           GROUP BY `c2`.`currency_code`
                           ORDER BY `count` DESC
                           LIMIT 1)
   AND `currency_usage` > 1
ORDER BY `continent_code`, `currency_code`;

# 16

SELECT COUNT(`country_code`) AS 'country_count'
FROM `countries`
         LEFT JOIN `mountains_countries` USING (`country_code`)
WHERE `mountain_id` IS NULL;

# 17

SELECT `country_name`,

       (SELECT MAX(`p`.`elevation`)
        FROM `mountains_countries`
                 LEFT JOIN `peaks` AS `p` USING (`mountain_id`)
        WHERE `country_code` = `c`.`country_code`) AS `highest_peak_elevation`,

       (SELECT MAX(`r`.`length`)
        FROM `countries_rivers` AS `cr`
                 LEFT JOIN `rivers` AS `r`
                           ON `cr`.`river_id` = `r`.`id`
        WHERE `country_code` = `c`.`country_code`) AS `longest_river_length`

FROM `countries` AS `c`
ORDER BY `highest_peak_elevation` DESC, `longest_river_length` DESC, `country_name`
LIMIT 5;