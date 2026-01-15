CREATE DATABASE SQL_P1;
use SQL_P1;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );
            
select count(*) as Total_Records from retail_sales;
select  * from retail_sales limit 5;
select  * from retail_sales where transaction_id IS NULL;

-- check for null values-- 
SELECT
    SUM(transaction_id IS NULL) AS transaction_id_nulls,
    SUM(sale_date IS NULL) AS sale_date_nulls,
    SUM(sale_time IS NULL) AS sale_time_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(gender IS NULL) AS gender_nulls,
    SUM(age IS NULL) AS age_nulls,
    SUM(category IS NULL) AS category_nulls,
    SUM(quantity IS NULL) AS quantity_nulls,
    SUM(price_per_unit IS NULL) AS price_per_unit_nulls,
    SUM(cogs IS NULL) AS cogs_nulls,
    SUM(total_sale IS NULL) AS total_sale_nulls
FROM retail_sales;

-- another way to check for null values-- 
SELECT *
FROM retail_sales
WHERE transaction_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantity IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;
   
select count( distinct category) from retail_sales;
select distinct category from retail_sales;
select count( distinct customer_id) from retail_sales;

-- Data Analysis Problems--
-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)
-- Q.11 Write a SQL query to find the total quantity sold for each category.
-- Q.12 Write a SQL query to find the total revenue and total profit for each category
-- Q.13 Write a SQL query to find the top 3 categories with the highest total sales.
-- Q.14 Write a SQL query to calculate the average price per unit for each category.
-- Q.15 Write a SQL query to find the youngest and oldest customer age for each category.
-- Q.16 Write a SQL query to find daily total sales and order them by highest sales.
-- Q.17 Write a SQL query to find the number of transactions per hour of the day.
-- Q.18 Write a SQL query to identify customers who have made more than 5 purchases.
-- Q.19 Write a SQL query to find the percentage contribution of each category to total sales.
-- Q.20 Write a SQL query to find the monthly growth rate of total sales.

 
 
  -- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
  select * 
  from retail_sales
  where sale_date = '2022-11-05';
  
  -- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
SELECT transaction_id
FROM retail_sales
WHERE category = 'Clothing'
  AND quantity >=4
  AND sale_date BETWEEN '2022-11-01' AND '2022-11-30';
  
SELECT 
  *
FROM retail_sales
WHERE 
    category = 'Clothing'
    AND 
    DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
    AND
    quantity >= 4;

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

select category, sum(total_sale) as Net_Sales ,count(total_sale) as Total_orders 
from retail_sales
group by category;

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

select round(avg(age),3)
from retail_sales
where category = 'Beauty';

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

select transaction_id
from retail_sales
where total_sale >1000;

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

select gender,category,count(transaction_id) as Total_Transactions
from retail_sales
group by gender,category
order by category;

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

SELECT year,month,avg_sale
FROM (    
SELECT 
   YEAR(sale_date) as year,
   MONTH(sale_date) as month,
    round(AVG(total_sale),2) as avg_sale,
    RANK() OVER(PARTITION BY YEAR(sale_date) ORDER BY AVG(total_sale) DESC) as ranks
FROM retail_sales
GROUP BY 1, 2
) as avg_sale_table
WHERE ranks = 1;

-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
select customer_id,sum(total_sale) as Total_sales
from retail_sales
group by customer_id
order by Total_sales limit 5;

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

select category,count(distinct customer_id) as Customer_Id
from retail_sales
group by category;


-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

WITH hourly_sale
AS
(
SELECT *,
    CASE
        WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END as shift
FROM retail_sales
)
SELECT 
    shift,
    COUNT(*) as total_orders    
FROM hourly_sale
GROUP BY shift;

-- Q.11 Write a SQL query to find the total quantity sold for each category.

select  category, sum(quantity) as Total_Quantity
from retail_sales
group by 1;

-- Q.12 Write a SQL query to find the total revenue and total profit for each category

SELECT category,
       SUM(total_sale) AS revenue,
       SUM(total_sale - cogs) AS profit
FROM retail_sales
GROUP BY category;

-- Q.13 Write a SQL query to find the top 3 categories with the highest total sales.

select category,sum(total_sale) as Total_sales
from retail_sales
group by category
order by Total_sales desc;

-- Q.14 Write a SQL query to calculate the average price per unit for each category.

select category,round(avg(price_per_unit),2) as Averge_price_per_Unit
from retail_sales
group by category
order by Averge_price_per_Unit desc;

-- Q.15 Write a SQL query to find the youngest and oldest customer age for each category.

select category,max(age) as Oldest,min(age) Youngest
from retail_sales
group by category;

-- Q.16 Write a SQL query to find daily total sales and order them by highest sales.

select sale_date,
       SUM(total_sale) AS daily_sales
from retail_sales
group by sale_date
order by daily_sales DESC;

-- Q.17 Write a SQL query to find the number of transactions per hour of the day.

select HOUR(sale_time) AS hour,
       COUNT(transaction_id) AS transactions
from retail_sales
group by hour
order by hour;

-- Q.18 Write a SQL query to identify customers who have made more than 5 purchases.

select customer_id,
       COUNT(transaction_id) AS total_purchases
from retail_sales
group by customer_id
having COUNT(transaction_id) > 5;

-- Q.19 Write a SQL query to find the percentage contribution of each category to total sales.

SELECT
    category,
    ROUND(
        SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER (),
        2
    ) AS percentage
FROM retail_sales
GROUP BY category;

-- Q.20 Write a SQL query to find the monthly growth rate of total sales.

SELECT year,
       month,
       total_sales,
       LAG(total_sales) OVER (ORDER BY year, month) AS prev_month_sales,
       ROUND(
         (total_sales - LAG(total_sales) OVER (ORDER BY year, month)) * 100 /
         LAG(total_sales) OVER (ORDER BY year, month), 2
       ) AS growth_rate
FROM (
    SELECT YEAR(sale_date) AS year,
           MONTH(sale_date) AS month,
           SUM(total_sale) AS total_sales
    FROM retail_sales
    GROUP BY YEAR(sale_date), MONTH(sale_date)
) growth_rate_table;

