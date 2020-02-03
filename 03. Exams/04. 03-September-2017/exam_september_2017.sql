#Databases MySQL Retake Exam - 03 Sept 2017
CREATE SCHEMA `instagraph`;
USE `instagraph`;

#Section 1: Data Definition Language (DDL)
#01. Table Design
CREATE TABLE `pictures` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `path` VARCHAR(255) NOT NULL,
    `size` DECIMAL(10, 2) NOT NULL
);

CREATE TABLE `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `username` VARCHAR(30) NOT NULL UNIQUE,
    `password` VARCHAR(30) NOT NULL,
    `profile_picture_id` INT,
    CONSTRAINT `fk_users_pictures`
        FOREIGN KEY (`profile_picture_id`)
            REFERENCES `pictures`(`id`)
);

CREATE TABLE `posts` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `caption` VARCHAR(255) NOT NULL,
    `user_id` INT NOT NULL,
    `picture_id` INT NOT NULL,
    CONSTRAINT `fk_posts_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`),
    CONSTRAINT `fk_posts_pictures`
        FOREIGN KEY (`picture_id`)
            REFERENCES `pictures`(`id`)
);

CREATE TABLE `comments` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `content` VARCHAR(255) NOT NULL,
    `user_id` INT NOT NULL,
    `post_id` INT NOT NULL,
    CONSTRAINT `fk_comments_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`),
    CONSTRAINT `fk_comments_posts`
        FOREIGN KEY (`post_id`)
            REFERENCES `posts`(`id`)
);

CREATE TABLE `users_followers` (
    `user_id` INT,
    `follower_id` INT,
    KEY `key_users_followers` (`user_id`, `follower_id`),
    CONSTRAINT `fk_uf_users`
        FOREIGN KEY (`user_id`)
            REFERENCES `users`(`id`),
    CONSTRAINT `fk_uf_followers`
        FOREIGN KEY (`follower_id`)
            REFERENCES `users`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#02. Insert
INSERT INTO `comments` (`content`, `user_id`, `post_id`)
SELECT concat('Omg!', u.`username`, '!This is so cool!') AS `content`,
       ceil((p.`id` * 3) / 2) as `user_id`, p.`id`
FROM `posts` AS `p`
JOIN `users` `u` ON `p`.`user_id` = `u`.`id`
WHERE p.`id` BETWEEN 1 AND 10;

#03. Update
UPDATE `users` AS `u`
JOIN (
    SELECT count(u2.`follower_id`) as `followers`
    FROM `users` AS `u`
    JOIN `users_followers` `u2` ON `u`.`id` = `u2`.`user_id`
    GROUP BY u.`id`) as `result`
SET u.`profile_picture_id`  =
    IF(`result`.`followers` = 0, `u`.`id`, `result`.`followers`)
WHERE u.`profile_picture_id` IS NULL;

#04. Delete
DELETE FROM `users`
WHERE `id` = (
    SELECT u.`id` FROM (SELECT * from `users`) AS `u`
    LEFT JOIN `users_followers` `uf` ON `u`.`id` = `uf`.`user_id`
    WHERE uf.`user_id` IS NULL AND `uf`.`follower_id` IS NULL);

#Section 3: Querying
#05. Users
SELECT u.`id`, u.`username`
FROM `users` AS `u`
ORDER BY u.`id`;

#Section 4: Programmability

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */