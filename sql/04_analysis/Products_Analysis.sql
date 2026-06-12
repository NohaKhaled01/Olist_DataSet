# Product Related Questions:
# Which Categories are the most represented?
# Which Categories have the highest demand?
# Categories with highest and lowest review scores

SELECT t.product_category_name_english, count(oi.product_id) as products_bought_in_category,
	count(DISTINCT p.product_id) as total_number_of_products_in_category,
	CASE 
		WHEN count(DISTINCT oi.product_id) = count(DISTINCT p.product_id) THEN 'All products bought atleast once'
        ELSE 'One or more products were never bought'
	END AS all_products_bought
FROM order_items as oi
JOIN products as p
ON oi.product_id = p.product_id
JOIN translation as t
ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name
ORDER BY products_bought_in_category DESC, total_number_of_products_in_category DESC
;

SELECT t.product_category_name_english, AVG(orev.review_score) as avg_review_score, COUNT(orev.review_score) as number_of_review_scores
FROM order_reviews as orev
JOIN order_items as oi
ON orev.order_id = oi.order_id
JOIN products as p
ON oi.product_id = p.product_id
JOIN translation as t
ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name
ORDER BY number_of_review_scores DESC, avg_review_score DESC
;