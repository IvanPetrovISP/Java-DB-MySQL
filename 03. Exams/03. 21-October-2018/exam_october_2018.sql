#Database Basics MySQL Exam - 21 October 2018
CREATE SCHEMA `colonial_journey`;
USE `colonial_journey`;

#Section 1: Data Definition Language (DDL)
#00. Table Design
CREATE TABLE `planets` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(30) NOT NULL
);

CREATE TABLE `spaceports` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `planet_id` INT,
    CONSTRAINT `fk_spaceports_planets`
        FOREIGN KEY (`planet_id`)
            REFERENCES `planets`(`id`)
);

CREATE TABLE `spaceships` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `manufacturer` VARCHAR(30) NOT NULL,
    `light_speed_rate` INT DEFAULT 0
);

CREATE TABLE `colonists` (
  `id` INT PRIMARY KEY AUTO_INCREMENT,
  `first_name` VARCHAR(20) NOT NULL,
  `last_name` VARCHAR(20) NOT NULL,
  `ucn` CHAR(10) NOT NULL UNIQUE,
  `birth_date` DATE NOT NULL
);

CREATE TABLE `journeys` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `journey_start` DATETIME NOT NULL,
    `journey_end` DATETIME NOT NULL,
    `purpose` ENUM('Medical', 'Technical', 'Educational', 'Military'),
    `destination_spaceport_id` INT,
    `spaceship_id` INT,
    CONSTRAINT `fk_journey_spaceport`
        FOREIGN KEY (`destination_spaceport_id`)
            REFERENCES `spaceports`(`id`),
    CONSTRAINT `fk_journey_spaceship`
        FOREIGN KEY (`spaceship_id`)
            REFERENCES `spaceships`(`id`)
);

CREATE TABLE `travel_cards` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `card_number` CHAR(10) NOT NULL UNIQUE,
    `job_during_journey` ENUM('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook'),
    `colonist_id` INT,
    `journey_id` INT,
    CONSTRAINT `fk_travel_cards_colonists`
        FOREIGN KEY (`colonist_id`)
            REFERENCES `colonists`(`id`),
    CONSTRAINT `fk_travel_cards_journeys`
        FOREIGN KEY (`journey_id`)
            REFERENCES `journeys`(`id`)
);

#Section 2: Data Manipulation Language (DML)
#01. Insert
INSERT INTO `travel_cards` (`card_number`, `job_during_journey`, `colonist_id`, `journey_id`)
SELECT
(CASE
    WHEN `birth_date` > '1980-01-01' THEN concat(year(`birth_date`), day(`birth_date`), left(`ucn`, 4))
    ELSE concat(year(`birth_date`), month(`birth_date`), right(`ucn`, 4))
    END) AS `cardnum`,
(CASE
    WHEN `id` % 2 = 0 THEN 'Pilot'
    WHEN id % 3 = 0 THEN 'Cook'
    ELSE 'Engineer'
    END) AS `job`, `id` AS `colonist`, substring(`ucn`, 1, 1) AS `jorney`
FROM `colonists` as `c`
WHERE `id` >=96 AND `id`<=100;

#02. Update
UPDATE `journeys` AS `j`
SET j.`purpose` = (CASE
    WHEN j.`id` % 2 = 0 THEN 'Medical'
    WHEN j.`id` % 3 = 0 THEN 'Technical'
    WHEN j.`id` % 5 = 0 THEN 'Educational'
    WHEN j.`id` % 7 = 0 THEN 'Military'
    ELSE j.`purpose`
    END);

#03. Delete
DELETE FROM `colonists`
WHERE `id` NOT IN (SELECT tc.`colonist_id` FROM `travel_cards` AS `tc`);

#Section 3: Querying
#04. Extract all travel cards
SELECT tc.`card_number`, tc.`job_during_journey` FROM `travel_cards` AS `tc`
ORDER BY tc.`card_number`;

#05. Extract all colonists
SELECT c.`id`, concat(c.`first_name`, ' ', c.`last_name`) as `full_name`, c.`ucn`
FROM `colonists` AS `c`
ORDER BY c.`first_name`, c.`last_name`, c.`id`;

#06. Extract all military journeys
SELECT j.`id`, j.`journey_start`, j.`journey_end`
FROM `journeys` AS `j`
WHERE j.`purpose` = 'Military'
ORDER BY j.`journey_start`;

#07. Extract all pilots
SELECT c.`id`, concat(c.`first_name`, ' ', c.`last_name`) AS `full_name`
FROM `colonists` AS `c`
JOIN `travel_cards` `tc` ON `c`.`id` = `tc`.`colonist_id`
WHERE tc.`job_during_journey` = 'Pilot'
ORDER BY c.`id`;

#08. Count all colonists
SELECT count(c.`id`) AS `count`
FROM `colonists` AS `c`
JOIN `travel_cards` `tc` ON `c`.`id` = `tc`.`colonist_id`
JOIN `journeys` `j` ON `tc`.`journey_id` = `j`.`id`
WHERE j.`purpose` = 'Technical';

#09. Extract the fastest spaceship
SELECT ss.`name`, sp.`name` FROM `spaceships` AS `ss`
JOIN `journeys` `j` ON `ss`.`id` = `j`.`spaceship_id`
JOIN `spaceports` `sp` ON `j`.`destination_spaceport_id` = `sp`.`id`
ORDER BY ss.`light_speed_rate` DESC
LIMIT 1;

#10. Extract - pilots younger than 30 years
SELECT ss.`name`, ss.`manufacturer` FROM `spaceships` as `ss`
JOIN `journeys` `j` ON `ss`.`id` = `j`.`spaceship_id`
JOIN `travel_cards` `tc` ON `j`.`id` = `tc`.`journey_id`
JOIN `colonists` `c` ON `tc`.`colonist_id` = `c`.`id`
WHERE `tc`.`job_during_journey` = 'Pilot' AND c.`birth_date` > '1989-01-01'
ORDER BY ss.`name`;

#11. Extract all educational mission
SELECT DISTINCT p.`name` AS `planet_name`, sp.`name` AS `spaceport_name`
FROM `planets` AS `p`
JOIN `spaceports` `sp` ON `p`.`id` = `sp`.`planet_id`
JOIN `journeys` `j` ON `sp`.`id` = `j`.`destination_spaceport_id`
WHERE j.`purpose` = 'Educational'
ORDER BY `spaceport_name` DESC;

#12. Extract all planets and their journey count
SELECT p.`name` AS `planet_name`, count(j.`id`) AS `journeys_count`
FROM `planets` AS `p`
JOIN `spaceports` `s` ON `p`.`id` = `s`.`planet_id`
JOIN `journeys` `j` ON `s`.`id` = `j`.`destination_spaceport_id`
GROUP BY p.`name`
ORDER BY `journeys_count` DESC, p.`name`;

#13. Extract the shortest journey
SELECT j.`id`, p.`name`, sp.`name`, j.`purpose`
FROM `journeys` AS `j`
JOIN `travel_cards` `tc` ON `j`.`id` = `tc`.`journey_id`
JOIN `spaceports` `sp` ON `j`.`destination_spaceport_id` = `sp`.`id`
JOIN `planets` `p` ON `sp`.`planet_id` = `p`.`id`
ORDER BY j.`journey_end` - j.`journey_start`
LIMIT 1;

#14. Extract the less popular job
SELECT `tc`.`job_during_journey` as `job_name`
FROM `travel_cards` as `tc`
WHERE `tc`.`journey_id` = (
    SELECT j.`id` FROM `journeys` AS `j`
    ORDER BY j.`journey_end` - j.`journey_start` DESC
    LIMIT 1)
GROUP BY tc.`job_during_journey`
ORDER BY count(tc.`job_during_journey`)
LIMIT 1;

#Section 4: Programmability
#15. Get colonists count
DELIMITER ;;
CREATE FUNCTION `udf_count_colonists_by_destination_planet` (`planet_name` VARCHAR(30))
RETURNS INT
    DETERMINISTIC
BEGIN
    DECLARE `colonist_count` INT;
    SET `colonist_count` = (
        SELECT count(c.`id`) AS `result` FROM `colonists` AS `c`
        JOIN `travel_cards` `tc` ON `c`.`id` = `tc`.`colonist_id`
        JOIN `journeys` `j` ON `tc`.`journey_id` = `j`.`id`
        JOIN `spaceports` `s` ON `j`.`destination_spaceport_id` = `s`.`id`
        JOIN `planets` `p` ON `s`.`planet_id` = `p`.`id`
        WHERE p.`name` = `planet_name`);
    RETURN `colonist_count`;
END ;;
DELIMITER ;

#16. Modify spaceship
DELIMITER ;;
CREATE PROCEDURE `udp_modify_spaceship_light_speed_rate` (`spaceship_name` VARCHAR(50), light_speed_rate_increse INT(11))
BEGIN
    IF ((SELECT count(ss.`name`) as `count`
        FROM `spaceships` AS `ss`
        WHERE ss.`name` = `spaceship_name`) > 0)
        THEN
        UPDATE `spaceships` as `ss`
        SET ss.`light_speed_rate` = ss.`light_speed_rate` + `light_speed_rate_increse`
        WHERE ss.`name` = `spaceship_name`;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT  = 'Spaceship you are trying to modify does not exists.';
    END IF;
END ;;
DELIMITER ;

/*
 The SoftUni Open Judge System does not accept the
 DETERMINISTIC and DELIMITER clauses so the functions
 from Section 4 must be submitted without them.
 */