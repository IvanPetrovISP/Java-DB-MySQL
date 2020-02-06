#Database Basics MySQL Exam - 25 February 2018
CREATE SCHEMA `buhtig`;
USE `buhtig`;

#Section 1: Data Definition Language (DDL)
#01. Table Design
CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NOT NULL
);

CREATE TABLE `repositories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `repositories_contributors` (
    `repository_id` INT,
    `contributor_id` INT,
    KEY `k_repositories_contributors` (`repository_id`, `contributor_id`),
    CONSTRAINT `fk_rc_repositories`
        FOREIGN KEY (`repository_id`)
            REFERENCES `repositories`(`id`),
    CONSTRAINT `fk_rc_contributors`
        FOREIGN KEY (`contributor_id`)
            REFERENCES `users`(`id`)
);

CREATE TABLE `issues` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(255) NOT NULL,
    `issue_status` VARCHAR(6) NOT NULL,
    `repository_id` INT NOT NULL,
    `assignee_id` INT NOT NULL,
    CONSTRAINT `fk_issues_repositories`
        FOREIGN KEY (`repository_id`)
            REFERENCES `repositories`(`id`),
    CONSTRAINT `fk_issues_users`
        FOREIGN KEY (`assignee_id`)
            REFERENCES `users`(`id`)
);

CREATE TABLE `commits` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `message` VARCHAR(255) NOT NULL,
    `issue_id` INT,
    `repository_id` INT NOT NULL,
    `contributor_id` INT NOT NULL,
    CONSTRAINT `fk_commits_issues`
        FOREIGN KEY (`issue_id`)
            REFERENCES `issues`(`id`),
    CONSTRAINT `fk_commits_repositories`
        FOREIGN KEY (`repository_id`)
            REFERENCES `repositories`(`id`),
    CONSTRAINT `fk_commits_users`
        FOREIGN KEY (`contributor_id`)
            REFERENCES `users`(`id`)
);

CREATE TABLE `files` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL,
    `size` DECIMAL(10, 2) NOT NULL,
    `parent_id` INT,
    `commit_id` INT NOT NULL,
    CONSTRAINT `fk_files_files`
        FOREIGN KEY (`parent_id`)
            REFERENCES `files` (`id`),
    CONSTRAINT `fk_files_commits`
        FOREIGN KEY (`commit_id`)
            REFERENCES `commits`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#02. Insert
INSERT INTO `issues` (`title`, `issue_status`, `repository_id`, `assignee_id`)
SELECT concat('Critical Problem With ', f.`name`, '!'),
       'open', ceil((f.`id` * 2) / 3), c.`contributor_id`
FROM `files` as `f`
JOIN `commits` `c` ON `f`.`commit_id` = `c`.`id`
WHERE f.`id` >= 46 and f.`id` <=50;

#03. Update
UPDATE `repositories_contributors` AS `rc`
JOIN (
    SELECT r.`id` AS 'result'
    FROM `repositories` AS `r`
    WHERE r.`id` NOT IN (
        SELECT `repository_id`
        FROM `repositories_contributors`)
    ORDER BY r.`id`
    LIMIT 1) AS `d`
SET rc.`repository_id` = d.`result`
WHERE rc.`contributor_id` = rc.`repository_id`;

#04. Delete
DELETE FROM `repositories`
WHERE `id` NOT IN (SELECT i.`repository_id` FROM `issues` as `i` );

#Section 3: Querying
#05. Users
SELECT `id`, `username`
FROM `users`
ORDER BY `id`;

#06. Lucky Numbers
SELECT `repository_id`, `contributor_id`
FROM `repositories_contributors`
WHERE `repository_id` = `contributor_id`
ORDER BY repository_id;

#07. Heavy HTML
SELECT id, `name`, `size`
FROM `files`
WHERE `size` > 1000 AND name LIKE '%html%'
ORDER BY `size` DESC;

#08. IssuesAndUsers
SELECT i.`id`, concat(u.`username`, ' : ', i.`title`) AS `issue_assignee`
FROM `issues` AS `i`
JOIN `users` `u` ON `i`.`assignee_id` = `u`.`id`
ORDER BY i.id DESC;

#09. NonDirectoryFiles
SELECT f.`id`, f.`name` as `Name`, concat(f.`size`, 'KB') as `size` FROM `files` AS `f`
LEFT JOIN `files` `f2` ON f.`id` = `f2`.`parent_id`
WHERE f2.`parent_id` IS NULL
ORDER BY f.`id`;

#10. ActiveRepositories
SELECT r.`id`, r.`name`, count(r.`id`) as `issues`
FROM `repositories` AS `r`
JOIN `issues` `i` ON `r`.`id` = `i`.`repository_id`
GROUP BY r.`id`
ORDER BY `issues` DESC, r.`id`
LIMIT 5;

#11. MostContributedRepository
SELECT r.`id`, r.`name`,
       (SELECT count(c.`id`) FROM `commits` as `c`
           WHERE c.`repository_id` = r.`id`) AS `commits`,
       (SELECT count(rc.`contributor_id`) FROM `repositories_contributors` AS `rc`
       WHERE rc.`repository_id` = r.`id`) as `contributors`
FROM `repositories` AS `r`
WHERE r.`id` =
      (SELECT r.`repository_id` FROM `repositories_contributors` AS `r`
       GROUP BY r.`repository_id`
       ORDER BY count(r.`contributor_id`)
       DESC, `repository_id`
       LIMIT 1);

#12. FixingMyOwnProblems
SELECT u.`id`, u.`username`, sum(
    if(c.`contributor_id` = u.`id`, 1, 0)) AS `commits`
FROM `users` AS `u`
LEFT JOIN `issues` `i` ON `u`.`id` = `i`.`assignee_id`
LEFT JOIN `commits` `c` ON `i`.`id` = `c`.`issue_id`
GROUP BY u.`id`
ORDER BY `commits` DESC, u.`id`;

#13. RecursiveCommits
SELECT substring(f.`name`, 1, locate('.', f.`name`)-1) as `file`,
       count(nullif(locate(f.`name`, c.`message`), 0)) AS `recursive_count`
FROM `files` AS `f`
JOIN `files` `f2` ON f.`parent_id` = `f2`.`id`
JOIN `commits` `c`
WHERE f2.`id` = f.`parent_id` AND  f.`id` = f2.`parent_id` and f.`id` != f.`parent_id`
GROUP BY `file`
ORDER BY `file`;

#14. RepositoriesAndCommits
SELECT r.`id`, r.`name`, count(DISTINCT c.`contributor_id`)AS `users`
FROM `repositories` AS `r`
LEFT JOIN `commits` `c` ON `r`.`id` = `c`.`repository_id`
GROUP BY r.`id`
ORDER BY `users` DESC, r.`id`;

#Section 4: Programmability
#15. Commit
DELIMITER ;;
CREATE PROCEDURE `udp_commit` (`username` VARCHAR(255), `password` VARCHAR(255), `message` VARCHAR(255), `issue_id` INT)
BEGIN
    DECLARE `counter` INT;
    SET `counter` = 0;
    IF ((SELECT count(u.`username`) as `count`
        FROM `users` AS `u`
        WHERE u.`username` = `username`) > 0)
    THEN
        SET `counter` = `counter` + 1;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No such user!';
    END IF;
    IF ((SELECT u.`password`
        FROM `users` AS `u`
        WHERE u.`username` = `username`) = `password`)
    THEN
        SET `counter` = `counter` + 1;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password is incorrect!';
    END IF;
    IF ((SELECT count(i.`id`) as `count`
        FROM `issues` AS `i`
        WHERE i.`id` = `issue_id`) > 0)
    THEN
        SET `counter` = `counter` + 1;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'The issue does not exist!';
    END IF;
    IF (`counter` = 3)
    THEN
        INSERT INTO `commits` (`message`, `issue_id`, `repository_id`, `contributor_id`)
        VALUES (`message`, `issue_id`,
                (SELECT i.`repository_id` FROM `issues` AS `i`
                    WHERE i.`id` = `issue_id`),
                (SELECT u.`id` FROM `users` AS `u`
                    WHERE u.`username` = `username`));
        UPDATE `issues` AS `i`
        SET i.`issue_status` = 'closed'
        WHERE i.`id` = `issue_id`;
    END IF ;
END ;;
DELIMITER ;

#16. Filter Extensions
DELIMITER ;;
CREATE PROCEDURE `udp_findbyextension` (`extension` VARCHAR(255))
BEGIN
    SELECT f.`id`, f.`name` AS `caption`, concat(f.`size`, 'KB') AS `user`
    FROM `files` AS `f`
    WHERE f.name LIKE (CONCAT('%', `extension`))
    ORDER BY f.`id`;
END ;;
DELIMITER ;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */