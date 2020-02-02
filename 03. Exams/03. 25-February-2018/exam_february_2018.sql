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
#03. Update
#04. Delete
#Section 3: Querying
#05. Users
#06. Lucky Numbers
#07. Heavy HTML
#08. IssuesAndUsers
#09. NonDirectoryFiles
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