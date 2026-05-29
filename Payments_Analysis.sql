# Question: Payment Combinations versus number of orders:
WITH all_orders_grouped AS(
	SELECT order_id, SUM(payment_value) as total_order_value, group_concat(payment_type) as payment_combination_full,
		group_concat(DISTINCT payment_type) as payment_combination_unique,
		max(payment_sequential) as no_of_payment_sequentials, 
		group_concat(payment_installments) as payment_installments
	FROM order_payments
	GROUP BY order_id
)
SELECT payment_combination_unique, count(payment_combination_unique)
FROM all_orders_grouped
GROUP BY payment_combination_unique
;

# Question: Distribution of credit card installments vs. order cost [to create a dash board on BI]
SELECT order_id, SUM(payment_value) as total_order_value, group_concat(payment_type) as payment_combination_full,
	max(payment_sequential) as no_of_payment_sequentials, 
	group_concat(payment_installments) as payment_installments
FROM order_payments
GROUP BY order_id
HAVING payment_combination_full = 'credit_card' AND no_of_payment_sequentials = 1
;

# Question: Derive a pattern for split payment orders - payment combinations types
	# Use the views to create a statistical chart in BI
    # Use the queries to get the flat numbers and the fact that more than 2 sequentials is always credit card and voucher, no other combination
CREATE VIEW two_or_less AS
SELECT *,
			COUNT(*) OVER() as total_records 
	FROM (
		SELECT *, 
			ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) as payment_sequential_row,
			COUNT(order_id) OVER (PARTITION BY order_id) as order_count
		FROM order_payments
		) as sub_table
	WHERE order_count <= 2
;

CREATE VIEW more_than_two AS
SELECT *,
			COUNT(*) OVER() as total_records 
	FROM (
		SELECT *, 
			ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) as payment_sequential_row,
			COUNT(order_id) OVER (PARTITION BY order_id) as order_count
		FROM order_payments
		) as sub_table
	WHERE order_count > 2
;

SELECT payment_combination, count(payment_combination)
FROM (
	SELECT group_concat(DISTINCT payment_type) as payment_combination
	FROM two_or_less
	GROUP BY order_id
	) as sub_table
GROUP BY payment_combination
;

SELECT payment_combination, count(payment_combination)
FROM (
	SELECT group_concat(DISTINCT payment_type) as payment_combination
	FROM more_than_two
	GROUP BY order_id
	) as sub_table
GROUP BY payment_combination
;
 
# Question: Does approval time change with payment type - plot in BI
SELECT op.order_id, payment_type, order_purchase_timestamp, order_approved_at,
	TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_approved_at) as days_to_approval,
    TIMESTAMPDIFF(HOUR, order_purchase_timestamp, order_approved_at) as hours_to_approval,
    TIMESTAMPDIFF(MINUTE, order_purchase_timestamp, order_approved_at) as minutes_to_approval,
    order_delivered_carrier_date, order_delivered_customer_date
FROM order_payments as op
JOIN orders
ON op.order_id = orders.order_id