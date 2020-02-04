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
CREATE PROCEDURE `usp_get_employees_by_salary_level` (`level` VARCHAR(255))
BEGIN
    SELECT e.`first_name`, e.`last_name`
    FROM `employees` as `e`
    WHERE
          CASE
              WHEN `level` = 'Low' THEN e.`salary` < 30000
              WHEN `level` = 'Average' THEN e.`salary` BETWEEN 30000 AND 50000
              WHEN `level` = 'High' THEN e.`salary` > 50000
              END
    ORDER BY e.`first_name` DESC, e.`last_name` DESC;
END;

CALL `usp_get_employees_by_salary_level`('high');

#07. Define Function
CREATE FUNCTION `ufn_is_word_comprised` (`set_of_letters` VARCHAR(50), word VARCHAR(50))
RETURNS BIT
    DETERMINISTIC
BEGIN
    DECLARE `regex` VARCHAR(255);
    DECLARE `result` BIT;
    SET `regex` = concat('^[', `set_of_letters`, ']+$');
    CASE
        WHEN `word` REGEXP `regex` THEN SET `result` = 1;
        ELSE SET `result` = 0;
    END CASE;
    RETURN `result`;
END;

SELECT `ufn_is_word_comprised`('oistmiahf', 'Sofia');

#08. Find Full Name
CREATE PROCEDURE `usp_get_holders_full_name` ()
BEGIN
    SELECT concat(ah.`first_name`, ' ', ah.`last_name`) AS `full_name`
    FROM `account_holders` AS `ah`
    ORDER BY `full_name`;
END;

#9. People with Balance Higher Than
CREATE PROCEDURE `usp_get_holders_with_balance_higher_than` (`balance` DOUBLE)
BEGIN
    SELECT DISTINCT ah.`first_name`, ah.`last_name`
    FROM `accounts` AS `a`
    JOIN `account_holders` `ah` ON `ah`.`id` = `a`.`account_holder_id`
    WHERE (SELECT sum(a2.`balance`) FROM `accounts` AS `a2`
            WHERE a2.`account_holder_id` = ah.`id`
            GROUP BY a2.`account_holder_id`) > `balance`
    GROUP BY a.`account_holder_id`, a.`id`
    ORDER BY a.`id`;
END;

CALL `usp_get_holders_with_balance_higher_than`(7000);

#10. Future Value Function
CREATE FUNCTION `ufn_calculate_future_value`
    (`sum` DECIMAL(20,4), `yearly_interest_rate` DECIMAL(20,4), `number_of_years` INT)
RETURNS DECIMAL(20,4)
    DETERMINISTIC
BEGIN
    DECLARE `result` DECIMAL(20,4);
    SET result := `sum` * POW(1 + `yearly_interest_rate`, `number_of_years`);
    RETURN `result`;
END;

CALL ufn_calculate_future_value(1000, 0.1, 5);

#11. Calculating Interest
CREATE PROCEDURE `usp_calculate_future_value_for_account`
	(`account_id` INT, `interest_rate` DECIMAL(20,4))
BEGIN
	SELECT a.`id`, h.`first_name`, h.`last_name`, a.`balance`,
		ufn_calculate_future_value(a.`balance`, interest_rate, 5) AS `balance_in_5_years`
	FROM `account_holders` AS `h`
    JOIN `accounts` `a` ON `a`.`account_holder_id` = `h`.`id`
	WHERE a.`id` = `account_id`
    GROUP BY a.`account_holder_id`;
END;

CALL usp_calculate_future_value_for_account(1, 0.1);

#12. Deposit Money
