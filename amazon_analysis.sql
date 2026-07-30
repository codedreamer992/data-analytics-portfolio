-- ================================================
-- Amazon Sales Dataset — SQL Analysis
-- Author: Murad Akhtar
-- Tool: SQLite
-- Dataset: 10,000 Amazon Sales Orders (Jan-Feb 2026)
-- ================================================


-- ================================================
-- SECTION 1: BASIC EXPLORATION
-- ================================================

-- Total KPIs
SELECT 
    COUNT(*) AS Total_Orders,
    SUM(total_sales) AS Total_Revenue,
    AVG(total_sales) AS Avg_Order_Value,
    MIN(total_sales) AS Min_Order,
    MAX(total_sales) AS Max_Order
FROM amazon;

-- Revenue by Category
SELECT 
    category,
    COUNT(*) AS Order_Count,
    SUM(total_sales) AS Total_Revenue,
    AVG(total_sales) AS Avg_Order_Value
FROM amazon
GROUP BY category
ORDER BY Total_Revenue DESC;

-- Monthly Revenue Trend
SELECT 
    Order_Month_Name,
    Order_Month_no,
    COUNT(*) AS Order_Count,
    SUM(total_sales) AS Monthly_Revenue
FROM amazon
GROUP BY Order_Month_Name, Order_Month_no
ORDER BY Order_Month_no;

-- Top 10 States by Revenue
SELECT 
    state,
    COUNT(*) AS Order_Count,
    SUM(total_sales) AS Total_Revenue
FROM amazon
GROUP BY state
ORDER BY Total_Revenue DESC
LIMIT 10;


-- ================================================
-- SECTION 2: JOINS
-- ================================================

-- Three Table JOIN
-- orders + customers + amazon (for product/category)
SELECT 
    o.order_id,
    c.customer_name,
    c.state,
    a.product_name,
    a.category,
    o.total_sales
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id
INNER JOIN amazon a ON o.order_id = a.order_id
LIMIT 20;

-- Revenue by Category using JOIN
SELECT 
    a.category,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_sales) AS Total_Revenue,
    AVG(o.total_sales) AS Avg_Order_Value
FROM orders o
INNER JOIN amazon a ON o.order_id = a.order_id
GROUP BY a.category
ORDER BY Total_Revenue DESC;

-- Top 10 Customers by Revenue
SELECT 
    c.customer_name,
    c.state,
    COUNT(o.order_id) AS Total_Orders,
    SUM(o.total_sales) AS Total_Revenue
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name, c.state
ORDER BY Total_Revenue DESC
LIMIT 10;


-- ================================================
-- SECTION 3: WINDOW FUNCTIONS
-- ================================================

-- Rank Orders Within Each Category
SELECT 
    order_id,
    category,
    total_sales,
    DENSE_RANK() OVER (
        PARTITION BY category 
        ORDER BY total_sales DESC
    ) AS Category_Rank
FROM amazon
LIMIT 30;

-- Top 3 Orders Per Category
SELECT * FROM (
    SELECT 
        order_id,
        category,
        total_sales,
        DENSE_RANK() OVER (
            PARTITION BY category 
            ORDER BY total_sales DESC
        ) AS category_rank
    FROM amazon
)
WHERE category_rank <= 3
ORDER BY category, total_sales DESC;

-- Month over Month Revenue with LAG
SELECT 
    Order_Month_Name,
    SUM(total_sales) AS Monthly_Revenue,
    LAG(SUM(total_sales)) OVER (
        ORDER BY Order_Month_no
    ) AS Previous_Month,
    SUM(total_sales) - LAG(SUM(total_sales)) OVER (
        ORDER BY Order_Month_no
    ) AS Revenue_Change
FROM amazon
GROUP BY Order_Month_Name, Order_Month_no
ORDER BY Order_Month_no;

-- Orders Above Category Average
SELECT 
    category,
    COUNT(*) AS Orders_Above_Average
FROM (
    SELECT 
        category,
        total_sales,
        AVG(total_sales) OVER (
            PARTITION BY category
        ) AS cat_avg
    FROM amazon
)
WHERE total_sales > cat_avg
GROUP BY category
ORDER BY Orders_Above_Average DESC;


-- ================================================
-- SECTION 4: CTEs AND CASE WHEN
-- ================================================

-- Order Tier Segmentation
WITH tiered_orders AS (
    SELECT *,
        CASE 
            WHEN total_sales > 100000 THEN 'High'
            WHEN total_sales >= 33000 THEN 'Medium'
            ELSE 'Low'
        END AS order_tier
    FROM amazon
)
SELECT 
    order_tier,
    COUNT(*) AS Order_Count,
    SUM(total_sales) AS Total_Revenue,
    AVG(total_sales) AS Avg_Order_Value
FROM tiered_orders
GROUP BY order_tier
ORDER BY Total_Revenue DESC;

-- Customer Segmentation (VIP / Loyal / Standard)
WITH customer_totals AS (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_sales) AS total_spent,
        AVG(total_sales) AS avg_order_value
    FROM amazon
    GROUP BY customer_id
),
customer_segments AS (
    SELECT 
        customer_id,
        order_count,
        total_spent,
        avg_order_value,
        CASE 
            WHEN total_spent > 100000 THEN 'VIP'
            WHEN total_spent >= 50000 THEN 'Loyal'
            ELSE 'Standard'
        END AS customer_segment
    FROM customer_totals
)
SELECT 
    customer_segment,
    COUNT(*) AS Customer_Count,
    AVG(total_spent) AS Avg_Spend_Per_Customer,
    SUM(total_spent) AS Segment_Total_Revenue
FROM customer_segments
GROUP BY customer_segment
ORDER BY Avg_Spend_Per_Customer DESC;

-- Monthly Growth Flag
WITH monthly_sales AS (
    SELECT 
        Order_Month_Name,
        Order_Month_no,
        SUM(total_sales) AS monthly_revenue,
        COUNT(*) AS order_count
    FROM amazon
    GROUP BY Order_Month_Name, Order_Month_no
),
monthly_with_lag AS (
    SELECT 
        Order_Month_Name,
        monthly_revenue,
        order_count,
        LAG(monthly_revenue) OVER (
            ORDER BY Order_Month_no
        ) AS prev_month_revenue
    FROM monthly_sales
),
monthly_with_growth AS (
    SELECT 
        Order_Month_Name,
        monthly_revenue,
        order_count,
        prev_month_revenue,
        monthly_revenue - prev_month_revenue AS revenue_change,
        CASE 
            WHEN prev_month_revenue IS NULL THEN 'First Month'
            WHEN monthly_revenue > prev_month_revenue THEN 'Growth'
            ELSE 'Decline'
        END AS trend_flag
    FROM monthly_with_lag
)
SELECT *
FROM monthly_with_growth;


-- ================================================
-- SECTION 5: BUSINESS QUESTIONS (DAY 13 PROJECT)
-- ================================================

-- Q1: Top 10% Customers by Revenue (NTILE)
WITH customer_revenue AS (
    SELECT 
        customer_id,
        COUNT(*) AS order_count,
        SUM(total_sales) AS total_spent,
        AVG(total_sales) AS avg_order_value
    FROM amazon
    GROUP BY customer_id
),
customer_deciles AS (
    SELECT *,
        NTILE(10) OVER (
            ORDER BY total_spent DESC
        ) AS revenue_decile
    FROM customer_revenue
),
segmented AS (
    SELECT 
        CASE 
            WHEN revenue_decile = 1 THEN 'Top 10%'
            ELSE 'Remaining 90%'
        END AS customer_segment,
        COUNT(*) AS total_customers,
        AVG(total_spent) AS avg_spent_per_customer,
        AVG(order_count) AS avg_order_per_customer
    FROM customer_deciles
    GROUP BY 
        CASE 
            WHEN revenue_decile = 1 THEN 'Top 10%'
            ELSE 'Remaining 90%'
        END
)
SELECT * FROM segmented;

-- Q2: Top 3 Products Per Category with Contribution %
WITH product_revenue AS (
    SELECT 
        product_id,
        product_name,
        category,
        SUM(total_sales) AS product_total_revenue
    FROM amazon
    GROUP BY product_id, product_name, category
),
category_revenue AS (
    SELECT 
        category,
        SUM(total_sales) AS category_total_revenue
    FROM amazon
    GROUP BY category
),
product_contribution AS (
    SELECT 
        p.product_id,
        p.product_name,
        p.category,
        p.product_total_revenue,
        c.category_total_revenue,
        ROUND(
            p.product_total_revenue * 100.0 / 
            c.category_total_revenue, 2
        ) AS contribution_percentage,
        DENSE_RANK() OVER (
            PARTITION BY p.category 
            ORDER BY p.product_total_revenue DESC
        ) AS revenue_rank
    FROM product_revenue p
    INNER JOIN category_revenue c 
        ON p.category = c.category
)
SELECT *
FROM product_contribution
WHERE revenue_rank <= 3
ORDER BY category, revenue_rank;

-- Q3: High Volume Low Value States
WITH state_stats AS (
    SELECT 
        state,
        COUNT(*) AS total_orders,
        SUM(total_sales) AS total_revenue,
        AVG(total_sales) AS avg_order_value
    FROM amazon
    GROUP BY state
),
state_ranked AS (
    SELECT *,
        DENSE_RANK() OVER (
            ORDER BY total_orders DESC
        ) AS order_count_rank,
        DENSE_RANK() OVER (
            ORDER BY avg_order_value DESC
        ) AS avg_value_rank
    FROM state_stats
)
SELECT 
    state,
    total_orders,
    total_revenue,
    avg_order_value,
    order_count_rank,
    avg_value_rank,
    CASE 
        WHEN order_count_rank <= 20 
        AND avg_value_rank > 30 THEN 'High Volume Low Value'
        ELSE 'Normal'
    END AS top20
FROM state_ranked
ORDER BY total_orders DESC;