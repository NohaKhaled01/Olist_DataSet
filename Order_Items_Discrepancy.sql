# Discrepancies to investigate:
	# Payments table has 99,440 distinct order ids vs 98,666 in the items table — a difference of 774 more orders in the payment
		# These orders have payment records but no items. Likely cancelled or unavailable orders
		# Output:
			# 603 unavailable. 164 cancelled. 2 invoiced. 5 created. 1 shipped.
				# 603 unavailable - never shipped. No carrier delivered date
                # 164 cancelled - 141 cancelled before approval, 23 cancelled after approval, before carrier date. No customer delivered date
				# 1 shipped - never arrived. No customer delivered date
				# 2 invoiced - never shipped. No carrier delivered date
				# 5 created - never approved. No approval date
	# 3 orders with undefined payment type — also have no matching records in the items table
		# Output: Cancelled orders - present in the orders table.
        # To do: Be wary of payment type when doing analysis on payments
	# Orders table has ONE MORE ORDER ID than payments table
		# Output: Order was delivered and had items .. probably an exporting issue
        # To do: Nothing .. just be aware of this.
    # Total reviews is higher than the 98,666 distinct orders in items table
		# 99224 review ids versus 98666 orders. 
        # Output: The same order could have multiple review ids - a new review request is issued with the delivery of each product in the order; thus, more review ids than actual orders
	
# Other issues Found along the way:
	# The order_item_id counter in the order_items table doesnot correspond to the number of items in an order - it was found through the reviews table that an order could have three products, but have the item id as 1.
    # Cont: It also doesnot consistently correspond to the number of different items in the order - it was found that orders with similar product ids had the item id going up - 1, 2, .. 
    # This means: There is no way to know the number of products per order - this is not stored in this dataset.
    # Cont: And calculating the freight for each order will not be very accurate, because there is no way of knowing if the delivery is charged per number of products, or number of sellers, or per order
    # This mainly affects the freight costs investigation. Other than that, it's fine.

SELECT COUNT(DISTINCT order_id)
FROM order_payments
;

SELECT COUNT(DISTINCT order_id)
FROM order_items
;

SELECT *
FROM order_payments
;

SELECT DISTINCT payment_type
FROM order_payments
;
---
# Not Defined Payments Orders

#Order IDs:
SELECT order_id
FROM order_payments
WHERE payment_type = 'not_defined'
;

SELECT *
FROM order_items
WHERE order_id IN (
	SELECT order_id
	FROM order_payments
	WHERE payment_type = 'not_defined'
    )
; #not there in order_items

SELECT *
FROM orders
WHERE order_id IN (
	SELECT order_id
	FROM order_payments
	WHERE payment_type = 'not_defined'
    )
; #present in orders table - cancelled orders.
---
# Difference between payments orders and items orders

SELECT DISTINCT op.order_id
FROM order_payments as op
LEFT JOIN order_items as ot
ON op.order_id = ot.order_id
WHERE ot.order_id IS NULL
; #775 orders?

SELECT COUNT(order_status), order_status
FROM orders
WHERE order_id IN (
	SELECT DISTINCT op.order_id
	FROM order_payments as op
	LEFT JOIN order_items as ot
	ON op.order_id = ot.order_id
	WHERE ot.order_id IS NULL
)
GROUP BY order_status
; # 603 unavailable. 164 cancelled. 2 invoiced. 5 created. 1 shipped.

SELECT *
FROM orders
WHERE order_id IN (
	SELECT DISTINCT op.order_id
	FROM order_payments as op
	LEFT JOIN order_items as ot
	ON op.order_id = ot.order_id
	WHERE ot.order_id IS NULL
)
AND (order_status = 'shipped' OR order_status = 'invoiced' OR order_status = 'created')
ORDER BY order_purchase_timestamp 
; # 1 shipped - never arrived. No customer delivered date
# 2 invoiced - never shipped. No carrier delivered date
# 5 created - never approved. No approval date

SELECT *
FROM orders
WHERE order_id IN (
	SELECT DISTINCT op.order_id
	FROM order_payments as op
	LEFT JOIN order_items as ot
	ON op.order_id = ot.order_id
	WHERE ot.order_id IS NULL
)
AND (order_status = 'unavailable' AND order_delivered_carrier_date IS NOT NULL)
ORDER BY order_purchase_timestamp 
; # 603 unavailable - never shipped. No carrier delivered date

SELECT *
FROM orders
WHERE order_id IN (
	SELECT DISTINCT op.order_id
	FROM order_payments as op
	LEFT JOIN order_items as ot
	ON op.order_id = ot.order_id
	WHERE ot.order_id IS NULL
)
AND (order_status = 'canceled')
ORDER BY order_purchase_timestamp 
; # 164 cancelled - 141 cancelled before approval, 23 cancelled after approval, before carrier date. No customer delivered date
---
## 99441 in orders versus 99440 in payments

SELECT *
FROM orders as o
LEFT JOIN order_payments as op
ON o.order_id = op.order_id
WHERE op.order_id IS NULL
; 

SELECT *
FROM order_items
WHERE order_id = 'bfbd0f9bdef84302105ad712db648a6c'
; # One missing order from order payments .. not sure why
--
# Difference between order reviews and orders items:
SELECT COUNT(DISTINCT order_id) as payments_count
FROM order_payments
; #99440

SELECT COUNT(DISTINCT order_id) as items_count
FROM order_items
; #98666

SELECT COUNT(DISTINCT order_id) as orders_count
FROM orders
; # 99441

SELECT COUNT(DISTINCT order_id) as reviews_count
FROM order_reviews
; # 98763

SELECT COUNT(DISTINCT review_id) as reviews_count
FROM order_reviews
; # 98410

SELECT *
FROM order_reviews
;

SELECT *
FROM order_reviews as orev
JOIN order_items as ot
ON orev.order_id = ot.order_id
;

SELECT order_id, count(order_id) as order_count
FROM order_reviews
GROUP BY order_id
HAVING count(order_id) > 1
;

SELECT *
FROM (
	SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_id) as row_num,
    COUNT(order_id) OVER (PARTITION BY order_id) as order_count
	FROM order_reviews
    ) as sub_table
WHERE order_count > 1
ORDER BY order_id, review_creation_date
;

SELECT *
FROM order_items
WHERE order_id = '03c939fd7fd3b38f8485a0f95798f1f6'
;

SELECT *
FROM (
SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) as row_num,
	COUNT(order_id) OVER (PARTITION BY order_id) as order_count_items
FROM order_items
WHERE order_id IN (
	SELECT order_id
	FROM (
		SELECT *, ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_id) as row_num,
		COUNT(order_id) OVER (PARTITION BY order_id) as order_count
		FROM order_reviews
		) as sub_table
	WHERE order_count > 1
	)
    ) as sub_table_2
WHERE order_count_items > 1
ORDER BY order_id
;

SELECT *
FROM (
SELECT *, 
	ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_id) as row_num,
	COUNT(order_id) OVER (PARTITION BY order_id) as order_count
FROM order_reviews
	) as sub_table
WHERE order_count > 1
ORDER BY order_id
;

SELECT *
FROM (
	SELECT *, 
			ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY order_id) as row_num, 
            COUNT(order_id) OVER (PARTITION BY order_id) as order_count_items
	FROM order_items
	WHERE order_id IN 
		(
		SELECT order_id
		FROM (
			SELECT *, 
					ROW_NUMBER() OVER (PARTITION BY order_id ORDER BY review_id) as row_num, 
                    COUNT(order_id) OVER (PARTITION BY order_id) as order_count
			FROM order_reviews
			) as sub_table
		WHERE order_count > 1
		)
    ) as sub_table_2
WHERE order_count_items > 1
ORDER BY order_id
;

SELECT COUNT(DISTINCT order_id)
FROM order_reviews
;

SELECT COUNT(*)
FROM order_reviews
;
