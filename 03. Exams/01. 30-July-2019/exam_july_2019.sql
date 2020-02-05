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
UPDATE `comments` AS `c`
SET `c`.`comment` =
    (CASE
        WHEN c.`id` % 2 = 0 THEN 'Very good article.'
        WHEN c.`id` % 3 = 0 THEN 'This is interesting.'
        WHEN c.`id` % 5 = 0 THEN 'I definitely will read the article again.'
        WHEN c.`id` % 7 = 0 THEN 'The universe is such an amazing thing.'
        ELSE c.`comment`
    END)
WHERE c.`id` BETWEEN 1 AND 15;

#04. Delete
DELETE FROM `articles`
WHERE `category_id` IS NULL;

#Section 3: Querying
#05. Extract 3 biggest articles
SELECT `filtered`.`title`, `filtered`.`summary`
FROM (
    SELECT a.`id`, a.`title`, concat(substr(a.`content`, 1, 20), '...') as `summary`
    FROM `articles` AS `a`
    ORDER BY length(a.`content`) DESC
    LIMIT 3) as `filtered`
ORDER BY `filtered`.`id`;

#06. Golden articles
SELECT ua.`article_id`, a.`title`
FROM `users_articles` AS `ua`
JOIN `articles` `a` ON `ua`.`article_id` = `a`.`id`
WHERE ua.`article_id` = ua.`user_id`;

#07. Extract categories
SELECT DISTINCT c.`category`, count(a.`category_id`) as `articles`,
       (SELECT count(l.`article_id`)
        FROM `likes` AS `l`
        JOIN `articles` `a2` ON `l`.`article_id` = `a2`.`id`
        JOIN `categories` `c2` ON `a2`.`category_id` = `c2`.`id`
        WHERE c2.`id` = c.`id`) as `likes`
FROM `categories` AS `c`
JOIN `articles` `a` ON `c`.`id` = `a`.`category_id`
GROUP BY c.`category`, `likes`, c.`id`
ORDER BY `likes` DESC, `articles` DESC, c.`id`;

#08. Extract the most commented social article
SELECT a.`title`, count(c.`article_id`) as `comments`
FROM `comments` AS `c`
JOIN `articles` `a` ON `c`.`article_id` = `a`.`id`
WHERE a.`category_id` = 5
GROUP BY `article_id`
ORDER BY `comments` DESC
LIMIT 1;

#09. Extract the less liked comments
SELECT concat(substring(c.`comment`, 1, 20), '...') as `summary`
FROM `comments` AS `c`
WHERE c.`id` NOT IN (
    SELECT l.`comment_id`
    FROM `likes` AS `l`
    WHERE l.`article_id` IS NULL)
ORDER BY c.`id` DESC;

#Section 4: Programmability
#10. Get users articles count
DELIMITER ;;
CREATE FUNCTION `udf_users_articles_count` (`username` VARCHAR(30))
RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `result` INT;
    SET `result` = (SELECT count(ua.`article_id`)
        FROM `users_articles` AS `ua`
    JOIN `users` `u` ON `ua`.`user_id` = `u`.`id`
    WHERE u.`username` = `username`);
    RETURN `result`;
END ;;
DELIMITER ;

#11. Like Article
DELIMITER ;;
CREATE PROCEDURE `udp_like_article` (`username` VARCHAR(30), `title` VARCHAR(30))
BEGIN
    IF ((SELECT u.`username` FROM `users` AS `u` WHERE u.`username` = `username`) IS NULL)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non-existent user.';
    ELSEIF ((SELECT a.`title` FROM `articles` AS `a` WHERE a.`title` = `title`) IS NULL)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Non-existent article.';
    ELSE
        INSERT INTO `likes` (`article_id`, `comment_id`, `user_id`)
        SELECT (SELECT a.`id` FROM `articles` AS `a` WHERE a.`title` = `title`) AS `article_id`,
               NULL AS `comment_id`,
               (SELECT u.`id` FROM `users` AS `u` WHERE u.`username` = `username`) AS `user_id`;
    END IF;
END ;;
DELIMITER ;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */