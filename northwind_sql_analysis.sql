
-- 1. SALES & REVENUE TRENDS


-- Total Revenue Trend By Year and Month
SELECT 
    EXTRACT(YEAR FROM o.order_date) AS order_year, 
    EXTRACT(MONTH FROM o.order_date) AS order_month, 
    ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount)))::numeric, 2) AS total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_year, order_month
ORDER BY order_year, order_month;

--Average Order Value (AOV) by Year

WITH order_totals AS (
	SELECT ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue, o.order_id, o.order_date
	FROM orders o
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY o.order_id, o.order_date
)

SELECT ROUND(AVG(ot.total_revenue)::numeric, 2) AS average_order_value, EXTRACT(YEAR FROM(ot.order_date)) AS order_year
FROM order_totals ot
GROUP BY order_year
ORDER BY order_year

--Sales by Month and Year

SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, EXTRACT(MONTH FROM o.order_date) AS order_month, ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric,2) AS total_revenue
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
GROUP BY order_year, order_month
ORDER BY order_year DESC, order_month ASC

--Sales by Country/Region

SELECT c.country, ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric,2) AS total_revenue, COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC

--Cumulative Sales

WITH monthly_sales AS(
	SELECT
	EXTRACT(YEAR FROM o.order_date) AS order_year,
	EXTRACT(MONTH FROM o.order_date) AS order_month,
	SUM(od.unit_price * od.quantity * (1 - od.discount)) AS monthly_revenue
	FROM orders o
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY order_year, order_month
)

SELECT order_year, order_month, ROUND(monthly_revenue::numeric, 2) AS monthly_revenue, ROUND(SUM(monthly_revenue)
																						OVER (
																						PARTITION BY order_year
																						ORDER BY order_month)::numeric, 2) AS running_total_revenue
FROM monthly_sales
ORDER BY order_year, order_month


--Yearly Revenue Growth 

WITH yearly_sales AS (
	SELECT EXTRACT(YEAR FROM o.order_date) AS order_year, ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric,2) AS yearly_revenue
	FROM orders o 
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY order_year
)

SELECT order_year, ROUND(yearly_revenue::numeric, 2) AS current_year_revenue, ROUND(LAG(yearly_revenue) OVER (ORDER BY order_year)::numeric, 2) AS previous_year_revenue,
	ROUND(
	((yearly_revenue) - LAG(yearly_revenue) OVER (ORDER BY order_year)) / LAG(yearly_revenue) OVER (ORDER BY order_year) * 100::numeric, 2) AS growth_percentage
FROM yearly_sales
ORDER BY order_year

--Sales per Day

SELECT TO_CHAR(o.order_date, 'Day') AS day_of_week, COUNT(DISTINCT o.order_id) AS total_orders,  ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount)))::numeric, 2) as total_revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY day_of_week, EXTRACT(ISODOW FROM o.order_date)
ORDER BY EXTRACT(ISODOW FROM o.order_date) ASC


-- 2. PRODUCT & CATEGORY PERFORMANCE


--Top 5 Products by Revenue

WITH product_revenue AS (
	SELECT p.product_name, SUM(od.unit_price * od.quantity * (1 - od.discount)) AS product_revenue
	FROM products p 
	JOIN order_details od ON p.product_id = od.product_id
	GROUP BY product_name
 )

 
SELECT product_name, ROUND(product_revenue::numeric, 2) AS product_revenue, 
ROUND((product_revenue / SUM(product_revenue) OVER () * 100)::numeric, 2) AS percentage_of_total_revenue
FROM product_revenue
ORDER BY product_revenue DESC
LIMIT 5


--Total Revenue by Category

SELECT category_name, ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount)))::numeric, 2) as total_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON od.product_id = p.product_id
GROUP BY category_name
ORDER BY total_revenue DESC
LIMIT 10

--Products Below Order Level

SELECT product_name, units_in_stock, reorder_level, units_on_order
FROM products
WHERE units_in_stock <= reorder_level AND discontinued = 0
ORDER BY units_in_stock

--Discount Impact

SELECT p.product_name, ROUND(AVG(od.discount)::numeric, 2) AS average_discount, SUM(od.quantity) AS total_units_sold
FROM products p 
JOIN order_details od ON p.product_id = od.product_id
GROUP BY product_name
ORDER BY average_discount DESC
LIMIT 5

--Most Sold Product in Each Category

SELECT DISTINCT ON(c.category_name) c.category_name, p.product_name, ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS product_revenue
FROM categories c
JOIN products p ON c.category_id = p.category_id
JOIN order_details od ON p.product_id = od.product_id
GROUP BY c.category_name, p.product_name
ORDER BY c.category_name, product_revenue DESC

--Categories With Highest Average Discount

SELECT c.category_name, ROUND((AVG(od.discount)* 100)::numeric, 2) AS average_discount_percentage
FROM categories c
JOIN products p ON p.category_id = c.category_id
JOIN order_details od ON od.product_id = p.product_id
GROUP BY c.category_name
ORDER BY average_discount_percentage  DESC


-- 3. CUSTOMER & EMPLOYEE ANALYTICS


-- Top 10 Customers by Revenue
SELECT 
    c.company_name, 
    ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount)))::numeric, 2) AS total_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
GROUP BY c.company_name
ORDER BY total_revenue DESC
LIMIT 10;

--Customer Recency (Days since last order)

SELECT c.company_name, MAX(o.order_date) AS last_order_date, (SELECT MAX(order_date) from orders) - MAX(o.order_date) AS days_since_last_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY company_name
ORDER BY days_since_last_order DESC

--RFM per Customer

SELECT c.company_name, COUNT(DISTINCT o.order_id) AS number_of_orders, ROUND(SUM(od.unit_price * od.quantity * (1 - od.discount))::numeric, 2) AS total_revenue, (SELECT MAX(order_date) from orders) - MAX(o.order_date) AS days_since_last_order
FROM orders o 
JOIN order_details od ON o.order_id = od.order_id
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY company_name
ORDER BY total_revenue DESC

--Customer Segmentation by Spend Quartile (NTILE)

WITH total_revenue_customer AS (
	SELECT c.company_name, SUM(od.unit_price * od.quantity * (1 - od.discount)) AS total_spent
	FROM customers c
	JOIN orders o ON o.customer_id = c.customer_id
	JOIN order_details od ON od.order_id = o.order_id
	GROUP BY company_name
)

SELECT company_name, ROUND(total_spent::numeric, 2) AS total_spent, NTILE(4) OVER (ORDER BY total_spent DESC) AS customer_quartile
FROM total_revenue_customer

--Customers with Only One Order

SELECT c.company_name, COUNT(o.order_id) AS number_of_orders
FROM customers c 
JOIN orders o ON c.customer_id = o.customer_id
GROUP BY company_name
HAVING COUNT(o.order_id) = 1

--Top 5 Sales Representatives by Revenue

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, COUNT(DISTINCT o.order_id) AS total_orders, ROUND(SUM((od.unit_price * od.quantity * (1 - od.discount)))::numeric, 2) as total_revenue
FROM orders o
JOIN employees e ON o.employee_id = e.employee_id
JOIN order_details od ON od.order_id = o.order_id
GROUP BY employee_name
ORDER BY total_revenue DESC
LIMIT 5
