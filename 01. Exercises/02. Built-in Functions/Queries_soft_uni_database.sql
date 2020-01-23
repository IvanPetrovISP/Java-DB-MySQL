#01. Find Names of All Employees by First Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE left(`first_name`, 2) = 'Sa'
ORDER BY `employee_id`;

#02. Find Names of All Employees by Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE locate('ei', `last_name`)
ORDER BY `employee_id`;

#03. Find First Names of All Employess
SELECT `first_name` FROM `employees`
WHERE `department_id` IN (3, 10) AND `hire_date` BETWEEN '1995-01-01' AND '2005-12-31'
ORDER BY `employee_id`;

#04. Find All Employees Except Engineers
SELECT `first_name`, `last_name` FROM `employees`
WHERE locate('engineer', `job_title`) is FALSE
ORDER BY `employee_id`;

#05. Find Towns with Name Length
SELECT `name` FROM `towns`
WHERE char_length(`name`) in (5, 6)
ORDER BY `name`;

#06. Find Towns Starting With
SELECT `town_id`,`name` FROM `towns`
WHERE lower(left(`name`, 1)) IN ('m', 'k', 'b', 'e')
ORDER BY `name`;

#07. Find Towns Not Starting With
SELECT `town_id`,`name` FROM `towns`
WHERE lower(left(`name`, 1)) IN ('r', 'b', 'd') is FALSE
ORDER BY `name`;

#08. Create View Employees Hired After
CREATE VIEW `v_employees_hired_after_2000` AS SELECT `first_name`, `last_name` FROM `employees`
WHERE `hire_date` > '2000-12-31';

#09. Length of Last Name
SELECT `first_name`, `last_name` FROM `employees`
WHERE char_length(`last_name`) = 5;