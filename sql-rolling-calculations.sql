USE sakila;

-- Get the number of monthly users:
SELECT
  YEAR(rental_date) AS Year,
  MONTH(rental_date) AS Month,
  COUNT(DISTINCT customer_id) AS Monthly_Active_Customers
FROM rental
GROUP BY year, month
ORDER BY year, month;


-- Get the number of active users last month
SELECT
  YEAR(rental_date) AS Year,
  MONTH(rental_date) AS Month,
  COUNT(DISTINCT customer_id) AS Monthly_Active_Customers,
  LAG(COUNT(DISTINCT customer_id)) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date)) AS Last_Month_Active_Customers
FROM rental
GROUP BY year, month
ORDER BY year, month;

-- Getting the percentage of change of monthly active users

SELECT YEAR(rental_date) AS Year, MONTH(rental_date) AS Month,
  COUNT(DISTINCT customer_id) AS Monthly_Active_Customers,
  LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date)) AS Last_Month_Active_Customers,
  CONCAT(
    IF(
      LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date)) <> 0,
      ((COUNT(DISTINCT customer_id) - LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date))) /
      LAG(COUNT(DISTINCT customer_id), 1) OVER (ORDER BY YEAR(rental_date), MONTH(rental_date))) * 100,
      0
    ),
    '%'
  ) AS Change_Percentage
FROM rental
GROUP BY year, month
ORDER BY year, month;

-- Getting the retained customers
SELECT YEAR(r1.rental_date) AS Year, MONTH(r1.rental_date) AS Month,
  COUNT(DISTINCT r1.customer_id) AS Monthly_Active_Customers,
  LAG(COUNT(DISTINCT r1.customer_id), 1, 0) OVER (ORDER BY YEAR(r1.rental_date), MONTH(r1.rental_date)) AS Last_Month_Active_Customers,
  COUNT(DISTINCT CASE WHEN r2.customer_id IS NOT NULL THEN r2.customer_id END) AS Retained_Customers
FROM rental r1
LEFT JOIN rental r2 ON r1.customer_id = r2.customer_id
AND DATE_FORMAT(r1.rental_date, '%Y-%m') = DATE_FORMAT(DATE_SUB(r2.rental_date, INTERVAL 1 MONTH), '%Y-%m')
GROUP BY Year, Month
ORDER BY Year, Month;

