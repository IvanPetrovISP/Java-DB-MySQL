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
#11. MostContributedRepository
#12. FixingMyOwnProblems
#13. RecursiveCommits
#14. RepositoriesAndCommits
#Section 4: Programmability
#15. Commit
#16. Filter Extensions

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */