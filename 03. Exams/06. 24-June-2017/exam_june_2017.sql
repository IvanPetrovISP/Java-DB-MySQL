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
UPDATE `problems` AS `p`
JOIN `contests` `ct` ON `p`.`contest_id` = `ct`.`id`
JOIN `categories` `c` ON `ct`.`category_id` = `c`.`id`
SET p.tests =
    CASE
        WHEN p.id % 3 = 0 THEN length(c.`name`)
        WHEN p.id % 3 = 1 THEN (SELECT sum(s.id)
                    FROM `submissions` AS `s`
                    WHERE `s`.`problem_id` = `p`.`id`)
        WHEN p.id % 3 = 2 THEN length(ct.name)
    END
WHERE p.tests = 0;

#04. Delete
DELETE FROM `users` AS `u`
WHERE u.`id` NOT IN (SELECT uc.`user_id` FROM `users_contests` AS `uc` );

#Section 3: Querying
#05. Users
SELECT u.`id`, u.`username`, u.`email`
FROM `users` AS `u`
ORDER BY u.`id`;

#09. Leaf Categories
SELECT c.`id`, c.`name`
FROM `categories` AS `c`
LEFT JOIN `categories` AS `c2` ON c2.`parent_id` = c.`id`
WHERE c2.`parent_id` is NULL
ORDER BY c.`name`, c.`id`;

#10. Mainstream Passwords
SELECT u.`id`, u.`username`, u.`password`
FROM `users` AS `u`
WHERE u.`password` IN (SELECT u.`password` FROM `users` `u`
                      GROUP BY u.`password`
                      HAVING COUNT(u.`password`) > 1)
ORDER BY u.`username`, u.`id`;

#11. Most Participated Contests
SELECT `filtered`.`id`, `filtered`.`name`, `filtered`.`count`
from (SELECT ct.`id`, ct.`name`, count(uc.`user_id`) as `count`
        FROM `contests` AS `ct`
        LEFT JOIN `users_contests` `uc` ON `ct`.`id` = `uc`.`contest_id`
        GROUP BY uc.`contest_id`
        ORDER BY `count` DESC
        LIMIT 5) AS `filtered`
ORDER BY `filtered`.`count`, `filtered`.`id`;

#Section 4: Programmability

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */