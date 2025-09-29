--THE FOLLOWING ARE ALL THE SQL CODE I USED DURING THE IMPLEMENTATION OF THIS PROJECT.
--THEY INCLUDE HELPFUL COMMENTS TO HELP THE READER KNOW WHAT WAS AT PLAY.
--THEY WERE DONE IN THE FOLLOWING SEQUENTIAL FORMAT:

1.--This table holds the information about each store's location
CREATE TABLE branches (
    branch_id   INT PRIMARY KEY,
    branch_name VARCHAR(100) NOT NULL,
    location_name   VARCHAR(100),
    open_date   DATE
);

2.--This table outline the different products of the local supermarket's location
CREATE TABLE products (
    product_id   INT PRIMARY KEY,
    product_name VARCHAR(255) NOT NULL,
    price        DECIMAL(10, 2),
    -- Foreign Key to the new categories table
    category_id  INT,
    FOREIGN KEY (category_id) REFERENCES product_categories(category_id)
);

3.--this table managed the different category of products
CREATE TABLE product_categories (
    category_id   INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description   TEXT
);

4.--this table holds information about our loyalty-program members
CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name  VARCHAR(100),
    last_name   VARCHAR(100),
    join_date   DATE
);

5.--This is the table that records every single sale. 
--It links a customer, a product, and a branch together using Foreign Keys.
CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    sale_date      DATE,
    quantity       INT,
    amount         DECIMAL(10, 2),
    
    customer_id    INT,
    product_id     INT,
    branch_id      INT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (branch_id) REFERENCES branches(branch_id)
);

6.--The FOLLOWING INSERTION queries are to insert in data into the created tables for further analysis
INSERT INTO product_categories (category_id, category_name, description) VALUES
(1, 'Dairy', 'Products like milk, cheese, and yogurt'),
(2, 'Beverages', 'Sodas, juices, coffee, and water'),
(3, 'Dry Goods', 'Flour, rice, pasta, and other non-perishables'),
(4, 'Produce', 'Fresh fruits and vegetables');

INSERT INTO branches (branch_id, branch_name, location_name, open_date) VALUES
(1, 'Nyarugenge City Center', 'Nyarugenge', '2022-03-15'),
(2, 'Kicukiro Prime', 'Kicukiro', '2023-01-20'),
(3, 'Kigali Heights', 'Gasabo', '2023-06-01');

INSERT INTO customers (customer_id, first_name, last_name, join_date) VALUES
(1001, 'Jean', 'Mugisha', '2022-04-01'),
(1002, 'Aline', 'Uwase', '2023-02-11'),
(1003, 'Cedric', 'Gatete', '2023-07-20'),
(1004, 'Eliane', 'Keza', '2024-01-05'),
(1005, 'Olivier', 'Nsenga', '2024-03-15'),
(1006, 'Sandrine', 'Isimbi', '2024-05-22'),
(1007, 'Patrick', 'Habimana', '2024-08-30'),
(1008, 'Chantal', 'Uwamahoro', '2025-01-10');

INSERT INTO products (product_id, product_name, price, category_id) VALUES
(101, 'Inyange Milk 1L', 1200.00, 1),
(102, 'Supa Starch 5kg', 6500.00, 3),
(103, 'Bralirwa Soda 50cl', 500.00, 2),
(104, 'Gourmet Coffee Beans 250g', 4500.00, 2),
(105, 'Fresh Apples (1kg)', 2500.00, 4),
(106, 'Rwandan Tea Box', 3000.00, 2),
(107, 'White Bread Loaf', 1000.00, 3),
(108, 'Amashu Cooking Oil 2L', 5500.00, 3),
(109, 'Fresh Bananas (bunch)', 1500.00, 4),
(110, 'Fromage Cheese 150g', 3500.00, 1);

INSERT INTO transactions (transaction_id, sale_date, quantity, amount, customer_id, product_id, branch_id) VALUES
-- October 2024 Sales
(1, '2024-10-05', 2, 2400.00, 1001, 101, 1),
(2, '2024-10-15', 1, 4500.00, 1002, 104, 2),
-- November 2024 Sales
(3, '2024-11-12', 1, 6500.00, 1001, 102, 1),
(4, '2024-11-20', 5, 2500.00, 1003, 103, 3),
(5, '2024-11-25', 2, 6000.00, 1005, 106, 1),
-- December 2024 Sales
(6, '2024-12-15', 3, 7500.00, 1004, 105, 1),
(7, '2024-12-28', 2, 9000.00, 1002, 104, 2),
(8, '2024-12-30', 1, 1000.00, 1006, 107, 3),
-- January 2025 Sales
(9, '2025-01-10', 4, 4800.00, 1001, 101, 1),
(10, '2025-01-15', 1, 2500.00, 1003, 105, 3),
(11, '2025-01-20', 1, 5500.00, 1007, 108, 2),
(12, '2025-01-25', 3, 10500.00, 1008, 110, 1),
-- February 2025 Sales
(13, '2025-02-05', 2, 13000.00, 1002, 102, 1),
(14, '2025-02-11', 10, 5000.00, 1004, 103, 2),
(15, '2025-02-18', 1, 1500.00, 1005, 109, 1),
(16, '2025-02-25', 1, 3500.00, 1008, 110, 3),
-- March 2025 Sales
(17, '2025-03-02', 1, 4500.00, 1001, 104, 1),
(18, '2025-03-10', 3, 3600.00, 1003, 101, 2),
(19, '2025-03-15', 2, 6000.00, 1006, 106, 1),
(20, '2025-03-20', 1, 5500.00, 1007, 108, 2),
(21, '2025-03-28', 2, 3000.00, 1002, 109, 1);

--THIS DOWN HERE ARE MY ANALYSIS QUERIES USING WINDOWS FUNCTIONS

1.--GOAL 1: Rank branches by total revenue to find the 'Gold Standard' model.
-- We use a Common Table Expression (CTE) to first calculate total revenue per branch.
WITH BranchRevenue AS (
    SELECT
        b.branch_name,
        SUM(t.amount) AS total_revenue
    FROM
        transactions t
    JOIN
        branches b ON t.branch_id = b.branch_id
    GROUP BY
        b.branch_name
)
-- Then, we select from the CTE and apply the RANK() window function.
SELECT
    branch_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS branch_rank
FROM
    BranchRevenue
ORDER BY
    branch_rank;

2.-- GOAL 2: Calculate the running monthly sales total for each branch.
-- This helps us see the growth momentum of each location over time.
-- First, we'll use a CTE to get the total sales for each branch, for each month.
-- It's like organizing our data into neat monthly piles for each store.
WITH MonthlyBranchSales AS (
    SELECT
        b.branch_name,
        -- We'll truncate the date to the first day of the month to group sales by month.
        DATE_TRUNC('month', t.sale_date)::date AS sale_month,
        SUM(t.amount) AS monthly_sales
    FROM
        transactions t
    JOIN
        branches b ON t.branch_id = b.branch_id
    GROUP BY
        b.branch_name, TRUNC(t.sale_date, 'MM')
)
-- Afterwards, we'll select our monthly sales data and add the running total.
SELECT
    sale_month,
    branch_name,
    monthly_sales,
    -- The SUM() OVER() window function creates our running total.
    -- We 'PARTITION BY branch_name' to make sure the running total restarts for each branch.
    -- We 'ORDER BY sale_month' so the sum accumulates chronologically.
    SUM(monthly_sales) OVER (PARTITION BY branch_name ORDER BY sale_month) AS running_total_revenue
FROM
    MonthlyBranchSales
ORDER BY
    branch_name, sale_month;

3.-- GOAL 3: Analyze month-over-month revenue growth to check for consistency.
-- We'll start with the same CTE as before to get our monthly sales totals.
WITH MonthlyBranchSales AS (
    SELECT
        b.branch_name,
        DATE_TRUNC('month', t.sale_date)::date AS sale_month,
        SUM(t.amount) AS monthly_sales
    FROM
        transactions t
    JOIN
        branches b ON t.branch_id = b.branch_id
    GROUP BY
        b.branch_name, sale_month
),
-- Now, let's create a second CTE to add the previous month's sales data.
-- The LAG() function is like a time machine, letting us peek at the data from the row right before the current one.
SalesWithLag AS (
    SELECT
        sale_month,
        branch_name,
        monthly_sales,
        -- We'll grab the sales from 1 month ago. If it's the first month (no previous data), we'll default to 0.
        LAG(monthly_sales, 1, 0) OVER (PARTITION BY branch_name ORDER BY sale_month) AS previous_month_sales
    FROM
        MonthlyBranchSales
)
-- Finally, we can calculate the growth percentage using the current and previous month's sales.
SELECT
    sale_month,
    branch_name,
    monthly_sales,
    previous_month_sales,
    -- We use a CASE statement to prevent a 'divide by zero' error for the very first month.
    CASE WHEN previous_month_sales > 0 THEN
            ROUND(((monthly_sales - previous_month_sales) / previous_month_sales) * 100, 2)
        ELSE
            0
    END AS growth_percentage
FROM
    SalesWithLag
ORDER BY
    branch_name, sale_month;

4.-- GOAL 4 : Segment customers in our #1 branch into four spending tiers.
-- First, let's create a CTE to calculate the total spending for each customer,
--but ONLY at our top-performing Nyarugenge branch (branch_id = 1).
WITH CustomerSpending AS (
    SELECT
        customer_id,
        SUM(amount) AS total_spent
    FROM
        transactions
    WHERE
        branch_id = 1 -- We only care about customers of our best branch
    GROUP BY
        customer_id
)
-- Now, we'll join this data with the customers table to get their names
-- and then use NTILE(4) to assign them to a spending tier.
SELECT
    c.first_name || ' ' || c.last_name AS customer_name,
    cs.total_spent,
    -- NTILE(4) divides the customers into 4 groups.
    -- We order by total_spent DESC, so the highest spenders get put in group 1.
    CASE NTILE(4) OVER (ORDER BY cs.total_spent DESC)
        WHEN 1 THEN 'Platinum' WHEN 2 THEN 'Gold' WHEN 3 THEN 'Silver'
        WHEN 4 THEN 'Bronze'
    END AS customer_tier
FROM
    CustomerSpending cs
JOIN
    customers c ON cs.customer_id = c.customer_id
ORDER BY
    cs.total_spent DESC;

5.-- ADDITIONAL GOAL 5; for a better analysis:Calculate the 3-month moving average of transactions to see the real shopper traffic trend.
-- As always, we start with a CTE to organize our base data.
-- Here, we're just counting the number of sales transactions that happened each month in each branch.
WITH MonthlyTransactionCounts AS (
    SELECT
        b.branch_name,
        DATE_TRUNC('month', t.sale_date)::date AS sale_month,
        COUNT(t.transaction_id) AS transaction_count FROM transactions t JOIN branches b ON t.branch_id = b.branch_id
    GROUP BY
        b.branch_name, sale_month
)
-- Now, we select our monthly counts and apply the moving average.
SELECT
    sale_month,
    branch_name,
    transaction_count,
    -- This is the key part. We're calculating the average of the transaction counts.
    -- The 'frame clause' (ROWS BETWEEN...) is what makes it a '3-month moving' average.
    -- It tells the database to only average the current month and the two that came before it.
    ROUND(
        AVG(transaction_count) OVER (PARTITION BY branch_name ORDER BY sale_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),
        2
    ) AS three_month_moving_avg FROM MonthlyTransactionCounts ORDER BY
    branch_name, sale_month;
