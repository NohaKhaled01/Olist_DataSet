# Tried to find a reason for why approval time delivers for same customers.
# Tried looking at customer cities - customer used payment method - purchase time [weekday versus weekend]
# Nothing Found

SELECT *
FROM orders
JOIN order_payments
;

SELECT *
FROM customers
;
# Distinct UNIQUE IDs = 96096
# Distinct/Total IDs = 99441
# Unique IDs < Total IDs .. duplications in unique id?
WITH customers_orders AS(
	SELECT *
	FROM (
		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY customer_unique_id) as row_num,
		COUNT(customer_unique_id) OVER(PARTITION BY customer_unique_id) as row_count
		FROM customers
		) as sub_table
	WHERE row_count > 1
    )
SELECT co.customer_id, co.customer_unique_id, co.customer_zip_code_prefix, co.customer_city, co.row_num,
	 CASE 
        WHEN WEEKDAY(o.order_purchase_timestamp) IN (5, 6) THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
	o.order_id, o.order_status,
    TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_approved_at) as days_to_approval,
    op.payment_type, op.payment_sequential
FROM customers_orders as co
JOIN orders as o
ON co.customer_id = o.customer_id
JOIN order_payments as op
ON o.order_id = op.order_id
ORDER BY co.customer_unique_id, co.customer_id, co.row_num
;

# '1afe8a9c67eec3516c09a8bdcc539090'
# '24b0e2bd287e47d54d193e7bbb51103f'
# '00172711b30d52eea8b313a7f2cced02'
SELECT *
FROM orders
WHERE customer_id = '24b0e2bd287e47d54d193e7bbb51103f' OR customer_id = '1afe8a9c67eec3516c09a8bdcc539090'
;

WITH customers_orders AS(
	SELECT *
	FROM (
		SELECT *,
		ROW_NUMBER() OVER(PARTITION BY customer_unique_id) as row_num,
		COUNT(customer_unique_id) OVER(PARTITION BY customer_unique_id) as row_count
		FROM customers
		) as sub_table
	WHERE row_count > 1
    )
SELECT co.customer_unique_id, co.row_num, co.customer_zip_code_prefix, co.customer_city, 
	o.order_status,
    TIMESTAMPDIFF(DAY, o.order_purchase_timestamp, o.order_approved_at) as days_to_approval,
    op.payment_type, op.payment_sequential
FROM customers_orders as co
JOIN orders as o
ON co.customer_id = o.customer_id
JOIN order_payments as op
ON o.order_id = op.order_id
ORDER BY co.customer_unique_id, co.row_num
;