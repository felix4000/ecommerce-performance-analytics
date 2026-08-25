-- ============================================================
-- E-commerce Funnel Analysis
-- Dataset: website_daily.csv (synthetic full-site aggregates)
-- Funnel: Sessions -> Product Views -> Add to Cart -> Checkout -> Purchase
-- ============================================================

-- 1. Full funnel with conversion rate at each step (period total)
SELECT
    SUM(sessions)       AS sessions,
    SUM(product_views)  AS product_views,
    SUM(add_to_cart)    AS add_to_cart,
    SUM(checkout)       AS checkout,
    SUM(purchases)      AS purchases,
    ROUND(100.0 * SUM(add_to_cart) / NULLIF(SUM(sessions), 0), 2)   AS cart_rate_pct,
    ROUND(100.0 * SUM(checkout) / NULLIF(SUM(add_to_cart), 0), 2)   AS checkout_completion_pct,
    ROUND(100.0 * SUM(purchases) / NULLIF(SUM(checkout), 0), 2)     AS purchase_completion_pct,
    ROUND(100.0 * SUM(purchases) / NULLIF(SUM(sessions), 0), 2)     AS overall_conversion_rate_pct,
    ROUND(SUM(revenue) / NULLIF(SUM(sessions), 0), 2)               AS revenue_per_session
FROM website_daily;

-- 2. Monthly funnel trend, to catch drop-off before it shows up in revenue
SELECT
    strftime('%Y-%m', date)                                          AS month,
    SUM(sessions)                                                    AS sessions,
    SUM(add_to_cart)                                                 AS add_to_cart,
    SUM(checkout)                                                    AS checkout,
    SUM(purchases)                                                   AS purchases,
    ROUND(100.0 * SUM(purchases) / NULLIF(SUM(sessions), 0), 2)      AS conversion_rate_pct,
    ROUND(100.0 * SUM(checkout) / NULLIF(SUM(add_to_cart), 0), 2)    AS checkout_completion_pct
FROM website_daily
GROUP BY 1
ORDER BY 1;

-- 3. Weekday vs weekend funnel behaviour
SELECT
    CASE WHEN strftime('%w', date) IN ('0','6') THEN 'weekend' ELSE 'weekday' END AS day_type,
    ROUND(AVG(sessions), 0)                                           AS avg_sessions,
    ROUND(100.0 * SUM(purchases) / NULLIF(SUM(sessions), 0), 2)       AS conversion_rate_pct,
    ROUND(SUM(revenue) / NULLIF(SUM(sessions), 0), 2)                 AS revenue_per_session
FROM website_daily
GROUP BY 1;

-- 4. Biggest single drop-off point in the funnel (as % of the previous step lost)
SELECT
    ROUND(100.0 * (SUM(sessions) - SUM(add_to_cart)) / NULLIF(SUM(sessions), 0), 1)   AS pct_lost_before_cart,
    ROUND(100.0 * (SUM(add_to_cart) - SUM(checkout)) / NULLIF(SUM(add_to_cart), 0), 1) AS pct_lost_at_checkout_start,
    ROUND(100.0 * (SUM(checkout) - SUM(purchases)) / NULLIF(SUM(checkout), 0), 1)      AS pct_lost_at_payment
FROM website_daily;
