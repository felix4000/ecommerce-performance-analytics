-- ============================================================
-- Sales Analysis
-- Dataset: orders.csv, products.csv (synthetic, see /data)
-- Schema assumed:
--   orders(order_id, customer_id, product_id, order_date, quantity, revenue, acquisition_channel)
--   products(product_id, category, brand, vehicle_type, price, cost, stock, oem_reference)
-- ============================================================

-- 1. Headline KPIs: revenue, orders, average order value
SELECT
    COUNT(DISTINCT o.order_id)                     AS total_orders,
    ROUND(SUM(o.revenue), 2)                        AS total_revenue,
    ROUND(SUM(o.revenue) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value,
    ROUND(SUM(o.quantity * p.cost), 2)              AS total_cost,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2)   AS gross_margin
FROM orders o
JOIN products p ON p.product_id = o.product_id;

-- 2. Revenue and margin by category
SELECT
    p.category,
    COUNT(DISTINCT o.order_id)                      AS orders,
    SUM(o.quantity)                                 AS units_sold,
    ROUND(SUM(o.revenue), 2)                        AS revenue,
    ROUND(SUM(o.revenue) - SUM(o.quantity * p.cost), 2) AS margin,
    ROUND(100.0 * (SUM(o.revenue) - SUM(o.quantity * p.cost)) / NULLIF(SUM(o.revenue), 0), 1) AS margin_pct
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.category
ORDER BY revenue DESC;

-- 3. Top 20 products by revenue (classic 80/20 check)
SELECT
    p.product_id,
    p.category,
    p.brand,
    COUNT(o.order_id)      AS orders,
    SUM(o.quantity)        AS units_sold,
    ROUND(SUM(o.revenue),2) AS revenue
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.category, p.brand
ORDER BY revenue DESC
LIMIT 20;

-- 4. Revenue concentration: share of revenue from top 10% of products
WITH product_revenue AS (
    SELECT p.product_id, SUM(o.revenue) AS revenue
    FROM orders o
    JOIN products p ON p.product_id = o.product_id
    GROUP BY p.product_id
),
ranked AS (
    SELECT product_id, revenue,
           NTILE(10) OVER (ORDER BY revenue DESC) AS decile
    FROM product_revenue
)
SELECT
    ROUND(100.0 * SUM(CASE WHEN decile = 1 THEN revenue ELSE 0 END) / SUM(revenue), 1) AS pct_revenue_from_top_decile
FROM ranked;

-- 5. Monthly revenue trend
SELECT
    strftime('%Y-%m', order_date) AS month,
    COUNT(DISTINCT order_id)      AS orders,
    ROUND(SUM(revenue), 2)        AS revenue
FROM orders
GROUP BY 1
ORDER BY 1;

-- 6. Stock risk: products with high sales velocity but low stock
SELECT
    p.product_id,
    p.category,
    p.stock,
    SUM(o.quantity) AS units_sold_period,
    ROUND(SUM(o.quantity) * 1.0 / NULLIF(p.stock, 0), 2) AS demand_to_stock_ratio
FROM orders o
JOIN products p ON p.product_id = o.product_id
GROUP BY p.product_id, p.category, p.stock
HAVING p.stock < 60 AND SUM(o.quantity) >= 5
ORDER BY demand_to_stock_ratio DESC;
