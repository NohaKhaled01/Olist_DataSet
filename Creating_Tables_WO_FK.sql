SHOW TABLES ;

CREATE TABLE translation(
product_category_name VARCHAR(100),
product_category_name_english VARCHAR(100),
PRIMARY KEY (product_category_name)
)
;
CREATE TABLE customers (
customer_id CHAR(32),
customer_unique_id CHAR(32),
customer_zip_code_prefix CHAR(5),
customer_city VARCHAR(100),
customer_state CHAR(2),
PRIMARY KEY (customer_id)
)
;

CREATE TABLE products(
product_id CHAR(32),
product_category_name VARCHAR(100),
product_name_lenght TINYINT UNSIGNED,
product_description_lenght INT UNSIGNED,
product_photos_qty TINYINT UNSIGNED,
product_weight_g INT UNSIGNED,
product_length_cm TINYINT UNSIGNED,
product_height_cm TINYINT UNSIGNED,
product_width_cm TINYINT UNSIGNED,
PRIMARY KEY (product_id)
)
;

CREATE TABLE sellers(
seller_id CHAR(32),
seller_zip_code_prefix CHAR(5),
seller_city VARCHAR(100),
seller_state CHAR(2),
PRIMARY KEY (seller_id)
)
;

CREATE TABLE geolocation (
geolocation_zip_code_prefix CHAR(5),
geolocation_lat DECIMAL(17,13),
geolocation_lng DECIMAL(17,13),
geolocation_city VARCHAR(38),
geolocation_state CHAR(2),
PRIMARY KEY (geolocation_lat, geolocation_lng)
)
;

CREATE TABLE orders(
order_id CHAR(32),
customer_id CHAR(32),
order_status VARCHAR(20),
order_purchase_timestamp DATETIME,
order_approved_at DATETIME,
order_delivered_carrier_date DATETIME,
order_delivered_customer_date DATETIME,
order_estimated_delivery_date DATETIME,
PRIMARY KEY (order_id)
)
;

CREATE TABLE order_items(
order_id CHAR(32),
order_item_id TINYINT UNSIGNED,
product_id CHAR(32),
seller_id CHAR(32),
shipping_limit_date DATETIME,
price DECIMAL(10, 2),
freight_value DECIMAL(10, 2),
PRIMARY KEY (order_id, order_item_id)
)
;

CREATE TABLE order_payments(
order_id CHAR(32),
payment_sequential TINYINT UNSIGNED,
payment_type VARCHAR(11),
payment_installments TINYINT UNSIGNED,
payment_value DECIMAL(10, 2),
PRIMARY KEY (order_id, payment_sequential)
)
;

CREATE TABLE order_reviews(
review_id CHAR(32),
order_id CHAR(32),
review_score TINYINT UNSIGNED,
review_comment_title VARCHAR(500),
review_comment_message TEXT,
review_creation_date DATETIME,
review_answer_timestamp DATETIME,
PRIMARY KEY (review_id)
)
;







