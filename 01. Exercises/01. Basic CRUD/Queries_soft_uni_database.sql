#01. Find All Information About Departments
SELECT * FROM `departments`;

#02. Find all Department Names
SELECT `name` from `departments`
ORDER BY `department_id` ASC;

#03. Find Salary of Each Employee
SELECT `first_name`, `last_name`, `salary`
FROM soft_uni.`employees`;

#04. Find Full Name of Each Employee
SELECT `first_name`, `middle_name`, `last_name`
FROM soft_uni.`employees`;

#05. Find Email Address of Each Employee
SELECT concat(`first_name`, '.', `last_name`, '@softuni.bg') AS `full_email_address`
FROM soft_uni.`employees`;

#06. Find All Different Employee’s Salaries
SELECT DISTINCT `salary` FROM soft_uni.`employees`
ORDER BY `employee_id` ASC ;

#07. Find all Information About Employees
SELECT * FROM soft_uni.`employees`
WHERE `job_title` = 'Sales Representative'
ORDER BY `employee_id`;

#08. Find Names of All Employees by Salary in Range
SELECT `first_name`, `last_name`, `job_title` FROM soft_uni.`employees`
WHERE `salary` >= 20000 AND `salary` <= 30000
ORDER BY `employee_id`;

#09. Find Names of All Employees
SELECT concat_ws(' ', `first_name`, `middle_name`, `last_name`) as `Full Name` FROM soft_uni.`employees`
WHERE `salary` = 25000 or `salary` = 14000 or `salary` = 12500 or `salary` = 23600;

#10. Find All Employees Without Manager
SELECT `first_name`, `last_name` FROM soft_uni.`employees`
WHERE `manager_id` IS NULL;

#11. Find All Employees with Salary More Than
SELECT `first_name`, `last_name`, `salary` FROM soft_uni.`employees`
WHERE `salary` > 50000 ORDER BY `salary`DESC;

#12. Find 5 Best Paid Employees
SELECT `first_name`, `last_name` FROM soft_uni.`employees`
ORDER BY `salary` DESC LIMIT 5;

#13. Find All Employees Except Marketing
SELECT `first_name`, `last_name` FROM soft_uni.`employees`
WHERE `department_id` != 4;

#14. Sort Employees Table
SELECT * FROM soft_uni.`employees`
ORDER BY `salary` DESC, `first_name` ASC, `last_name` DESC, `middle_name` ASC;

#15. Create View Employees with Salaries
CREATE VIEW `v_employees_salaries` as SELECT `first_name`, `last_name`, `salary` FROM soft_uni.`employees`;

#16. Create View Employees with Job Titles
CREATE VIEW `v_employees_job_titles` AS SELECT concat_ws(' ', `first_name`, ifnull(`middle_name`, ''), `last_name`) AS `full_name`, `job_title`
FROM soft_uni.`employees`;

#17. Distinct Job Titles
SELECT DISTINCT `job_title` AS `Job_title` FROM soft_uni.`employees`
ORDER BY `job_title`;

#18. Find First 10 Started Projects
SELECT * FROM `projects`
ORDER BY `start_date` ASC, `name` ASC
LIMIT 10;

#19. Last 7 Hired Employees
SELECT `first_name`, `last_name`, `hire_date` FROM soft_uni.`employees`
ORDER BY `hire_date` DESC LIMIT 7;

#20. Increase Salaries
UPDATE soft_uni.`employees`
SET `salary` = `salary` + (`salary` * 0.12)
WHERE `department_id` = 1 OR `department_id` = 2 or `department_id` = 4 or `department_id` = 11;
SELECT `salary` FROM soft_uni.`employees`;