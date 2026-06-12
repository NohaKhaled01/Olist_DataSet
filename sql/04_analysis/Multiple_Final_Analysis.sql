# Reviews Analysis
# Questions:
# Response time vs. review score
# Word count vs. review score
# Both need no work .. can be visualized in BI directly

SELECT *,
	TIMESTAMPDIFF(DAY, review_creation_date, review_answer_timestamp) as days_to_review
FROM order_reviews
;

SELECT review_score, avg(length(review_comment_message))
FROM order_reviews
GROUP BY review_score
HAVING avg(length(review_comment_message)) > 0
;
---
# Sellers Analysis
# Questions:
# Geographical Distribution of Sellers - straight forward to BI
# Number of Orders per Seller - probably straight forward to BI as well .. same map as geographical distribution

SELECT COUNT(*)
FROM sellers
;

SELECT seller_id, COUNT(order_id)
FROM order_items
GROUP BY seller_id
ORDER BY COUNT(order_id) DESC
;
---
# Customers Analysis
# Questions:
# Customer Retention Rate - how often to customers re-order?
# Bonus question: Geographical Distribution of Customers - straight forward to BI

SELECT *
FROM customers
;
# Distinct UNIQUE IDs = 96096
# Distinct/Total IDs = 99441

SELECT id_repetitions, COUNT(id_repetitions) as number_of_customers
FROM (
	SELECT o.order_id, c.customer_unique_id,
		ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id) as row_num,
		COUNT(customer_unique_id) OVER(PARTITION BY customer_unique_id) as id_repetitions
	FROM orders as o
	JOIN customers as c
	ON o.customer_id = c.customer_id
	) as sub_table
GROUP BY id_repetitions
ORDER BY id_repetitions
;

#Create view from the inner query, to import to BI and connect to orders table:
CREATE VIEW customer_renetion AS
SELECT o.order_id, c.customer_unique_id,
		ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id) as row_num,
		COUNT(customer_unique_id) OVER(PARTITION BY customer_unique_id) as id_repetitions
	FROM orders as o
	JOIN customers as c
	ON o.customer_id = c.customer_id
;

SELECT COUNT(*), COUNT(DISTINCT customer_unique_id)
FROM customer_renetion
;