#01. Employees with Salary Above 35000
CREATE PROCEDURE `usp_get_employees_salary_above_35000` ()
BEGIN
    SELECT e.`first_name`, e.`last_name`
    FROM `employees` AS `e`
    WHERE e.`salary` > 35000
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END;

CALL `usp_get_employees_salary_above_35000`();

#02. Employees with Salary Above Number
CREATE PROCEDURE `usp_get_employees_salary_above` (`salary` DECIMAL)
BEGIN
    SELECT e.`first_name`, e.`last_name`
    FROM `employees` AS `e`
    WHERE e.`salary` >= `salary`
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END;

CALL `usp_get_employees_salary_above`(48100);

#03. Town Names Starting With
CREATE PROCEDURE `usp_get_towns_starting_with` (`prefix` VARCHAR(255))
BEGIN
    SELECT t.`name` AS `town_name`
    FROM `towns` as `t`
    WHERE t.`name` LIKE (concat(`prefix`, '%'))
    ORDER BY t.`name`;
END;

CALL `usp_get_towns_starting_with`('b');

#04. Employees from Town
CREATE PROCEDURE `usp_get_employees_from_town` (`town_name` VARCHAR(255))
BEGIN
    SELECT e.`first_name`, e.`last_name`
    FROM `employees` AS `e`
    JOIN `addresses` `a` ON e.`address_id` = a.`address_id`
    JOIN `towns` `t` ON `a`.`town_id` = `t`.`town_id`
    WHERE t.`name` = `town_name`
    ORDER BY e.`first_name`, e.`last_name`, e.`employee_id`;
END;

CALL `usp_get_employees_from_town`('Sofia');

#05. Salary Level Function
CREATE FUNCTION `ufn_get_salary_level` (`salary` DOUBLE)
RETURNS VARCHAR(255)
BEGIN
    DECLARE `result` VARCHAR(255);
    SET `result` =
        CASE
            WHEN `salary` < 30000 THEN 'Low'
            WHEN `salary` <= 50000 THEN 'Average'
            ELSE 'High'
            END;
    RETURN `result`;
END;

#06. Employees by Salary Level
