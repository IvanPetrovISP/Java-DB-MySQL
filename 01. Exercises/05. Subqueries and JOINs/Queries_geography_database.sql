#12. Highest Peaks in Bulgaria
SELECT c.`country_code`, m.`mountain_range`, p.`peak_name`, p.`elevation`
FROM `countries` AS `c`
JOIN `mountains_countries` `mc` ON `c`.`country_code` = `mc`.`country_code`
JOIN `mountains` `m` ON `mc`.`mountain_id` = `m`.`id`
JOIN `peaks` `p` ON `m`.`id` = `p`.`mountain_id`
WHERE c.`country_code` = 'BG' AND p.`elevation` > 2835
ORDER BY p.`elevation` DESC;

#13. Count Mountain Ranges
SELECT c.`country_code`, count(m.`mountain_range`) AS `mountain_range`
FROM `countries` AS `c`
JOIN `mountains_countries` `mc` ON `c`.`country_code` = `mc`.`country_code`
JOIN `mountains` `m` ON `mc`.`mountain_id` = `m`.`id`
WHERE c.`country_code` IN ('BG', 'US', 'RU')
GROUP BY c.`country_code`
ORDER BY `mountain_range` DESC;

#14. Countries with Rivers
SELECT c.`country_name`, r.`river_name`
FROM `countries` AS `c`
LEFT JOIN `countries_rivers` `cr` ON `c`.`country_code` = `cr`.`country_code`
LEFT JOIN `rivers` `r` ON `cr`.`river_id` = `r`.`id`
WHERE c.`continent_code` = 'AF'
ORDER BY c.`country_name`
LIMIT 5;

#15. *Continents and Currencies
SELECT c.`continent_code`, c.`currency_code`, count(*) AS 'currency_usage'
FROM `countries` AS `c`
GROUP BY c.`continent_code` , c.`currency_code`
HAVING `currency_usage` > 1 AND `currency_usage` = (
    SELECT count(*) AS `count` FROM `countries` AS `c2`
    WHERE `c2`.`continent_code` = c.`continent_code`
    GROUP BY `c2`.`currency_code`
    ORDER BY `count` DESC
    LIMIT 1)
ORDER BY c.`continent_code` , c.`continent_code`;

#16. Countries without any Mountains
SELECT count(c.`country_code`) AS `country_count` FROM `countries` AS `c`
LEFT JOIN `mountains_countries` `mc` ON `c`.`country_code` = `mc`.`country_code`
WHERE mc.`mountain_id` IS NULL;

#17. Highest Peak and Longest River by Country
SELECT c.`country_name`, max(p.`elevation`) as `highest_peak_elevation`,
       max(r.`length`) as `longest_river_length`
FROM `countries` AS `c`
LEFT JOIN `mountains_countries` `mc` ON `c`.`country_code` = `mc`.`country_code`
JOIN `mountains` AS `m` ON `mc`.`mountain_id` = `m`.`id`
JOIN `peaks` `p` ON `m`.`id` = `p`.`mountain_id`
LEFT JOIN `countries_rivers` `cr` ON `c`.`country_code` = `cr`.`country_code`
JOIN `rivers` `r` ON `cr`.`river_id` = `r`.`id`
GROUP BY c.`country_code`, `country_name`
ORDER BY `highest_peak_elevation` DESC,
         `longest_river_length` DESC,
         c.`country_name`
LIMIT 5;