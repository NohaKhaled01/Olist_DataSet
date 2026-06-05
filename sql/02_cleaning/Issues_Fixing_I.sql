# Issues to fix:
	# Date Time Columns: convert from varchar to date time - Done
		# Order reviews - Orders
    # Products Table: Fix lenght in column names to length - Done

SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'olist_db'
ORDER BY table_name, ordinal_position
;

CREATE TABLE order_items_backup AS
	SELECT * FROM order_items;

# Native DATETIME format:
	# YYYY-MM-DD HH:MM:SS
    
SELECT *
FROM order_reviews
;

DESCRIBE order_reviews ;

SELECT review_creation_date, STR_TO_DATE(review_creation_date, '%m/%d/%Y %H:%i'), review_answer_timestamp, STR_TO_DATE(review_answer_timestamp, '%m/%d/%Y %H:%i')
FROM order_reviews
;

UPDATE order_reviews
SET review_creation_date = STR_TO_DATE(review_creation_date, '%m/%d/%Y %H:%i')
;

UPDATE order_reviews
SET review_answer_timestamp = STR_TO_DATE(review_answer_timestamp, '%m/%d/%Y %H:%i')
;

ALTER TABLE order_reviews
MODIFY COLUMN review_creation_date DATETIME
;

ALTER TABLE order_reviews
MODIFY COLUMN review_answer_timestamp DATETIME
;

## Forgot to backup the orders table lol. opps.
SELECT *
FROM orders
;

DESCRIBE orders ;

ALTER TABLE orders
MODIFY COLUMN order_purchase_timestamp DATETIME,
MODIFY COLUMN order_approved_at DATETIME,
MODIFY COLUMN order_delivered_carrier_date DATETIME,
MODIFY COLUMN order_delivered_customer_date DATETIME,
MODIFY COLUMN order_estimated_delivery_date DATETIME
;

SELECT *
FROM orders
WHERE order_approved_at = ''
;

# Changing the empty fields to null:
UPDATE orders
SET 
	order_purchase_timestamp = NULLIF(order_purchase_timestamp, ''),
    order_approved_at = NULLIF(order_approved_at, ''),
    order_delivered_carrier_date = NULLIF(order_delivered_carrier_date, ''),
    order_delivered_customer_date = NULLIF(order_delivered_customer_date, ''),
    order_estimated_delivery_date = NULLIF(order_estimated_delivery_date, '')
;

-- ## Products column names:
CREATE TABLE products_backup AS
	SELECT * FROM products;

SELECT *
FROM products
;

ALTER TABLE products
RENAME COLUMN product_name_lenght TO product_name_length
;

ALTER TABLE products
RENAME COLUMN product_description_lenght TO product_description_length
;