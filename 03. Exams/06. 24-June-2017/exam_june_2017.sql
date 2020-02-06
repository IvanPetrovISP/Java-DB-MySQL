#Databases MySQL Exam - 24 Jun 2017
CREATE SCHEMA `closed_judge_system`;
USE `closed_judge_system`;

#Section 1: Data Definition Language (DDL)
#01. Table Design
CREATE TABLE `users` (
    `id` INT PRIMARY KEY,
    `username` VARCHAR(30) NOT NULL,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NULL
);

CREATE TABLE `categories` (
    `id` INT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `parent_id` INT,
    CONSTRAINT `fk_categories_categories`
        FOREIGN KEY (`parent_id`)
            REFERENCES `categories`(`id`)
);

CREATE TABLE `contests`(
    `id` INT PRIMARY KEY,
    `name` VARCHAR(50) NOT NULL,
    `category_id` INT,
    CONSTRAINT `fk_contests_categories`
        FOREIGN KEY (`category_id`)
            REFERENCES `categories`(`id`)
);

CREATE TABLE `problems` (
    `id` INT PRIMARY KEY,
    `name` VARCHAR(100) NOT NULL,
    `points` INT NOT NULL,
    `tests` INT DEFAULT 0,
    `contest_id` INT,
    CONSTRAINT `fk_problems_contests`
        FOREIGN KEY (`contest_id`)
            REFERENCES `contests`(`id`)
);

CREATE TABLE `submissions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `passed_tests` INT NOT NULL,
    `problem_id` INT,
    `user_id` INT,
    CONSTRAINT `fk_submissions_problems`
        FOREIGN KEY (`problem_id`)
            REFERENCES `problems`(`id`),
    CONSTRAINT `fk_submissions_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`)
);

CREATE TABLE `users_contests` (
    `user_id` INT,
    `contest_id` INT,
    CONSTRAINT `pk_users_contests`
        PRIMARY KEY (`user_id`, `contest_id`),
    CONSTRAINT `fk_uc_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`),
    CONSTRAINT `fk_uc_contests`
        FOREIGN KEY (`contest_id`)
            REFERENCES `contests`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#02. Insert
INSERT INTO `submissions` (`passed_tests`, `problem_id`, `user_id`)
SELECT ceil((sqrt(power(length(p.`name`), 3))) - length(p.`name`)),
       p.`id`,
       ceil((p.`id` * 3) /2)
FROM `problems` AS `p`
WHERE p.`id` BETWEEN 1 AND 10;

#03. Update
#04. Delete
#Section 3: Querying

#09. Leaf Categories
SELECT c.`id`, c.`name`
FROM `categories` AS `c`
LEFT JOIN `categories` AS `c2` ON c2.`parent_id` = c.`id`
WHERE c2.`parent_id` is NULL
ORDER BY c.`name`, c.`id`

#Section 4: Programmability

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */