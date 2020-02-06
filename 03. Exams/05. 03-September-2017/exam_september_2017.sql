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

#06. Cheaters
SELECT u.`id`, u.`username`
FROM `users` AS `u`
JOIN `users_followers` `uf` ON `u`.`id` = `uf`.`user_id`
WHERE uf.`user_id` = uf.`follower_id`
ORDER BY u.`id`;

#07. High Quality Pictures
SELECT p.`id`, p.`path`, p.`size`
FROM `pictures` AS `p`
WHERE p.`size` > 50000 AND (p.`path` LIKE '%.jpeg' OR p.`path` LIKE '%.png')
ORDER BY p.`size` DESC;

#08. Comments and Users
SELECT c.`id`, concat(u.`username`, ' : ', c.`content`) as `full_comment`
FROM `comments` AS `c`
JOIN `users` `u` ON `c`.`user_id` = `u`.`id`
ORDER BY c.`id` DESC;

#09. Profile Pictures
SELECT u.`id`, u.`username`, concat(p.`size`, 'KB') as `size`
FROM `users` AS `u`
JOIN `pictures` `p` ON `u`.`profile_picture_id` = `p`.`id`
WHERE (
    SELECT count(u.`profile_picture_id`)
    FROM `users` AS `u2`
    WHERE u.`profile_picture_id` = u2.`profile_picture_id`) > 1
ORDER BY u.`id`;

#10. Spam Posts
SELECT p.`id`, p.`caption`, count(c.`post_id`) AS `comments`
FROM `posts` AS `p`
LEFT JOIN `comments` `c` ON `p`.`id` = `c`.`post_id`
GROUP BY p.`id`
ORDER BY `comments` DESC, p.`id`
LIMIT 5;

#11. Most Popular User
SELECT u.`id`, u.`username`, COUNT(u.id) AS `posts`,
    (SELECT COUNT(uf.`follower_id`)
    FROM `users_followers` AS `uf`
	WHERE u.`id` = uf.`user_id`) AS `followers`
FROM `users` AS `u`
JOIN `posts` AS `p` ON `p`.`user_id` = `u`.`id`
GROUP BY u.`id`
ORDER BY followers DESC
LIMIT 1;

#12. Commenting Myself
SELECT u.`id`, u.`username`, count(c.`id`) AS `my_comments`
FROM `users` AS `u`
LEFT JOIN `posts` `p` ON `u`.`id` = `p`.`user_id`
LEFT JOIN `comments` `c` ON `u`.`id` = `c`.`user_id` AND c.`post_id` = p.`id`
GROUP BY u.`id`
ORDER BY `my_comments` DESC, u.`id`;

#13. User Top Posts
SELECT u.`id`, u.`username`, `top_comment`.`caption`
FROM
    (SELECT p.`id`, p.`caption`, count(c.`post_id`) AS `comments`, p.`user_id`
    FROM `posts` AS `p`
    LEFT JOIN `comments` `c` ON `p`.`id` = `c`.`post_id`
    GROUP BY p.`id`
    ORDER BY `comments` DESC, p.`id`) as `top_comment`
JOIN `users` `u` ON u.`id` = `top_comment`.`user_id`
GROUP BY u.`id`
ORDER BY u.`id`;

#14. Posts and Commentators
SELECT p.`id`, p.`caption`, count(DISTINCT c.`user_id`) as `users`
FROM `posts` AS `p`
LEFT JOIN `comments` `c` ON `p`.`id` = `c`.`post_id`
GROUP BY p.`id`
ORDER BY `users` DESC, p.`id`;

#Section 4: Programmability
#15. Post
DELIMITER ;;
CREATE PROCEDURE `udp_post` (`username` VARCHAR(255), `password` VARCHAR(255), `caption` VARCHAR(255), `path` VARCHAR(255))
BEGIN
    IF ((SELECT u.`password` FROM `users` AS `u`
        WHERE u.`username` = `username`) != `password`)
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Password is incorrect!';
    ELSEIF ((SELECT p.`path` FROM `pictures` AS `p`
        WHERE p.`path` = `path`) IS NULL )
        THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'The picture does not exist!';
    ELSE
        INSERT INTO `posts` (`caption`, `user_id`, `picture_id`)
        SELECT `caption`,
               (SELECT u.`id` FROM `users` AS `u`
               WHERE u.`username` = `username`) AS `user_id`,
               (SELECT p.`id` FROM `pictures` AS `p`
                   WHERE p.`path` = `path`) AS `picture_id`;
    END IF ;
END ;;
DELIMITER ;

#16. Filter
DELIMITER ;;
CREATE PROCEDURE `udp_filter` (`hashtag` VARCHAR(255))
BEGIN
    SELECT p.`id`, p.`caption`, u.`username`
    FROM `posts` AS `p`
    JOIN `users` `u` ON `p`.`user_id` = `u`.`id`
    WHERE p.`caption` LIKE (concat('%', `hashtag`, '%'))
    ORDER BY p.`id`;
END ;;
DELIMITER ;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */