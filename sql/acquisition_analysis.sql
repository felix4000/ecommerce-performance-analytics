-- ============================================================
-- Acquisition Analysis
-- Dataset: orders.csv (acquisition_channel column, synthetic)
-- Goal: compare channels on volume, revenue and efficiency so
-- budget and content decisions are backed by numbers, not gut feel.
-- ============================================================

-- 1. Orders and revenue by acquisition channel
SELECT
    acquisition_channel,
    COUNT(order_id)              AS orders,
    ROUND(SUM(revenue), 2)       AS revenue,
    ROUND(AVG(revenue), 2)       AS avg_order_value,
    ROUND(100.0 * SUM(revenue) / (SELECT SUM(revenue) FROM orders), 1) AS pct_of_total_revenue
FROM orders
GROUP BY acquisition_channel
ORDER BY revenue DESC;

-- 2. Channel mix trend over time (monthly)
SELECT
    strftime('%Y-%m', order_date)  AS month,
    acquisition_channel,
    COUNT(order_id)                AS orders,
    ROUND(SUM(revenue), 2)         AS revenue
FROM orders
GROUP BY 1, 2
ORDER BY 1, revenue DESC;

-- 3. Channel performance by customer type (does paid work better for B2B or B2C?)
SELECT
    o.acquisition_channel,
    c.customer_type,
    COUNT(o.order_id)        AS orders,
    ROUND(SUM(o.revenue), 2) AS revenue
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.acquisition_channel, c.customer_type
ORDER BY o.acquisition_channel, revenue DESC;

-- 4. New vs returning customers, by channel
SELECT
    o.acquisition_channel,
    c.repeat_purchase,
    COUNT(DISTINCT c.customer_id) AS customers
FROM orders o
JOIN customers c ON c.customer_id = o.customer_id
GROUP BY o.acquisition_channel, c.repeat_purchase
ORDER BY o.acquisition_channel;
