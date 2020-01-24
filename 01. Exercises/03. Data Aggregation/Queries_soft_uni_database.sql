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
#soonTM

#18. Salary Challenge
#soonTM

#19. Departments Total Salaries
SELECT `department_id`, sum(`salary`) AS `total_salary` FROM `employees`
GROUP BY `department_id`
ORDER BY `department_id`;