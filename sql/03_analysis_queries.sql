-- Business Question 1: Bagaimana trend revenue bulanan? 
SELECT 
    year_month, 
    COUNT(DISTINCT order_id)          AS total_orders, 
    COUNT(DISTINCT customer_id)       AS unique_customers, 
    ROUND(SUM(total_item_value)::NUMERIC, 2)  AS total_revenue, 
    ROUND(AVG(total_item_value)::NUMERIC, 2)  AS avg_order_value 
FROM clean_orders_master 
WHERE order_status = 'delivered' 
  AND year_month BETWEEN '2017-01' AND '2018-08'  
GROUP BY year_month 
ORDER BY year_month;

-- Business Question 2: Kategori produk mana paling revenue? 
SELECT 
    product_category, 
    COUNT(DISTINCT order_id)                    AS total_orders, 
    SUM(item_sequence)                          AS total_items_sold, 
    ROUND(SUM(total_item_value)::NUMERIC, 2)    AS total_revenue, 
    ROUND(AVG(item_price)::NUMERIC, 2)          AS avg_price, 
    ROUND( 
        SUM(total_item_value) * 100.0 / 
        SUM(SUM(total_item_value)) OVER() 
    , 2)                                        AS revenue_pct 
FROM clean_orders_master 
WHERE order_status = 'delivered' 
  AND product_category IS NOT NULL 
GROUP BY product_category 
ORDER BY total_revenue DESC 
LIMIT 15;

-- Business Question 3: Seberapa sering pengiriman terlambat? 
SELECT 
    delivery_status, 
    COUNT(*)                            AS jumlah, 
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS persentase, 
    ROUND(AVG(delivery_days)::NUMERIC, 1) AS avg_delivery_days 
FROM clean_orders_master 
WHERE delivery_status IN ('Late', 'On Time') 
  AND delivery_days IS NOT NULL 
GROUP BY delivery_status; 

  -- Breakdown keterlambatan per state customer 
SELECT 
    customer_state, 
    COUNT(*) FILTER (WHERE delivery_status = 'Late')        AS late_orders, 
    COUNT(*) FILTER (WHERE delivery_status = 'On Time')     AS ontime_orders, 
    ROUND( 
        COUNT(*) FILTER (WHERE delivery_status = 'Late') * 100.0 / COUNT(*) 
    , 2)                                                     AS late_rate_pct 
FROM clean_orders_master 
WHERE delivery_status IN ('Late', 'On Time') 
GROUP BY customer_state 
ORDER BY late_rate_pct DESC 
LIMIT 10; 

-- BQ-4: Distribusi Review Score 
SELECT 
    review_score, 
    COUNT(*)                                     AS jumlah_review, 
    ROUND(COUNT(*)*100.0/SUM(COUNT(*)) OVER(), 2) AS persentase 
FROM clean_orders_master 
WHERE review_score IS NOT NULL 
GROUP BY review_score 
ORDER BY review_score; 

  -- BQ-5: Top 10 State by Jumlah Order 
SELECT 
    customer_state, 
    COUNT(DISTINCT order_id)                   AS total_orders, 
    ROUND(SUM(total_item_value)::NUMERIC, 2)   AS total_revenue 
FROM clean_orders_master 
WHERE order_status = 'delivered' 
GROUP BY customer_state 
ORDER BY total_orders DESC 
LIMIT 10; 

  -- BQ-6: Metode Pembayaran 
SELECT 
    payment_type, 
    COUNT(DISTINCT order_id)                    AS jumlah_order, 
    ROUND(AVG(payment_value)::NUMERIC, 2)       AS avg_payment, 
    ROUND(AVG(installments)::NUMERIC, 1)        AS avg_installments 
FROM clean_orders_master 
WHERE payment_type IS NOT NULL 
GROUP BY payment_type 
ORDER BY jumlah_order DESC; 

  -- BQ-7: Average Order Value per Bulan 
SELECT 
    year_month, 
    ROUND(AVG(total_item_value)::NUMERIC, 2)  AS aov 
FROM clean_orders_master 
WHERE order_status = 'delivered' 
  AND year_month BETWEEN '2017-01' AND '2018-08' 
GROUP BY year_month 
ORDER BY year_month; 

  -- BQ-8: Korelasi Delivery Days vs Review Score 
SELECT 
    review_score, 
    ROUND(AVG(delivery_days)::NUMERIC, 1) AS avg_delivery_days, 
    COUNT(*)                              AS jumlah 
FROM clean_orders_master 
WHERE review_score IS NOT NULL 
  AND delivery_days IS NOT NULL 
  AND delivery_days BETWEEN 1 AND 60 
GROUP BY review_score 
ORDER BY review_score; 
-- Ekspektasi: semakin lama pengiriman, semakin rendah rating