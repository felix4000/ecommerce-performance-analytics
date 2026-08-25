-- ============================================================
-- Customer Analysis
-- Dataset: orders.csv, customers.csv (synthetic, see /data)
-- Schema assumed:
--   customers(customer_id, country, device, customer_type, first_purchase, repeat_purchase)
--   orders(order_id, customer_id, product_id, order_date, quantity, revenue, acquisition_channel)
-- ============================================================

-- 1. Revenue and order count by customer type (B2C vs B2B)
SELECT
    c.customer_type,
    COUNT(DISTINCT c.customer_id)              AS customers,
    COUNT(DISTINCT o.order_id)                 AS orders,
    ROUND(SUM(o.revenue), 2)                   AS revenue,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_type
ORDER BY revenue DESC;

-- 2. Repeat vs one-time customers: revenue contribution
SELECT
    c.repeat_purchase,
    COUNT(DISTINCT c.customer_id)  AS customers,
    ROUND(SUM(o.revenue), 2)       AS revenue,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.repeat_purchase;

-- 3. Revenue by country
SELECT
    c.country,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.revenue), 2)      AS revenue,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.country
ORDER BY revenue DESC;

-- 4. Customer value by device used
SELECT
    c.device,
    COUNT(DISTINCT c.customer_id) AS customers,
    ROUND(SUM(o.revenue), 2)      AS revenue,
    ROUND(AVG(o.revenue), 2)      AS avg_order_value
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.device
ORDER BY revenue DESC;

-- 5. Simple RFM-style scoring (Recency in days, Frequency, Monetary)
-- Uses MAX(order_date) in the dataset as the reference "today" date
WITH last_date AS (SELECT MAX(order_date) AS today FROM orders),
customer_orders AS (
    SELECT
        o.customer_id,
        MAX(o.order_date)              AS last_order_date,
        COUNT(o.order_id)              AS frequency,
        SUM(o.revenue)                 AS monetary
    FROM orders o
    GROUP BY o.customer_id
)
SELECT
    co.customer_id,
    CAST(julianday(ld.today) - julianday(co.last_order_date) AS INTEGER) AS recency_days,
    co.frequency,
    ROUND(co.monetary, 2) AS monetary
FROM customer_orders co, last_date ld
ORDER BY monetary DESC
LIMIT 25;

-- 6. Acquisition channel that produces the highest-value customers (first order channel)
WITH first_order AS (
    SELECT customer_id, acquisition_channel,
           ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS rn
    FROM orders
)
SELECT
    fo.acquisition_channel,
    COUNT(DISTINCT fo.customer_id)  AS customers_acquired,
    ROUND(SUM(o.revenue), 2)        AS lifetime_revenue_so_far,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT fo.customer_id), 2) AS revenue_per_acquired_customer
FROM first_order fo
JOIN orders o ON o.customer_id = fo.customer_id
WHERE fo.rn = 1
GROUP BY fo.acquisition_channel
ORDER BY revenue_per_acquired_customer DESC;
