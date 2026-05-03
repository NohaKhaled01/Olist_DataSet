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
# Notes:
	# Insights I wanted to derive from these values:
		# Gap between review creation date, and review answer timestamp -- and does it change with the review score?
        # Is the review request sent the day after the delivery?
        # Does the comment length vary with the review score?
        # What % of reviews have comments?