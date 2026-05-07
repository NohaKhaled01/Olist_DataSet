# A Baseline Statistical Profile -- to make sure my questions and targetted insights are actually achievable 
# Columns to look at values distribution in:
# price, frieght value, order item id, payment value, payment installments, review score, submission - approval times, delivery estimate - actual delivery, product weight, product dimensions (volume).
-----
# Some definitions for myself:
# Mean -- Average | Median -- Middle Value | Mode -- Most frequent value
# CV -- Coefficient of Variation [STDDEV/Mean] .. the lower, the most clustered the values around the mean .. the higher, the more spread around the values are


# 4. submission, approval times, delivery estimates, actual delivery - orders table:
SELECT *
FROM orders
LIMIT 10
;

DESCRIBE orders ;

# Notes:
	# All time stamp columns were imported as VARCHAR. Will need to change to date time type to work on.
    
SELECT 
	COUNT(*) as total_rows,
	COUNT(order_purchase_timestamp) as non_null,
    COUNT(*) - COUNT(order_purchase_timestamp) as null_count,
    COUNT(order_approved_at) as non_null,
    COUNT(*) - COUNT(order_approved_at) as null_count,
    COUNT(order_delivered_carrier_date) as non_null,
    COUNT(*) - COUNT(order_delivered_carrier_date) as null_count,
    COUNT(order_delivered_customer_date) as non_null,
    COUNT(*) - COUNT(order_delivered_customer_date) as null_count,
    COUNT(order_estimated_delivery_date) as non_null,
    COUNT(*) - COUNT(order_estimated_delivery_date) as null_count
FROM orders
;

SELECT DISTINCT order_status
FROM orders
;
# Notes:
	# No null rows.
    # Total number of rows = 99441
    # Order statuses: Delivered - Unavaiable - Shipped - Canceled - Invoiced - Processing - Approved - Created
    # What is unavailable? lol - not sure [exploring below]:

SELECT COUNT(*)
from orders
WHERE order_status = 'unavailable'
; #609 unavailable orders in orders table

SELECT COUNT(*), COUNT(DISTINCT order_id)
FROM order_items
WHERE order_id IN 
(
	SELECT order_id
	from orders
	WHERE order_status = 'unavailable'
)
; 
# Notes:
	# 7 unavailable order id in order_items table - 6 distinct order ids [6 different orders]
	# What about the rest of the 609? they dont have enteries in the items table. 

SELECT COUNT(*), COUNT(DISTINCT order_id)
FROM order_payments
WHERE order_id IN 
(
	SELECT order_id
	from orders
	WHERE order_status = 'unavailable'
)
;

SELECT *
FROM order_payments
WHERE order_id IN 
(
	SELECT order_id
	from orders
	WHERE order_status = 'unavailable'
)
;
# Notes:
	# 649 unavailable order id in order_payments table - 609 distinct order ids [609 orders .. similar to the orders table]
    # All the orders have payment data.
    # Not possible to check if these orders had any refunds. 
--
	# Insights I wanted to derive from these values:
		# Does the time between purchase time and approval time  change with payment methods? [join to orders payments table]
        # Gap between estimated delivery date and actual delivery date - could give a sneak peak into the margin Olist give themselves. 
			# Follow up questions for this point:
				# Is estimated - approved always fixed? If no, what affects its change? Number of items? Number of sellers?
				# What does the actual delivery look like versus the estimated? More often on time than late, or vice versa?
				# Reviews for late deliveries - if any.
----
# 5. Products Table:

SELECT *
FROM products
;

SELECT 
	COUNT(*) as total_rows,
	COUNT(product_id) as non_null,
    COUNT(*) - COUNT(product_id) as null_count    
FROM products
;
# Notes:
	# Total number of rows: 32951. No Null rows for product ids

SELECT product_category_name, COUNT(*)
FROM products
GROUP BY product_category_name
ORDER BY product_category_name
; # Number of product enteries for each category

SELECT COUNT(DISTINCT product_category_name)
FROM products
;
# Notes:
	# Number of categories: 74 -- is this the same as the number in the translation table? -- query below, answer: No. There are 71 categories in the translation table. Why the difference?
		# Fixed below. Added the missing categories and their translation manually.
    
SELECT COUNT(DISTINCT product_category_name), COUNT(DISTINCT product_category_name_english)
FROM translation
; # 71 categories

SELECT DISTINCT p.product_category_name as product_categories, t.product_category_name as translation_categories
FROM products as p
LEFT JOIN translation as t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL or t.product_category_name = ''
; 
# Notes:
	# There are three categories in the products table with no matches in the translation table:
    # Null categories - pc_gamer - portateis_cozinha_e_preparadores_de_alimentos

SELECT COUNT(*)
FROM products
WHERE product_category_name = ''
; # 610 product ids with no product category name

SELECT COUNT(*)
FROM translation
WHERE product_category_name = '' OR product_category_name IS NULL
; # No null enteries in the translation table, makes sense.

# pc_gamer - portateis_cozinha_e_preparadores_de_alimentos
# Lets try to look for this manually in the translation table - maybe they are there but misspelled or sth

SELECT *
FROM translation
;

# They are not there, so will have to add them ourselves and add their english translation
# pc_gamer will go as it is
# portateis_cozinha_e_preparadores_de_alimentos will be kitchen_and_food_preparators_portables

INSERT INTO translation (product_category_name, product_category_name_english)
VALUES ('pc_gamer', 'pc_gamer'), 
		('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_and_food_preparators_portables')
;

SELECT *
FROM translation
;

# Checking the 610 missing categories products in the products table - were these products ever ordered? They have no name, description, or photos -- queries below
# Output: The products were ordered, delivered, and many of the order ids have reviews.
# Many of the orders with these products had one product in the order -- so only this unknown product was ordered, and delivered, and reviewed lol.
# Explanation is: Either the database didn't catch the details of these products, or this is an allowed thing on Olist, where a product can be added to the website without any description or photos or name lol, which seems unlikely.

SELECT order_status, COUNT(*)
FROM orders
WHERE order_id IN (
	SELECT order_id
	FROM order_items
	WHERE product_id IN (
		SELECT product_id
		FROM products
		WHERE product_category_name = ''
		)
	)
GROUP BY order_status
;
  
SELECT *
FROM order_items
;

SELECT *
FROM order_reviews
WHERE order_id IN (
	SELECT order_id
	FROM order_items
	WHERE product_id IN (
		SELECT product_id
		FROM products
		WHERE product_category_name = ''
		)
	)
ORDER BY review_score
;

SELECT order_item_id, COUNT(*)
FROM order_items
WHERE order_id IN (
	SELECT order_id
		FROM order_items
		WHERE product_id IN (
			SELECT product_id
			FROM products
			WHERE product_category_name = ''
			)
		)
GROUP BY order_item_id
;

SELECT *
FROM order_reviews
WHERE order_id IN (
	SELECT order_id
	FROM order_items
	WHERE product_id IN (
		SELECT product_id
		FROM products
		WHERE product_category_name = ''
		)
	)
ORDER BY review_score
;

# As a double check, i want the orders where only the unknown product was ordered - nothing else:
SELECT *
FROM order_reviews
WHERE order_id IN (
	SELECT order_id
		FROM order_items
		WHERE product_id IN (
			SELECT product_id
			FROM products
			WHERE product_category_name = ''
			)
	GROUP BY order_id
	HAVING COUNT(order_item_id) = 1
    )
;
--
# Issues I wanted to fix, and fixed:
	# Difference between number of categories in product tables versus in translation table - fixed, manually added the 2 missing categories in the translation table.
    # Are the products with missing data actual products? Yes.
    
# Insights I wanted to derive from this table:
	# Relation between product weight/volume, and freight value - if any
    # Relation between product weight/volume, and delivery time - if any
    # Number of products per category - which are the most represented?
    # Categories versus orders - which categories have the highest demand?
    # Categories with highest and lowest review scores - find if there is a relationship there.
    