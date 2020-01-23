#12. Games from 2011 and 2012 Year
SELECT `name`, DATE_FORMAT(`start`, '%Y-%m-%d') as `asd` FROM `games`
WHERE extract(YEAR FROM `start`) in ('2011', '2012')
ORDER BY `start`, `name`
LIMIT 50;

#13. User Email Providers
SELECT `user_name`, substring(`email`, locate('@', `email`) + 1) as `Email Provider` FROM `users`
ORDER BY `Email Provider`, `user_name`;

#14. Get Users with IP Address Like Pattern
SELECT `user_name`, `ip_address` FROM `users`
WHERE `ip_address` LIKE '___.1%.%.___'
ORDER BY `user_name`;

#15. Show All Games with Duration and Part of the Day
SELECT `name` AS `game`,
       CASE
           WHEN extract(HOUR FROM `start`) BETWEEN 00 and 11 THEN 'Morning'
           WHEN extract(HOUR FROM `start`) BETWEEN 12 and 17 THEN 'Afternoon'
           WHEN extract(HOUR FROM `start`) BETWEEN 18 and 23 THEN 'Evening'
           END AS `Part of the Day`,
       CASE
           WHEN `duration` BETWEEN 0 AND 3 THEN 'Extra Short'
           WHEN `duration` BETWEEN 4 AND 6 THEN 'Short'
           WHEN `duration` BETWEEN 7 AND 10 THEN 'Long'
           ELSE 'Extra Long'
           END AS `Duration` FROM `games`;