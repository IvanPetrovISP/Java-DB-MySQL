#13. Employees Minimum Salaries
SELECT `department_id`, min(`salary`) AS `minimum_salary` FROM `employees`
WHERE `department_id` IN (2, 5, 7) AND `hire_date` > '2000-01-01'
GROUP BY `department_id`
ORDER BY `department_id`;

#14. Employees Average Salaries
CREATE TABLE `temp_table` AS SELECT `department_id`, avg(`salary`) AS `avg_salary` FROM `employees`
WHERE `manager_id` != 42 AND `salary` > 30000
GROUP BY `department_id`;

UPDATE `temp_table`
SET `avg_salary` = `avg_salary` + 5000
WHERE `department_id` = 1;

SELECT * FROM `temp_table`
ORDER BY `department_id`;

#15. Employees Maximum Salaries
SELECT `department_id`, max(`salary`) AS `max_salary` FROM `employees`
GROUP BY `department_id`
HAVING `max_salary` < 30000 OR `max_salary` > 70000
ORDER BY `department_id`;

#16. Employees Count Salaries
SELECT count(`salary`)as `` FROM `employees`
WHERE `manager_id` IS NULL
GROUP BY `manager_id`;

#17. 3rd Highest Salary
SELECT `department_id`,
    (SELECT DISTINCT `e2`.`salary`
        FROM `employees` AS `e2`
        WHERE `e2`.`department_id` = `e1`.`department_id`
        ORDER BY `e2`.`salary` DESC
        LIMIT 2 , 1) AS `third_highest_salary`
FROM `employees` AS `e1`
GROUP BY `department_id`
HAVING `third_highest_salary` IS NOT NULL
ORDER BY `department_id`;

#18. Salary Challenge
SELECT e1.`first_name`, e1.`last_name`, e1.`department_id` FROM `employees` AS `e1`
WHERE `salary` > (
    SELECT avg(e2.`salary`) FROM `employees` AS  `e2`
    WHERE e2.`department_id` = e1.`department_id`
    GROUP BY e2.`department_id`)
ORDER BY e1.`department_id`, e1.`employee_id`
LIMIT 10;

#19. Departments Total Salaries
SELECT `department_id`, sum(`salary`) AS `total_salary` FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`;
