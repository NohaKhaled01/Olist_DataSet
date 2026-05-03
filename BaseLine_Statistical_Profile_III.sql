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
                
        
SELECT *
FROM orders
;
        


