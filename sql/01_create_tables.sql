-- TABLE 1 :  ORDER ---
CREATE TABLE
    IF NOT EXISTS raw_orders (
        order_id VARCHAR(100),
        customer_id VARCHAR(100),
        order_status VARCHAR(50),
        order_purchase_timestamp VARCHAR(50),
        order_approved_at VARCHAR(50),
        order_delivered_carrier_date VARCHAR(50),
        order_delivered_customer_date VARCHAR(50),
        order_estimated_delivery_date VARCHAR(50)
    );

---- TABLE 2 : ORDER ITEM ----
CREATE TABLE
    IF NOT EXISTS raw_order_items (
        order_id VARCHAR(100),
        order_item_id VARCHAR(20),
        product_id VARCHAR(100),
        seller_id VARCHAR(100),
        shipping_limit_date VARCHAR(50),
        price VARCHAR(30),
        freight_value VARCHAR(30)
    );

----- TABLE 3 : ORDER PAYMENT ------
CREATE TABLE
    IF NOT EXISTS raw_order_payments (
        order_id VARCHAR(100),
        payment_sequential VARCHAR(10),
        payment_type VARCHAR(50),
        payment_installments VARCHAR(10),
        payment_value VARCHAR(30)
    );

----- TABLE 4 : ORDER REVIEWS ------
CREATE TABLE
    IF NOT EXISTS raw_order_reviews (
        review_id VARCHAR(100),
        order_id VARCHAR(100),
        review_score VARCHAR(5),
        review_comment_title VARCHAR(500),
        review_comment_message VARCHAR(5000),
        review_creation_date VARCHAR(50),
        review_answer_timestamp VARCHAR(50)
    );

----- TABLE 5 : CUSTOMER ----
CREATE TABLE
    IF NOT EXISTS raw_customer (
        customer_id VARCHAR(100),
        customer_unique_id VARCHAR(100),
        customer_zip_code_prefix VARCHAR(20),
        customer_city VARCHAR(200),
        customer_state VARCHAR(10)
    );

----- TABLE 6 : SELLER ----
CREATE TABLE
    IF NOT EXISTS raw_seller (
        seller_id VARCHAR(100),
        seller_zip_code_prefix VARCHAR(20),
        seller_city VARCHAR(200),
        seller_state VARCHAR(10)
    );

----- TABLE 7 : PRODUCT ----
CREATE TABLE
    IF NOT EXISTS raw_products (
        product_id VARCHAR(100),
        product_category_name VARCHAR(200),
        product_name_length VARCHAR(20),
        product_description_length VARCHAR(20),
        product_photos_qty VARCHAR(10),
        product_weight_g VARCHAR(20),
        product_length_cm VARCHAR(20),
        product_height_cm VARCHAR(20),
        product_width_cm VARCHAR(20)
    );

-- TABEL 8: PRODUCT CATEGORY TRANSLATION -- 
CREATE TABLE
    IF NOT EXISTS raw_product_category_translation (
        product_category_name VARCHAR(200),
        product_category_name_english VARCHAR(200)
    );

-- TABEL 9: GEOLOCATION -- 
CREATE TABLE
    IF NOT EXISTS raw_geolocation (
        geolocation_zip_code_prefix VARCHAR(20),
        geolocation_lat VARCHAR(30),
        geolocation_lng VARCHAR(30),
        geolocation_city VARCHAR(200),
        geolocation_state VARCHAR(10)
    );



