#16. Orders Table
SELECT `product_name`, `order_date`,
       adddate(`order_date`, INTERVAL 3 DAY) AS `pay_due`,
       adddate(`order_date`, INTERVAL 1 MONTH) as `deliver_due` FROM `orders`;