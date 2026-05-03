# A Baseline Statistical Profile -- to make sure my questions and targetted insights are actually achievable 
# Columns to look at values distribution in:
# price, frieght value, order item id, payment value, payment installments, review score, submission - approval times, delivery estimate - actual delivery, product weight, product dimensions (volume).
-----
# Some definitions for myself:
# Mean -- Average | Median -- Middle Value | Mode -- Most frequent value
# CV -- Coefficient of Variation [STDDEV/Mean] .. the lower, the most clustered the values around the mean .. the higher, the more spread around the values are

SELECT *
FROM order_payments
;

# 2. payment value, payment installments, payment sequential - order payments table:
SELECT 
	COUNT(*) as total_rows,
	COUNT(payment_value) as non_null_payment_values,
    COUNT(*) - COUNT(payment_value) as null_count,
    MIN(payment_value) as min_payment_value,
    MAX(payment_value) as max_payment_value,
    AVG(payment_value) as mean_payment_value,
    STDDEV(payment_value) as std_dev_payment_value,
    STDDEV(payment_value)/AVG(payment_value) as CV
FROM order_payments
;
# Notes: 
	# CV is 1.4, which is on the higher side -- payment values, like prices, are scattered.
    # No null prices. Total = 103886
    
SELECT COUNT(DISTINCT order_id)
FROM order_payments
;
# Total orders with payments = 99440

SELECT 
	COUNT(*) as total_rows,
	COUNT(payment_installments) as non_null_payment_installments,
    COUNT(*) - COUNT(payment_installments) as null_count,
    MIN(payment_installments) as min_payment_installments,
    MAX(payment_installments) as max_payment_installments,
    AVG(payment_installments) as mean_payment_installments,
    STDDEV(payment_installments) as std_dev_payment_installments,
    STDDEV(payment_installments)/AVG(payment_installments) as CV
FROM order_payments
;
# Notes: 
	# CV is 0.94, max installment is 24, and mean is 2.85.
    # No null prices. Total = 103886
    
    SELECT 
	COUNT(*) as total_rows,
	COUNT(payment_sequential) as non_null_payment_sequential,
    COUNT(*) - COUNT(payment_sequential) as null_count,
    MIN(payment_sequential) as min_payment_sequential,
    MAX(payment_sequential) as max_payment_sequential,
    AVG(payment_sequential) as mean_payment_sequential,
    STDDEV(payment_sequential) as std_dev_payment_sequential,
    STDDEV(payment_sequential)/AVG(payment_sequential) as CV
FROM order_payments
;
# Notes: 
	# CV is 0.64, max sequential is 29, and mean is 1.09.
    # No null prices. Total = 103886
    
SELECT *
FROM order_payments
WHERE order_id IN 
(
SELECT order_id
FROM order_payments
WHERE payment_sequential > 1
) AND payment_type != 'voucher' AND payment_type != 'credit_card'
;

SELECT *
FROM orders
WHERE order_id IN
(
	SELECT order_id
	FROM order_payments
	WHERE payment_type = 'not_defined'
)
;

SELECT payment_type, COUNT(payment_type)
FROM order_payments
WHERE order_id in
(
	SELECT order_id
	FROM orders
	WHERE order_status = 'canceled'
)
GROUP BY payment_type
;

# Notes:
	# Insights I wanted to derive from these values:
		# Distinct order IDs in order items: 98,666. Distinct order IDs in payments: 99,440 -- clearing this discrepancy is important.
        # [Solved] The 3 order IDs with undefined payment types -- cancelled orders. There is no cancellation timestamp. So can't tell why these didnt have payment types, whereas other cancelled orders had payment types.
        # Derive a pattern for the split payment orders - what is the usual cost of the order, and what are the different payment types used in the splitting?
        # Frequency of each payment type
        # Distribution of credit card installments - order cost (& delivery cost) vs. frequency of credit card usage vs. installments
        
        
# 3. review score, review_creation_date, review_answer_timestamp - order review tables:
SELECT *
FROM order_reviews
LIMIT 10
;

SELECT 
	COUNT(*) as total_rows,
	COUNT(review_score) as non_null_review_score,
    COUNT(*) - COUNT(review_score) as null_count,
    MIN(review_score) as min_review_score,
    MAX(review_score) as max_review_score,
    AVG(review_score) as mean_review_score,
    STDDEV(review_score) as std_dev_review_score,
    STDDEV(review_score)/AVG(review_score) as CV
FROM order_reviews
;
# Notes: 
	# Total records: 99224
	# CV is 0.32, mean is 4.08.
    # No null prices. Total = 99224

SELECT review_score, COUNT(review_score)
FROM order_reviews
GROUP BY review_score
ORDER BY review_score DESC
;

SELECT COUNT(DISTINCT order_id), COUNT(DISTINCT review_id)
FROM order_reviews
;
# Notes: 
	# Distinct Order IDs: 98673. Distinct Review IDs: 98410
    # Same Review ID for multiple Order IDs? -- yes there are multiple [query below]. Will need to look into them. 

WITH 
    review_id_count AS(
		SELECT review_id, COUNT(DISTINCT order_id) as order_id_count
		FROM order_reviews
		GROUP BY review_id
					),
    duplicate_review_id AS(
    SELECT review_id
    FROM review_id_count
    WHERE order_id_count > 1
				)
SELECT *
FROM duplicate_review_id
JOIN order_reviews
using (review_id)
;

DESCRIBE order_reviews ;
# Notes:
    # Creation date and Answer TimeStamp are varchar columns .. will need to change to date time type to be able to operate on them.
    
SELECT DATA_TYPE, COLUMN_TYPE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'order_reviews' 
;

SELECT *
FROM order_reviews
WHERE review_creation_date = NULL
;

SELECT 
	COUNT(*) as total_rows,
	COUNT(review_creation_date) as non_null,
    COUNT(*) - COUNT(review_creation_date) as null_count,
    COUNT(review_answer_timestamp) as non_null,
    COUNT(*) - COUNT(review_answer_timestamp) as null_count
FROM order_reviews
;
# Notes:
	# Insights I wanted to derive from these values:
		# Gap between review creation date, and review answer timestamp -- and does it change with the review score?
        # Is the review request sent the day after the delivery?
        # Does the comment length vary with the review score?
        # What % of reviews have comments?

