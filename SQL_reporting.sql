CREATE DATABASE Sql_reporting;
USE Sql_reporting;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(20),
    city VARCHAR(50),
    country VARCHAR(50),
    signup_date DATE);
    
CREATE TABLE categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100));
    
INSERT INTO categories (category_id, category_name) VALUES
(1, 'Electronics'),
(2, 'Laptop'),
(3, 'Mobile'),
(4, 'Accessories');

SELECT * FROM categories;

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2),

    FOREIGN KEY (category_id)
        REFERENCES categories(category_id));
        
INSERT INTO products (product_id, product_name, category_id, price) VALUES
(101, 'iPhone 15', 3, 70000),
(102, 'Samsung Galaxy S24', 3, 65000),
(103, 'Dell Laptop', 2, 85000),
(104, 'HP Laptop', 2, 75000),
(105, 'Wireless Mouse', 4, 1500),
(106, 'Keyboard', 4, 2500),
(107, 'Sony Headphones', 1, 5000);
        
CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    order_status VARCHAR(30),

    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id));
        
INSERT INTO orders(order_id, customer_id, order_date, order_status) VALUES
(1001, 1, '2025-01-15', 'Completed'),
(1002, 2, '2025-01-20', 'Completed'),
(1003, 3, '2025-02-05', 'Completed'),
(1004, 1, '2025-02-15', 'Completed'),
(1005, 4, '2025-03-10', 'Completed'),
(1006, 5, '2025-03-25', 'Completed'),
(1007, 6, '2025-04-12', 'Completed'),
(1008, 7, '2025-05-15', 'Completed'),
(1009, 8, '2025-06-20', 'Completed'),
(1010, 1, '2025-07-10', 'Completed'),
(1011, 2, '2025-08-05', 'Completed'),
(1012, 3, '2025-09-18', 'Completed');
        
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),

    FOREIGN KEY (order_id)
        REFERENCES orders(order_id),

    FOREIGN KEY (product_id)
        REFERENCES products(product_id));

INSERT INTO order_items(order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1, 1001, 101, 1, 70000),
(2, 1001, 105, 2, 1500),
(3, 1002, 102, 1, 65000),
(4, 1003, 103, 1, 85000),
(5, 1003, 106, 1, 2500),
(6, 1004, 105, 3, 1500),
(7, 1005, 104, 1, 75000),
(8, 1006, 107, 2, 5000),
(9, 1007, 106, 2, 2500),
(10, 1008, 101, 1, 70000),
(11, 1009, 102, 2, 65000),
(12, 1010, 103, 1, 85000),
(13, 1011, 105, 5, 1500),
(14, 1012, 107, 1, 5000);

CREATE TABLE messy_customers (
    customer_id INT,
    customer_name VARCHAR(100),
    email VARCHAR(100),
    phone VARCHAR(30),
    city VARCHAR(50),
    country VARCHAR(50),
    signup_date VARCHAR(30));
    
INSERT INTO messy_customers VALUES
(1, '  John Doe  ', 'JOHN.DOE@GMAIL.COM', '987-654-3210', 'hyderabad', 'india', '2025-01-10'),
(2, 'jane smith', ' jane.smith@gmail.com ', '9876543211', 'BANGALORE', 'INDIA', '2025-02-15'),
(3, ' ALICE BROWN', 'ALICE.BROWN@YAHOO.COM', '(987) 654-3212', 'Mumbai ', 'india', '2025-03-20'),
(4, 'Bob  Wilson', 'BOB.WILSON@GMAIL.COM', '987 654 3213', 'hyderabad', 'India', '2025-04-05'),
(5, '  David Miller', 'david.miller@gmail.com', NULL, 'DELHI', 'INDIA', '2025-05-11'),
(6, 'Emma Jones ', 'EMMA.JONES@GMAIL.COM', '9876543215', NULL, 'INDIA', '2025-06-18'),
(7, 'Michael Brown', ' michael.brown@yahoo.com', '987-654-3216', 'Mumbai', 'India', '2025-07-22'),
(8, 'Sarah Taylor', 'SARAH.TAYLOR@GMAIL.COM', '9876543217', ' hyderabad ', 'INDIA', '2025-08-12');
SELECT * FROM messy_customers;

## Data Cleansing
CREATE TABLE cleaned_customers AS
SELECT customer_id, LOWER(TRIM(customer_name)) AS customer_name, LOWER(TRIM(email)) AS email,
    REPLACE(
        REPLACE(
            REPLACE(
                REPLACE(phone, '-', ''),
            ' ', ''),
        '(', ''),
    ')', '') AS phone, UPPER(TRIM(city)) AS city, UPPER(TRIM(country)) AS country,
STR_TO_DATE(signup_date, '%Y-%m-%d') AS signup_date FROM messy_customers;

SELECT * FROM cleaned_customers;

## Handling missing values
SELECT customer_id, customer_name, email, phone, city FROM cleaned_customers
WHERE phone IS NULL OR city IS NULL;

SELECT customer_id, customer_name, COALESCE(city, 'UNKNOWN') AS city
FROM cleaned_customers;

## Moving cleaned data into customers
INSERT INTO customers
(customer_id, customer_name, email, phone, city, country, signup_date)
SELECT customer_id, customer_name, email, phone, COALESCE(city, 'UNKNOWN'),
country, signup_date FROM cleaned_customers;

SELECT * FROM customers;

## Sales calculation
SELECT oi.order_id, oi.product_id, oi.quantity, oi.unit_price, 
oi.quantity * oi.unit_price AS sales_amount FROM order_items oi;

## Nested query
SELECT customer_id, total_sales
FROM(SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id) AS customer_sales WHERE total_sales > 70000;

## Re-writing nested query as CTE
WITH customer_sales AS
(SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id)
SELECT customer_id, total_sales FROM customer_sales WHERE total_sales > 70000;

## Creating multiple CTE's 
WITH customer_sales AS
(SELECT o.customer_id, SUM(oi.quantity * oi.unit_price) AS total_sales
FROM orders o JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY o.customer_id),

customer_orders AS
(SELECT customer_id, COUNT(*) AS order_count
FROM orders GROUP BY customer_id)

SELECT c.customer_id, c.customer_name, cs.total_sales, co.order_count
FROM customers c JOIN customer_sales cs ON c.customer_id = cs.customer_id
JOIN customer_orders co ON c.customer_id = co.customer_id ORDER BY cs.total_sales DESC;

## Creating SALES View
CREATE VIEW vw_sales_details AS
SELECT o.order_id, o.order_date, c.customer_id, c.customer_name, c.city,
p.product_id, p.product_name, cat.category_name, oi.quantity, oi.unit_price,
oi.quantity * oi.unit_price AS sales_amount 
FROM orders o JOIN customers c ON o.customer_id = c.customer_id 
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id 
JOIN categories cat ON p.category_id = cat.category_id;

SELECT * FROM vw_sales_details;

## Creating sales by customer view
CREATE VIEW vw_customer_sales AS
SELECT customer_id, customer_name, city,
COUNT(DISTINCT order_id) AS total_orders, SUM(sales_amount) AS total_sales
FROM vw_sales_details GROUP BY customer_id, customer_name, city;

SELECT * FROM vw_customer_sales ORDER BY total_sales DESC;

## Combining view + CTE
WITH ranked_customers AS
(SELECT customer_id, customer_name, city, total_orders, total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM vw_customer_sales)
SELECT * FROM ranked_customers WHERE sales_rank <= 5;

## Overall customer ranking
SELECT customer_id, customer_name, total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM vw_customer_sales;

## Dense rank
SELECT customer_id, customer_name, total_sales,
DENSE_RANK() OVER (ORDER BY total_sales DESC) AS sales_rank
FROM vw_customer_sales;

## Row number
SELECT customer_id, customer_name, total_sales,
ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS Row_Count FROM vw_customer_sales;

## Ranking products within category
SELECT category_name, product_name, SUM(sales_amount) AS total_sales,
RANK() OVER (PARTITION BY category_name ORDER BY SUM(sales_amount) DESC) 
AS category_rank FROM vw_sales_details GROUP BY
category_name, product_name;

## Time-series
SELECT YEAR(order_date) AS sales_year, MONTH(order_date) AS sales_month,
SUM(sales_amount) AS monthly_sales FROM vw_sales_details
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY sales_year, sales_month;

## Monthly sales
SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month, 
SUM(sales_amount) AS monthly_sales FROM vw_sales_details 
GROUP BY DATE_FORMAT(order_date, '%Y-%m') ORDER BY sales_month;

## Using window func
WITH monthly_sales AS
(SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
SUM(sales_amount) AS monthly_sales FROM vw_sales_details
GROUP BY DATE_FORMAT(order_date, '%Y-%m'))
SELECT sales_month, monthly_sales, SUM(monthly_sales) 
OVER (ORDER BY sales_month) AS running_total FROM monthly_sales;

## Month over month change
WITH monthly_sales AS
(SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
SUM(sales_amount) AS monthly_sales FROM vw_sales_details
GROUP BY DATE_FORMAT(order_date, '%Y-%m'))
SELECT sales_month, monthly_sales, LAG(monthly_sales) 
OVER (ORDER BY sales_month) AS previous_month_sales FROM monthly_sales;

## Month-Over-Month Percentage
WITH monthly_sales AS
(SELECT DATE_FORMAT(order_date, '%Y-%m') AS sales_month,
SUM(sales_amount) AS monthly_sales FROM vw_sales_details
GROUP BY DATE_FORMAT(order_date, '%Y-%m')),
sales_comparison AS
(SELECT sales_month, monthly_sales, LAG(monthly_sales) OVER (
ORDER BY sales_month) AS previous_month_sales FROM monthly_sales)
SELECT sales_month, monthly_sales, previous_month_sales,
ROUND(((monthly_sales - previous_month_sales)/ previous_month_sales) * 100,2) 
AS growth_percentage FROM sales_comparison;

## window function dashboard
WITH customer_sales AS
(SELECT customer_id, customer_name, city, total_sales FROM vw_customer_sales),
dashboard AS(SELECT customer_id, customer_name, city, total_sales,
RANK() OVER (ORDER BY total_sales DESC) AS sales_rank,
LAG(total_sales) OVER (ORDER BY total_sales DESC) AS previous_customer_sales,
SUM(total_sales) OVER () AS overall_sales FROM customer_sales)
SELECT customer_id, customer_name, city, total_sales, sales_rank,
previous_customer_sales, ROUND(total_sales / overall_sales * 100,2) 
AS percentage_of_total_sales FROM dashboard ORDER BY sales_rank;

### SLOW QUERY 1 — CUSTOMER ORDERS
EXPLAIN SELECT * FROM orders WHERE customer_id = 1;

### Add index
CREATE INDEX idx_orders_customer ON orders(customer_id);

### SLOW QUERY 2 — ORDER DATE
EXPLAIN SELECT * FROM orders
WHERE order_date BETWEEN '2025-01-01'AND '2025-06-30';

### create an index
CREATE INDEX idx_orders_date ON orders(order_date);

### SLOW QUERY 3 — ORDER ITEMS PRODUCT
EXPLAIN SELECT * FROM order_items WHERE product_id = 101;

### create index
CREATE INDEX idx_order_items_product ON order_items(product_id);

SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;

## using explain analyze
EXPLAIN ANALYZE SELECT * FROM orders WHERE customer_id = 1;

## DOCUMENT PERFORMANCE GAINS
CREATE TABLE query_performance (
    query_id INT PRIMARY KEY,
    query_name VARCHAR(100),
    optimization VARCHAR(200),
    before_plan VARCHAR(200),
    after_plan VARCHAR(200),
    performance_result VARCHAR(200));
    
## Inserting observations:
INSERT INTO query_performance VALUES
(1,
    'Customer Orders',
    'Added index on orders.customer_id',
    'Table scan',
    'Index lookup',
    'Reduced rows examined'),
(2,
    'Orders by Date',
    'Added index on orders.order_date',
    'Table scan',
    'Index range scan',
    'Reduced rows examined'),
(3,
    'Product Order Items',
    'Added index on order_items.product_id',
    'Table scan',
    'Index lookup',
    'Reduced rows examined');
SELECT * FROM query_performance;