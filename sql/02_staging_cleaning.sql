-- ═══════════════════════════════════════════════════════ 
-- AUDIT RAW DATA 
-- checking raw data 
-- ═══════════════════════════════════════════════════════ 


-- A1. Preview tiap tabel 
SELECT * FROM raw_orders        LIMIT 5; 
SELECT * FROM raw_order_items   LIMIT 5; 
SELECT * FROM raw_customers     LIMIT 5; 
SELECT * FROM raw_products      LIMIT 5; 

-- A2. Cek NULL di tabel orders
SELECT 
    COUNT(*)                                        AS total_rows, 
    COUNT(*) - COUNT(order_id)                      AS null_order_id, 
    COUNT(*) - COUNT(customer_id)                   AS null_customer_id, 
    COUNT(*) - COUNT(order_status)                  AS null_order_status, 
    COUNT(*) - COUNT(order_purchase_timestamp)      AS null_purchase_ts, 
    COUNT(*) - COUNT(order_delivered_customer_date) AS null_delivered_date, 
    COUNT(*) - COUNT(order_estimated_delivery_date) AS null_estimated_date 
FROM raw_orders; 

-- A3. Cek nilai unik order_status 
SELECT order_status, COUNT(*) AS jumlah 
FROM raw_orders 
GROUP BY order_status 
ORDER BY jumlah DESC;
 

  -- A4. Cek NULL di order_items 
SELECT 
    COUNT(*) - COUNT(order_id)      AS null_order_id, 
    COUNT(*) - COUNT(product_id)    AS null_product_id, 
    COUNT(*) - COUNT(price)         AS null_price, 
    COUNT(*) - COUNT(freight_value) AS null_freight 
FROM raw_order_items; 

-- A5. Cek apakah price mengandung nilai non-numerik 
SELECT price FROM raw_order_items 
WHERE price !~ '^[0-9]+(\.[0-9]+)?$' 
LIMIT 20; 

-- A6. Cek duplikat di orders 
SELECT order_id, COUNT(*) AS muncul 
FROM raw_orders 
GROUP BY order_id 
HAVING COUNT(*) > 1; 

-- A7. Cek NULL produk di tabel products 
SELECT 
    COUNT(*) - COUNT(product_id)            AS null_product_id, 
    COUNT(*) - COUNT(product_category_name) AS null_category_name 
FROM raw_products; 

-- A8. Cek rentang tanggal 
SELECT 
    MIN(order_purchase_timestamp) AS order_paling_lama, 
    MAX(order_purchase_timestamp) AS order_paling_baru 
FROM raw_orders; 

-- ═══════════════════════════════════════════════════════ 
--  STAGING TABLES 
-- ═══════════════════════════════════════════════════════ 

-- Make staging tables 
CREATE TABLE staging_orders                AS SELECT * FROM raw_orders; 
CREATE TABLE staging_order_items           AS SELECT * FROM raw_order_items; 
CREATE TABLE staging_order_payments        AS SELECT * FROM raw_order_payments; 
CREATE TABLE staging_order_reviews         AS SELECT * FROM raw_order_reviews; 
CREATE TABLE staging_customers             AS SELECT * FROM raw_customers; 
CREATE TABLE staging_sellers               AS SELECT * FROM raw_sellers; 
CREATE TABLE staging_products              AS SELECT * FROM raw_products; 

-- Verifikasi jumlah baris identik 
WITH counts AS (
    SELECT 
        (SELECT COUNT(*) FROM raw_orders) AS raw,
        (SELECT COUNT(*) FROM staging_orders) AS staging
)
SELECT 
    raw,
    staging,
    CASE 
        WHEN raw = staging THEN '✓ SAMA'
        ELSE '✗ BEDA - CEK ULANG'
    END AS status
FROM counts;

-- ═══════════════════════════════════════════════════════ 
-- BAGIAN C: CLEANING staging_orders 
-- ═══════════════════════════════════════════════════════ 

ALTER TABLE staging_orders 
    ADD COLUMN purchase_ts     TIMESTAMP, 
    ADD COLUMN approved_ts     TIMESTAMP, 
    ADD COLUMN delivered_ts    TIMESTAMP, 
    ADD COLUMN estimated_ts    TIMESTAMP; 

UPDATE staging_orders SET 
    purchase_ts  = order_purchase_timestamp::TIMESTAMP, 
    approved_ts  = NULLIF(order_approved_at, '')::TIMESTAMP, 
    delivered_ts = NULLIF(order_delivered_customer_date, '')::TIMESTAMP, 
    estimated_ts = NULLIF(order_estimated_delivery_date, '')::TIMESTAMP;

DELETE FROM staging_orders 
WHERE order_id IS NULL OR customer_id IS NULL;

CREATE TABLE staging_orders_canceled AS 
SELECT * FROM staging_orders 
WHERE order_status IN ('canceled', 'unavailable');

DELETE FROM staging_orders 
WHERE order_status IN ('canceled', 'unavailable'); 

#verifikasi 
SELECT order_status, COUNT(*) FROM staging_orders GROUP BY order_status;

SELECT order_status,
COUNT(*) AS total  FROM staging_orders
GROUP BY order_status

-- ═══════════════════════════════════════════════════════ 
-- BAGIAN E: CLEANING staging_products 
-- ═══════════════════════════════════════════════════════ 

-- E1. Replace NULL values in product_category_name with 'others' 

UPDATE staging_products 
SET product_category_name = 'others' 
WHERE product_category_name IS NULL; 

-- E2. Add an English category name column (JOIN with translation)

ALTER TABLE staging_products 
    ADD COLUMN category_english VARCHAR(200); 
  
UPDATE staging_products sp 
SET category_english = COALESCE(t.product_category_name_english, 
sp.product_category_name) 
FROM raw_product_category_translation t 
WHERE sp.product_category_name = t.product_category_name; 

-- For entries not found in the translation table, use the original name
UPDATE staging_products 
SET category_english = product_category_name 
WHERE category_english IS NULL; 

  -- E3. Verifikasi 
SELECT category_english, COUNT(*) AS jumlah_produk 
FROM staging_products 
GROUP BY category_english 
ORDER BY jumlah_produk DESC 
LIMIT 15; 

-- ═══════════════════════════════════════════════════════ 
-- BAGIAN F: Cleaning staging_order_items
-- ═══════════════════════════════════════════════════════ 

ALTER TABLE staging_order_items
ADD COLUMN price_num NUMERIC(10,2),
ADD COLUMN freight_value_num NUMERIC(10,2);
ADD COLUMN order_item_id_int INTEGER
ADD COLUMN total_item_value NUMERIC(10,2);

UPDATE staging_order_items
SET
    price_num = price::NUMERIC(10,2),
    freight_value_num = freight_value::NUMERIC(10,2),
    order_item_id_int = order_item_id::INTEGER
    total_item_value = price_num + freight_value_num;

-- ═══════════════════════════════════════════════════════ 
-- BAGIAN F: BUAT TABEL ANALISA UTAMA  
-- ═══════════════════════════════════════════════════════ 
  
DROP TABLE IF EXISTS clean_orders_master; 

CREATE TABLE clean_orders_master AS 
SELECT 
    -- Identifiers 
    o.order_id, 
    o.customer_id, 
    c.customer_unique_id, 
    c.customer_city, 
    c.customer_state, 
  
    -- Order info 
    o.order_status, 
    o.purchase_ts                              AS order_date, 
    DATE_TRUNC('month', o.purchase_ts)         AS order_month, 
    EXTRACT(YEAR  FROM o.purchase_ts)          AS order_year, 
    EXTRACT(MONTH FROM o.purchase_ts)          AS order_month_num, 
    TO_CHAR(o.purchase_ts, 'YYYY-MM')          AS year_month, 
  
    -- Product info 
    i.product_id, 
    p.category_english                         AS product_category, 
    i.order_item_id_int                        AS item_sequence, 
  
    -- Financials 
    i.price_num                                AS item_price, 
    i.freight_value_num                        AS freight_value, 
    i.total_item_value, 
  
    -- Payment 
    pay.payment_type, 
    pay.payment_value::NUMERIC(12,2)           AS payment_value, 
    pay.payment_installments::INTEGER          AS installments, 
  
    -- Delivery performance 
    o.estimated_ts                             AS estimated_delivery, 
    o.delivered_ts                             AS actual_delivery, 
    CASE 
        WHEN o.delivered_ts IS NOT NULL AND o.purchase_ts IS NOT NULL 
        THEN EXTRACT(DAY FROM o.delivered_ts - o.purchase_ts) 
        ELSE NULL 
    END                                        AS delivery_days, 
    CASE 
        WHEN o.delivered_ts > o.estimated_ts THEN 'Late' 
        WHEN o.delivered_ts <= o.estimated_ts THEN 'On Time' 
        ELSE 'Not Yet Delivered' 
    END                                        AS delivery_status, 
  
    -- Review 
    r.review_score::INTEGER                    AS review_score, 
  
    -- Seller 
    i.seller_id, 
    s.seller_state 
  
FROM staging_orders o 
LEFT JOIN staging_order_items  i   ON o.order_id  = i.order_id 
LEFT JOIN staging_products     p   ON i.product_id = p.product_id 
LEFT JOIN staging_customers    c   ON o.customer_id = c.customer_id 
LEFT JOIN staging_sellers      s   ON i.seller_id   = s.seller_id 
LEFT JOIN raw_order_payments   pay ON o.order_id    = pay.order_id 
                                   AND pay.payment_sequential = '1' 
LEFT JOIN staging_order_reviews r  ON o.order_id   = r.order_id; 


  -- Verifikasi table master 
SELECT COUNT(*) AS total_rows FROM clean_orders_master; 
SELECT * FROM clean_orders_master LIMIT 5; 


  -- Ringkasan statistik dasar 
SELECT 
    COUNT(DISTINCT order_id)      AS unique_orders, 
    COUNT(DISTINCT customer_id)   AS unique_customers, 
    COUNT(DISTINCT product_id)    AS unique_products, 
    COUNT(DISTINCT seller_id)     AS unique_sellers, 
    MIN(order_date)               AS earliest_order, 
    MAX(order_date)               AS latest_order, 
    ROUND(AVG(total_item_value)::NUMERIC, 2) AS avg_order_value 
FROM clean_orders_master;