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

#06. Root Categories
SELECT c.`id`, c.`name`
FROM `categories` AS `c`
WHERE c.`parent_id` IS NULL;

#07. Well Tested Problems
SELECT p.`id`, p.`name`, p.`tests`
FROM `problems` AS `p`
WHERE p.`tests` > p.`points` AND p.`name` LIKE '% %'
ORDER BY p.`id` DESC;

#08. Full Path Problems
SELECT p.`id`, concat_ws(' - ', c.`name`, ct.`name`, p.`name`) AS `full_path`
FROM `problems` AS `p`
JOIN `contests` `ct` ON `p`.`contest_id` = `ct`.`id`
JOIN `categories` `c` ON `ct`.`category_id` = `c`.`id`
ORDER BY p.`id`;

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

#12. Most Valuable Person
SELECT s.`id`, u.`username`, p.`name`, concat(s.`passed_tests`, ' / ', p.`tests`)
FROM `submissions` AS `s`
JOIN `users` `u` ON `s`.`user_id` = `u`.`id`
JOIN `problems` `p` ON `s`.`problem_id` = `p`.`id`
WHERE u.id = (SELECT uc.`user_id`
            FROM `users_contests` AS `uc`
            GROUP BY uc.`user_id`
            ORDER BY count(uc.`contest_id`) DESC
            LIMIT 1)
ORDER BY s.`id` DESC;

#13. Contests Maximum Points
SELECT ct.`id`, ct.`name`, sum(p.`points`) as `maximum_points`
FROM `contests` AS `ct`
JOIN `problems` `p` ON `ct`.`id` = `p`.`contest_id`
GROUP BY ct.`id`
ORDER BY `maximum_points` DESC, ct.`id`;

#14. Contestants Submissions
SELECT ct.`id`, ct.`name`, count(s.`id`) as `submissions`
FROM `contests` AS `ct`
JOIN `problems` `p` ON `ct`.`id` = `p`.`contest_id`
JOIN `submissions` `s` ON `p`.`id` = `s`.`problem_id`
JOIN `users_contests` `uc` ON `ct`.`id` = `uc`.`contest_id`
WHERE s.`user_id` = uc.`user_id`
GROUP BY ct.`id`
ORDER BY `submissions` DESC, ct.`id`;

#Section 4: Programmability
#15. Login
CREATE PROCEDURE `udp_login` (`username` VARCHAR(255), `password` VARCHAR(255))
BEGIN
    IF ((SELECT u.`username` FROM `users` AS `u` WHERE u.`username` = `username`) IS NULL )
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Username does not exist!';
    ELSEIF ((SELECT u.`password` FROM `users` AS `u` WHERE u.`username` = `username`) != `password`)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Password is incorrect!';
    ELSEIF ((SELECT l.`username` FROM `logged_in_users` AS `l` WHERE l.`username` = `username`) IS NOT NULL )
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'User is already logged in!';
    ELSE
        INSERT INTO `logged_in_users` (`id`, `username`, `password`, `email`)
        SELECT u.`id`, u.`username`, u.`password`, u.`email`
            FROM `users` AS `u`
            WHERE u.`username` = `username`;
    END IF;
END;

#16. Evaluate Submission
CREATE PROCEDURE `udp_evaluate` (`input_id` INT)
BEGIN
    IF ((SELECT s.`id` FROM `submissions` AS `s` WHERE s.`id` = `input_id`) IS NULL )
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Submission does not exist!';
    END IF;

    INSERT INTO `evaluated_submissions` (`id`, `problem`, `user`, `result`)
    SELECT s.`id`, p.`name`, u.`username`,
           ceil(p.`points` / p.`tests` * s.`passed_tests`) as `result`
    FROM `submissions` AS `s`
    JOIN `problems` `p` ON `s`.`problem_id` = `p`.`id`
    JOIN `users` `u` ON `s`.`user_id` = `u`.`id`
    WHERE s.`id` = `input_id`;
END;

#Section 5: Bonus
#17. Check Constraint
CREATE TRIGGER `bonus`
BEFORE INSERT ON `problems`
FOR EACH ROW
BEGIN
    IF (`NEW`.`name` NOT LIKE '% %')
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The given name is invalid!';
    ELSEIF (NEW.points <= 0)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The problem\'s points cannot be less or equal to 0!';
    ELSEIF (NEW.tests <= 0)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The problem\'s tests cannot be less or equal to 0!';
    END IF;
END;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */