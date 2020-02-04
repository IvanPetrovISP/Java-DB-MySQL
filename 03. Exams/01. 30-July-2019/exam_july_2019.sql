#MySQL Retake Exam - 30 July 2019
CREATE SCHEMA `colonial_blog_db`;
USE `colonial_blog_db`;

#Section 1: Data Definition Language (DDL)
#01. Table Design
CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    `email` VARCHAR(50) NOT NULL
);

CREATE TABLE `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `category` VARCHAR(30) NOT NULL
);

CREATE TABLE `articles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `title` VARCHAR(50) NOT NULL,
    `content` TEXT NOT NULL,
    `category_id` INT,
    CONSTRAINT `fk_articles_categories`
        FOREIGN KEY (`category_id`)
            REFERENCES `categories`(`id`)
);

CREATE TABLE `users_articles` (
    `user_id` INT,
    `article_id` INT,
    CONSTRAINT `fk_ua_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`),
    CONSTRAINT `fk_ua_articles`
        FOREIGN KEY (`article_id`)
            REFERENCES `articles`(`id`)
);

CREATE TABLE `comments` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `comment` VARCHAR(255) NOT NULL,
    `article_id` INT NOT NULL,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_comments_articles`
        FOREIGN KEY (`article_id`)
            REFERENCES `articles`(`id`),
    CONSTRAINT `fk_comments_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`)
);

CREATE TABLE `likes` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `article_id` INT,
    `comment_id` INT,
    `user_id` INT NOT NULL,
    CONSTRAINT `fk_likes_articles`
        FOREIGN KEY (`article_id`)
            REFERENCES `articles`(`id`),
    CONSTRAINT `fk_likes_comments`
        FOREIGN KEY (`comment_id`)
            REFERENCES `comments`(`id`),
    CONSTRAINT `fk_likes_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#02. Insert
INSERT INTO `likes` (`article_id`, `comment_id`, `user_id`)
SELECT (SELECT length(u.`username`)
        WHERE u.id % 2 = 0) AS `article_id`,
       (SELECT length(u.`email`)
        WHERE u.id %2 = 1) as `comment_id`,
       u.`id` as `user_id`
FROM `users` AS `u`
WHERE u.`id` BETWEEN 16 AND 20;

#03. Update
#04. Delete
#Section 3: Querying
#05. Extract 3 biggest articles
#06. Golden articles
#07. Extract categories
#08. Extract the most commented social article
#09. Extract the less liked comments
#Section 4: Programmability
#10. Get users articles count
#11. Like Article

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */