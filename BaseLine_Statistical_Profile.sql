# A Baseline Statistical Profile -- to make sure my questions and targetted insights are actually achievable 
# Columns to look at values distribution in:
# price, frieght value, order item id, payment value, payment installments, review score, submission - approval times, delivery estimate - actual delivery, product weight, product dimensions (volume).
-----
# Some definitions for myself:
# Mean -- Average | Median -- Middle Value | Mode -- Most frequent value
# CV -- Coefficient of Variation [STDDEV/Mean] .. the lower, the most clustered the values around the mean .. the higher, the more spread around the values are

SELECT *
FROM order_items
;

# 1. Price, freight value, order item id - order items table:
SELECT 
	COUNT(*) as total_rows,
	COUNT(price) as non_null_prices,
    COUNT(*) - COUNT(price) as null_count,
    MIN(price) as min_price,
    MAX(price) as max_price,
    AVG(price) as mean_price,
    STDDEV(price) as std_dev_price,
    STDDEV(price)/AVG(price) as CV
FROM order_items
;
# Notes: 
	# CV is 1.5, which is on the higher side -- prices are scattered.
    # No null prices. Total = 112650

SELECT price, COUNT(*) as price_counts
FROM order_items
GROUP BY price
ORDER BY price_counts DESC
LIMIT 1
;
# Note: Most repeated price value -- 59.90, at 2481 times [manually calculated: 2.2%]

SELECT COUNT(*),
CASE
	WHEN price < 50 THEN 'price below 50'
    WHEN price < 100 THEN 'price between 50 and 10'
    WHEN price < 500 THEN 'price between 100 and 500'
    WHEN price < 1000 THEN 'price between 500 and 1000'
    WHEN price >= 1000 THEN 'price equal or above 1000'
END as price_range
FROM order_items
GROUP BY price_range
ORDER BY MIN(price)
;
# Highest product counts in orders is for prices below 50 .. the higher the price, the less frequent an item is ordered.
# There is a drop from the range 100 - 500 and 500 - 1000

SELECT COUNT(*),
CASE
	WHEN price < 50 THEN 'price below 50'
    WHEN price < 100 THEN 'price between 50 and 10'
    WHEN price < 150 THEN 'price between 100 and 150'
    WHEN price < 200 THEN 'price between 150 and 200'
    WHEN price < 250 THEN 'price between 200 and 250'
    WHEN price < 300 THEN 'price between 250 and 300'
    WHEN price < 350 THEN 'price between 300 and 350'
    WHEN price < 400 THEN 'price between 350 and 400'
    WHEN price < 450 THEN 'price between 400 and 450'
    WHEN price < 500 THEN 'price between 450 and 500'
    WHEN price < 1000 THEN 'price between 500 and 1000'
    WHEN price >= 1000 THEN 'price equal or above 1000'
END as price_range
FROM order_items
GROUP BY price_range
ORDER BY MIN(price)
;
# Highest product counts in orders is for prices below 50 .. the higher the price, the less frequent an item is ordered.
# The first sharp drop happens first between 100 - 150 and 150 - 200, then the second drop between 150 - 200 and 200 - 250

# Product Price related points I wanted to check:
	# Which orders have the highest overall price? The ones with multiple cheap items, or ones with few expensive item/items?
		# To get this, I have to group the orders into brackets based on the number of items in the order, and calculate the number of orders in each order in each bracket, and the avg order price [Might need to work with the Orders Table along this]
    # [Additional] Can the same product have a changed price in different orders? If yes, could indicate there is a factor there [time - inflation - promotions].
    
    # Do expensive orders [high price] get split payment more often? [Orders Table]
    # For credit card payments, how often do orders get split on installments? At what total price does a shift happen, if any? [Orders Table]
    # Payment type versus total price of order -- any relationship? [Orders Table]
    
# Freight - order items table:
SELECT 
	COUNT(*) as total_rows,
	COUNT(freight_value) as non_null_freights,
    COUNT(*) - COUNT(freight_value) as null_count,
    MIN(freight_value) as min_freight,
    MAX(freight_value) as max_freight,
    AVG(freight_value) as mean_freight,
    STDDEV(freight_value) as std_dev_freight,
    STDDEV(freight_value)/AVG(freight_value) as CV
FROM order_items
;
# Notes: 
	# CV is 0.79, lower than the prices CV [1.5].
    # No null deliveries. Total = 112650
    # There is a min_freight of 0. Is this promotion/low distance/high order price/high order count/some other reason?
    
SELECT COUNT(freight_value) as min_freight
FROM order_items
WHERE freight_value = 0.00
;
# Number of products delivered with zero delivery fees = 383

SELECT COUNT(DISTINCT order_id)
FROM order_items
WHERE freight_value = 0.00
;
# Number of orders delivered with zero delivery fees = 339

# The numbers below are misleading because the freight value count is inaccurate - the order ids need to be grouped first. Let me try
SELECT COUNT(*)
FROM
(
	SELECT DISTINCT order_id, price, freight_value
	FROM order_items
) as dist_table
;
# Note: Actual number of orders in order items table: 101570

SELECT COUNT(*),
CASE
    WHEN freight_value < 100 THEN 'delivery cost is 100 or less'
    WHEN freight_value < 200 THEN 'delivery cost between 100 and 200'
    WHEN freight_value < 300 THEN 'delivery cost between 200 and 300'
    WHEN freight_value < 400 THEN 'delivery cost between 300 and 400'
    WHEN freight_value >= 400 THEN 'delivery cost equal or above 400'
END as freight_range
FROM
(
	SELECT DISTINCT order_id, price, freight_value
	FROM order_items
) as dist_table
GROUP BY freight_range
ORDER BY MIN(freight_value)
;
# Note: Great majority of delivery costs are below 100

SELECT COUNT(*),
CASE
    WHEN freight_value < 20 THEN 'delivery cost is 20 or less'
    WHEN freight_value < 40 THEN 'delivery cost between 20 and 40'
    WHEN freight_value < 60 THEN 'delivery cost between 40 and 60'
    WHEN freight_value < 80 THEN 'delivery cost between 60 and 80'
    WHEN freight_value <= 100 THEN 'delivery cost between 80 and 101'
    WHEN freight_value > 100 THEN 'above 100'
END as freight_range
FROM
(
	SELECT DISTINCT order_id, price, freight_value
	FROM order_items
) as dist_table
GROUP BY freight_range
ORDER BY MIN(freight_value)
;
# Note: Great majority of delivery costs are below 20

# Freight Price related points I wanted to check:
	# Is the freight value per product in the order, or per product and seller, or per seller? -- this will clear alot of things.
    # How much does the freight cost contribute to the total order cost?
    # Do higher freight prices lead to lower review scores?
    # Product weight and volume vs freight value — heavier/bigger = more expensive to ship?

SELECT COUNT(DISTINCT order_id)
FROM order_items
;