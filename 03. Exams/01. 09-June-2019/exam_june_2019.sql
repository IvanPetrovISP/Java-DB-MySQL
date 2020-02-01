#Database Basics MySQL Exam - 9 June 2019
CREATE SCHEMA `bank`;
USE `bank`;

#Section 1: Data Definition Language (DDL)
#01. Table Design
CREATE TABLE `branches` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(20) NOT NULL,
    `last_name` VARCHAR(20) NOT NULL,
    `salary` DECIMAL(10, 2) NOT NULL,
    `started_on` DATE NOT NULL,
    `branch_id` INT NOT NULL,
    CONSTRAINT `fk_employees_branches`
        FOREIGN KEY (`branch_id`)
            REFERENCES `branches`(`id`)
);

CREATE TABLE `clients` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    `age` INT NOT NULL
);

CREATE TABLE `employees_clients` (
    `employee_id` INT,
    `client_id` INT,
    KEY `pk_employees_clients`(`employee_id`, `client_id`),
    CONSTRAINT `fk_employees_clients_employees`
        FOREIGN KEY (`employee_id`)
            REFERENCES `employees`(`id`),
    CONSTRAINT `fk_employees_clients_clients`
        FOREIGN KEY (`client_id`)
            REFERENCES `clients`(`id`)
);

CREATE TABLE `bank_accounts` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `account_number` VARCHAR(10) NOT NULL,
    `balance` DECIMAL(10, 2) NOT NULL,
    `client_id` INT NOT NULL UNIQUE,
    CONSTRAINT `fk_bank_accounts_clients`
        FOREIGN KEY (`client_id`)
            REFERENCES `clients`(`id`)
);

CREATE TABLE `cards` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `card_number` VARCHAR(19) NOT NULL,
    `card_status` VARCHAR(7) NOT NULL,
    `bank_account_id` INT NOT NULL,
    CONSTRAINT `fk_cards_bank_account_id`
        FOREIGN KEY (`bank_account_id`)
            REFERENCES `bank_accounts`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#02. Insert
INSERT INTO `cards` (`card_number`, `card_status`, `bank_account_id`)
SELECT reverse(`full_name`) AS `name`, 'Active' AS `status`, `id` FROM `clients`
WHERE `id` >= 191 AND `id` <= 200;

#03. Update
UPDATE `employees_clients` AS `ec`
JOIN (
    SELECT `ec2`.`employee_id` FROM `employees_clients` AS `ec2`
    GROUP BY ec2.`employee_id`
    ORDER BY count(ec2.`client_id`), ec2.`employee_id`
    LIMIT 1) AS `result`
SET ec.`employee_id` = `result`.employee_id
WHERE ec.`employee_id` = ec.`client_id`;

#04. Delete
DELETE FROM `employees`
WHERE `id` NOT IN (SELECT ec.`employee_id` FROM `employees_clients` AS `ec`);

#Section 3: Querying
#05. Clients
SELECT c.`id`, c.`full_name` FROM `clients` AS `c`
ORDER BY c.`id`;

#06. Newbies
SELECT e.`id`, concat(e.`first_name`, ' ', e.`last_name`) as `full_name`, concat('$', e.`salary`) AS `salary`, e.`started_on`
FROM `employees` AS `e`
WHERE e.`salary` >= 100000 AND e.`started_on` > '2018-01-01'
ORDER BY e.`salary` DESC , e.`id`;

#07. Cards against Humanity
SELECT c.`id`, concat(c.`card_number`, ' : ', cl.`full_name`) as `card_token`
FROM `cards` AS `c`
JOIN `bank_accounts` `ba` ON `c`.`bank_account_id` = `ba`.`id`
JOIN `clients` `cl` ON `ba`.`client_id` = `cl`.`id`
ORDER BY c.`id` DESC;

#08. Top 5 Employees
SELECT concat(e.`first_name`, ' ', e.`last_name`) as `full_name`, e.`started_on`, count(ec.`client_id`) AS `count_of_clients`
FROM `employees` AS `e`
JOIN `employees_clients` `ec` ON `e`.`id` = `ec`.`employee_id`
GROUP BY e.`id`
ORDER BY `count_of_clients` DESC, e.`id`
LIMIT 5;

#09. Branch cards
SELECT b.`name`, count(c.`id`) AS `count_of_cards` FROM `branches` AS `b`
LEFT JOIN `employees` `e` ON `b`.`id` = `e`.`branch_id`
LEFT JOIN `employees_clients` `ec` ON `e`.`id` = `ec`.`employee_id`
LEFT JOIN `bank_accounts` `b2` ON `ec`.`client_id` = `b2`.`client_id`
LEFT JOIN `cards` `c` ON `b2`.`id` = `c`.`bank_account_id`
GROUP BY b.`name`
ORDER BY `count_of_cards` DESC, b.`name`;

#Section 4: Programmability
#10. Extract card's count
DELIMITER ;;
CREATE FUNCTION `udf_client_cards_count` (`name` VARCHAR(30))
RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `cards_count` INT;
    SET `cards_count` = (
        SELECT count(c.`id`) as `result`
        FROM `clients` AS `cl`
        JOIN `bank_accounts` `ba` ON `cl`.`id` = `ba`.`client_id`
        JOIN `cards` `c` ON `ba`.`id` = `c`.`bank_account_id`
        WHERE cl.`full_name` = `name`
        GROUP BY cl.`full_name`);
    RETURN `cards_count`;
END ;;
DELIMITER ;

#11. Client Info
DELIMITER ;;
CREATE PROCEDURE `udp_clientinfo` (`full_name` VARCHAR(50))
BEGIN
SELECT cl.`full_name`, cl.`age`, ba.`account_number`, concat('$', ba.`balance`) as `balance`
    FROM `clients` AS `cl`
    JOIN `bank_accounts` `ba` ON `cl`.`id` = `ba`.`client_id`
    WHERE cl.`full_name` = `full_name`;
END ;;
DELIMITER ;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */