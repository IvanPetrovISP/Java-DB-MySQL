#01. Records’ Count
SELECT count(*) AS 'count' FROM `wizzard_deposits`;

#02. Longest Magic Wand
SELECT max(`magic_wand_size`) AS 'longest_magic_wand' FROM `wizzard_deposits`;

#03. Longest Magic Wand per Deposit Groups
SELECT `deposit_group`, max(`magic_wand_size`) AS `longest_magic_wand` FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `longest_magic_wand`, `deposit_group`;

#04. Smallest Deposit Group per Magic Wand Size
CREATE TABLE `temp_table` AS SELECT `deposit_group`, avg(`magic_wand_size`) as `wand_size` FROM `wizzard_deposits`
GROUP BY `deposit_group`;

SELECT `deposit_group` FROM `temp_table`
ORDER BY `wand_size`
LIMIT 1;

#05. Deposits Sum
SELECT `deposit_group`, sum(`deposit_amount`) AS `total_sum` FROM `wizzard_deposits`
GROUP BY `deposit_group`
ORDER BY `total_sum`;

#06. Deposits Sum for Ollivander Family
SELECT `deposit_group`, sum(`deposit_amount`) AS `total_sum` FROM `wizzard_deposits`
WHERE `magic_wand_creator` = 'Ollivander family'
GROUP BY `deposit_group`
ORDER BY `deposit_group`;

#07. Deposits Filter
SELECT `deposit_group`, sum(`deposit_amount`) as `total_sum` FROM `wizzard_deposits`
WHERE `magic_wand_creator` = 'Ollivander family'
GROUP BY `deposit_group`
HAVING `total_sum` < 150000
ORDER BY `total_sum` DESC;

#08. Deposit Charge
SELECT `deposit_group`, `magic_wand_creator`, min(`deposit_charge`) as `min_deposit_charge` FROM `wizzard_deposits`
GROUP BY `deposit_group`, `magic_wand_creator`
ORDER BY `magic_wand_creator`, `deposit_group`;

#09. Age Groups
SELECT CASE
    WHEN `age` <= 10 THEN '[0-10]'
    WHEN `age` <= 20 THEN '[11-20]'
    WHEN `age` <= 30 THEN '[21-30]'
    WHEN `age` <= 40 THEN '[31-40]'
    WHEN `age` <= 50 THEN '[41-50]'
    WHEN `age` <= 60 THEN '[51-60]'
    ELSE '[61+]' end AS `age_group`, COUNT(*) AS `wizard_count`
FROM `wizzard_deposits`
GROUP BY `age_group`
ORDER BY `age_group`;

#10. First Letter
SELECT DISTINCT left(`first_name`, 1) AS `first_letter` FROM `wizzard_deposits`
WHERE `deposit_group` = 'Troll Chest'
GROUP BY `first_name`;

#11. Average Interest
SELECT `deposit_group`, `is_deposit_expired`, avg(`deposit_interest`) AS `average_interest` FROM `wizzard_deposits`
WHERE `deposit_start_date` > '1985-01-01'
GROUP BY `deposit_group`, `is_deposit_expired`
ORDER BY `deposit_group` DESC , `is_deposit_expired`;

#12. Rich Wizard, Poor Wizard
SELECT SUM(`diff`.`next`) AS 'sum_difference'
FROM (SELECT `deposit_amount` -
             (SELECT `deposit_amount`
              FROM `wizzard_deposits`
              WHERE `id` = `wd`.`id` + 1) AS 'next'
      FROM `wizzard_deposits` AS `wd`) AS `diff`;
