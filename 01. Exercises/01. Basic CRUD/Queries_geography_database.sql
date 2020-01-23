#21. All Mountain Peaks
SELECT `peak_name` FROM `peaks`
ORDER BY `peak_name`;

#22. Biggest Countries by Population
SELECT `country_name`, `population` FROM `countries`
WHERE `continent_code` = 'EU'
ORDER BY `population` DESC , `country_name` ASC
LIMIT 30;

#23. Countries and Currency (Euro / Not Euro)
SELECT `country_name`, `country_code`,
       CASE `currency_code` WHEN 'EUR' THEN 'Euro' ELSE 'Not Euro' END AS 'currency'
FROM `countries`
ORDER BY `country_name`;
