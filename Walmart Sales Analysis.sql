CREATE DATABASE WALLMARTSALES1;

create table sales(
    invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    vat FLOAT(6,4) NOT NULL,
    total DECIMAL(12,4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12,4) NOT NULL,
    rating FLOAT(2,1)
);

-------------------------------------------------------------------------------------------------------
--------------------------------------- Feature Engineering -------------------------------------------

-- time_of_day

SELECT time,
  CASE 
    WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "morning"
    WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "afternoon"
    ELSE "evening"
  END AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);
SET SQL_SAFE_UPDATES = 0;

UPDATE sales
SET time_of_day = ( 
  CASE 
    WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "morning"
    WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "afternoon"
    ELSE "evening"
  END
);

SET SQL_SAFE_UPDATES = 1;

-- day_name
select 
  date,
  DAYNAME (date)
from sales;

alter table sales add column day_name varchar(10);

update sales
set day_name = dayname(date);


------ month_name

select date, MONTHNAME(Date) from sales;
alter table sales add column month_name varchar(10);

UPDATE sales
SET month_name =monthname(date);
-- ------------------------------------------------------------------------------------------------------------------
------------------------------------------------- Generic ------------------------------------------------------------
-- How many unique cities & branches ---
select distinct city from sales;
select distinct branch from sales;

--------------- -------------------------------------------------------------------------------------------------------------
-------------- --------------------------------- Product-----------------------------------------------------------------------
----------- -------------- How manny unique product lines does the data have ?------------------------------------- 

select distinct product_line from sales;
select COUNT(distinct product_line) from sales;

-- 1. What is the most common payment method?
SELECT payment_method, COUNT(*) AS count 
FROM sales 
GROUP BY payment_method
ORDER BY count DESC;


-- 2. What is the most selling product line?
SELECT product_line, COUNT(*) AS count 
FROM sales 
GROUP BY product_line 
ORDER BY count DESC; 

-- 3. What is the total revenue by month?
SELECT MONTH(date) AS month, SUM(total) AS total_revenue 
FROM sales 
GROUP BY month 
ORDER BY month;

-- 4. What month had the largest COGS?
SELECT MONTH(date) AS month, SUM(cogs) AS total_cogs 
FROM sales 
GROUP BY month 
ORDER BY total_cogs DESC
limit 1;

-- 5. What product line had the largest revenue?
SELECT product_line, SUM(total) AS total_revenue 
FROM sales 
GROUP BY product_line 
ORDER BY total_revenue DESC 
LIMIT 1;

-- 6. What is the city with the largest revenue?
SELECT city, SUM(total) AS total_revenue 
FROM sales 
GROUP BY city 
ORDER BY total_revenue DESC 
LIMIT 1;

-- 7. What product line had the largest VAT?
SELECT product_line, SUM(vat) AS total_vat 
FROM sales 
GROUP BY product_line 
ORDER BY total_vat DESC;

-- 8. Fetch each product line and add a column showing "Good" or "Bad". 
-- "Good" if its sales are greater than the average sales.
SELECT product_line, 
       SUM(total) AS total_sales,
       CASE 
           WHEN SUM(total) > (SELECT AVG(total) FROM sales) THEN 'Good'
           ELSE 'Bad' 
       END AS performance 
FROM sales 
GROUP BY product_line;


-- 9. Which branch sold more products than the average product sold?
SELECT branch, SUM(quantity) AS total_products_sold 
FROM sales 
GROUP BY branch 
HAVING total_products_sold > (SELECT AVG(quantity) FROM sales);

-- 10. What is the most common product line by gender?
SELECT gender, product_line, COUNT(*) AS count 
FROM sales 
GROUP BY gender, product_line 
ORDER BY gender, count DESC;

-- 11. What is the average rating of each product line?
SELECT product_line, AVG(rating) AS avg_rating 
FROM sales 
GROUP BY product_line;

------------- ------------------------------------------------------------------------------------------------
------------- ------------ Sales dashboard---------------------------------------------- ----------------------------
------- Number of sales made in each time of the day per weekday-------
SELECT 
    DAYNAME(date) AS weekday, 
    time_of_day, 
    COUNT(*) AS sales_count
FROM sales
GROUP BY weekday, time_of_day
ORDER BY FIELD(weekday, 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday');

------------------------ Which customer type brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue DESC
LIMIT 1;


----------------------- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT city, AVG(vat / total * 100) AS avg_vat_percent
FROM sales
GROUP BY city
ORDER BY avg_vat_percent DESC
LIMIT 1;

----------- Which customer type pays the most in VAT?-------------------------
SELECT customer_type, SUM(vat) AS total_vat_paid
FROM sales
GROUP BY customer_type
ORDER BY total_vat_paid DESC
LIMIT 1;



---------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------- Customer's ------------------------------------------------------------------------------

------------- How many unique customer types does the data have?----------------------------------------
SELECT COUNT(DISTINCT customer_type) AS unique_customer_types
FROM sales;


------------- How many unique payment methods does the data have?----------------------------------------
SELECT COUNT(DISTINCT payment) AS unique_payment_methods
FROM sales;

------------- What is the most common customer type?----------------------------------------
SELECT customer_type, COUNT(*) AS count
FROM sales
GROUP BY customer_type
ORDER BY count DESC
LIMIT 1;

------------------------------------------ Which customer type buys the most?-----------------------------
SELECT customer_type, SUM(quantity) AS total_products_bought
FROM sales
GROUP BY customer_type
ORDER BY total_products_bought DESC;

------------------------------ What is the gender of most of the customers?-------------------------------
SELECT gender, COUNT(*) AS count
FROM sales
GROUP BY gender
ORDER BY count DESC;

--------------------------------------------------------- What is the gender distribution per branch?
SELECT branch, gender, COUNT(*) AS count
FROM sales
GROUP BY branch, gender
ORDER BY branch, count DESC;

 ----------------------------------------- Which time of the day do customers give most ratings?
 SELECT time_of_day, COUNT(rating) AS rating_count
FROM sales
GROUP BY time_of_day
ORDER BY rating_count DESC
LIMIT 1;

------------------- Which day of the week has the best average ratings?
SELECT DAYNAME(date) AS weekday, AVG(rating) AS avg_rating
FROM sales
GROUP BY weekday
ORDER BY avg_rating DESC
LIMIT 1;

------------------- Which day of the week has the best average ratings per branch?
SELECT branch, DAYNAME(date) AS weekday, AVG(rating) AS avg_rating
FROM sales
GROUP BY branch, weekday
ORDER BY branch, avg_rating DESC;








