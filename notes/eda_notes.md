# Olist E-Commerce Dataset — EDA Notes

---

## Table: olist_customers_dataset

**Columns:** customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state

### What this table is
Contains data about customers registered on the Olist e-commerce platform.

- `customer_id` — generated per order. A new one is created every time the same user places an order.
- `customer_unique_id` — the actual user's ID. Stays the same across all orders.
- Three orders by the same user = three different customer_ids, but the same customer_unique_id.

### Numbers
| Total records | 99,441 |
| Distinct users (unique customer ids) | 96,096 |

### Observations
- Most customers are in **SP - São Paulo**. Least are in **RR - Roraima**.
- Highest customer counts by city: **São Paulo** and **Rio de Janeiro**.
- No nulls, no short zip codes, no short city names or IDs — clean import.

### Open questions
- Cities with lower customer counts — do they have a higher number of orders per customer vs the bigger cities?
- City names likely have misspellings that SQL can't catch (e.g. "sao paulo" vs "são paulo" counted as different cities). Will need Python + fuzzy matching later. Whether it's worth doing depends on what we need from the city column.

---

## Table: olist_geolocation_dataset

**Columns:** geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state

### What this table is
Contains zip codes with their lat/lng coordinates, city, and state. Each zip code can have multiple lat/lng pairs within the same city and state.

### Numbers
| Total records | 1,000,163 |

### Observations
- No PK could be defined on import — no single column or combination was unique enough to work. Imported without one.
- No obvious direct use yet — will become useful when enriching customer/seller data with location for distance or map-based analysis.

### Open questions
- Is the lat/lng variation per zip code due to multiple data sources being merged?
- Will be useful for: travel distance per order → connect to freight value, delivery time, and review scores.

---

## Table: olist_order_items_dataset

**Columns:** order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value

### What this table is
Contains the line items for each order. Each row is one item in one order.

- `order_item_id` — a sequential counter for items within an order (1st item, 2nd item, etc.). Not a product identifier.
- The same order_id repeats for each item in that order, with order_item_id incrementing.
- One order can contain items from multiple different sellers.

### Numbers
| Total records | 112,650 |
| Distinct orders | 98,666 |
| Max items in one order | 21 |

### Observations
- **Freight value issue:** if the same product from the same seller appears multiple times in one order, the freight_value is repeated per item — not split or consolidated. This misrepresents the actual shipping cost. To get accurate shipping costs, need to group by order_id + product_id + seller_id before summing freight.
- **shipping_limit_date** — unclear if this is the deadline for the seller to hand the order to the carrier, or the actual shipping date. Needs to be compared against the date columns in the orders table to confirm.

### Possible insights
- Average number of items per order.
- Which orders have the highest total price — high quantity of cheap items, or low quantity of expensive ones?
- Compare shipping_limit_date to order dates to understand seller compliance and delivery timelines.

---

## Table: olist_order_payments_dataset

**Columns:** order_id, payment_sequential, payment_type, payment_installments, payment_value

### What this table is
Contains payment data for each order. An order can be paid in one go or split across multiple payment methods.

- `payment_sequential` — counts the number of payment records per order (1 = single payment, 2+ = split payment).
- `payment_installments` — only meaningful for credit card. All other payment types have 1 installment.

### Numbers
| Total records | 103,886 |
| Distinct order ids | 99,440 |

### Observations
- **Discrepancy:** payments table has 99,440 distinct order ids vs 98,666 in the items table — a difference of 774 orders. These orders have payment records but no items. Needs investigation — likely cancelled or unavailable orders.
- **3 orders with undefined payment type** — also have no matching records in the items table. Will need to be removed from all tables.

### Open questions
- Are split payments (payment_sequential > 1) a sign of financial difficulty, or just customers intentionally combining a voucher with a credit card? Need to look at payment type combinations to find out — what was used with what.
- Do high-value orders get split more often?

### Possible insights
- Frequency of each payment type.
- Distribution of credit card installments — how many people pay in how many installments?
- How often are orders paid with multiple methods, and what combinations appear?

---

## Table: olist_order_reviews_dataset

**Columns:** review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp

### What this table is
Contains reviews submitted for orders. Reviews are at the order level — not per item.

- `review_score` — 1 to 5.
- `review_comment_title` and `review_comment_message` — optional fields.
- `review_creation_date` — likely when Olist sent the review request to the customer. All timestamps are at midnight, which suggests a scheduled batch job.
- `review_answer_timestamp` — when the customer actually submitted the review.

### Numbers
| Total records | 99,224 |

Note: higher than the 98,666 distinct orders in the items table — needs comparison with the orders table to understand why.

### Observations
- The gap between creation_date and answer_timestamp = how long after being asked did the customer bother to respond. More interesting than just "time to submit."
- Is the review request sent the day after delivery? Needs to be checked against order_delivered_customer_date in the orders table.
- Comments are in Portuguese — full text analysis would need NLP tools. But can still extract value without reading them.

### Open questions
- Do angry customers (score 1-2) respond faster than happy ones (score 5)?
- Do lower scores correlate with longer comment length? Theory: angry customers write more lol.
- What % of reviews per score actually include a comment?

### Possible insights
- Response time vs review score.
- Comment rate by score — does unhappiness drive more written feedback?
- Word count of messages vs review score.

---

## Table: olist_orders_dataset

**Columns:** order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date

### What this table is
The central table. Contains one row per order with its status and all the key timestamps.

- `order_purchase_timestamp` — when the customer placed the order.
- `order_approved_at` — likely automated payment approval by the platform, not the seller.
- `order_delivered_carrier_date` — when the carrier picked up the order from the seller. Compare against shipping_limit_date in the items table.
- `order_delivered_customer_date` — actual delivery date.
- `order_estimated_delivery_date` — what the customer was told at time of purchase.

### Numbers
| Total records | 99,441 |
| Distinct order ids | 99,441 |

Note: same as the customer record count — makes sense since each customer_id is generated per order.

### Order statuses
| Status | Count (TBD) |
|---|---|
| delivered | |
| shipped | |
| canceled | |
| unavailable | |
| invoiced | |
| processing | |
| approved | |
| created | |

Need to get count and % of total for each. Special focus on canceled and unavailable — and cross-reference their order ids against the mysterious ones found in the payments and reviews tables.

### Observations
- **Approval time gap** — the time between purchase and approval is essentially payment processing time. Boleto payments likely take longer than credit cards. Worth checking if payment type explains the variation.
- **Delivery margin** — the gap between estimated and actual delivery date tells us whether Olist deliberately under-promises (the margin they give themselves), and how often is it useful/surpassed/fails?
- For large approval time gaps, worth looking at the order details - number of items in order, and payment type.

### Open questions
- Does payment type affect approval time?
- How often does actual delivery beat, match, or miss the estimate?
- What do the reviews look like for late deliveries? (just curious lol)
- Do canceled/unavailable orders explain the discrepancies found in the payments and items tables?

### Possible insights
- Approval time distribution — and what drives outliers.
- On-time delivery rate — estimated vs actual.
- Olist's buffer strategy — are they padding estimates intentionally?
- Order status funnel — where do orders drop off?

---

## Table: olist_products_dataset

**Columns:** product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm

### What this table is
Contains data for all products listed on the platform. No seller_id here — the connection to sellers is only through the order_items table.

### Numbers
| Total records (and distinct product ids) | 32,951 |
| Product categories | 74 |
| Products with empty category name | 610 |

### Observations
- Categories are likely pre-set by Olist — low risk of misspelled duplicate categories.
- **610 products** have empty category names, and also missing name length, description length, and photos qty. Are these real products? Need to check if anyone actually bought them via the order_items table.

### Possible insights
- Product weight and volume vs freight value — does heavier/bigger = more expensive to ship?
- Product weight and volume vs delivery time.
- Number of products per category — which categories are most represented on the platform?
- Categories vs orders — which categories have the highest demand?
- Bonus: are products in certain categories bought in bulk or one at a time?
- Which categories have the lowest review scores? Could point to product quality issues, seller issues, or delivery problems.
- Which categories have the highest and lowest prices?

---

## Table: olist_sellers_dataset

**Columns:** seller_id, seller_zip_code_prefix, seller_city, seller_state

### What this table is
Contains data for all sellers on the platform.

### Numbers
| Total records (and distinct seller ids) | 3,095 |

### Observations
- More sellers in an area = more products, more competition, potentially lower prices, and more buyers. Geographical distribution matters.

### Possible insights
- Seller geographical distribution — which states and cities have the most sellers?
- Number of orders per seller — are a small number of sellers driving most of the volume?
- Seller location vs customer location — which state-to-state routes have the longest delivery times? Could tell Olist where to recruit more sellers.
- Reviews for sellers with more products — does product count relate to review score or delivery speed?

---

## Table: product_category_name_translation

**Columns:** product_category_name, product_category_name_english

### What this table is
A lookup table translating Portuguese category names to English.

### Numbers
| Total records | 71 |

### Observations
- **Discrepancy:** 74 categories in the products table but only 71 translations. Need to find the 3 missing ones — could be untranslated categories, or a spelling mismatch between the two tables (same fuzzy matching problem as cities).

---

## Cross-table things to investigate

- **The ghost orders** — orders that appear in payments or reviews but not in items. Hypothesis: these are canceled or unavailable orders. Cross-reference order_status to confirm.
- **The 3 undefined payment type orders** — remove from all tables.
- **Travelling distances** — use geolocation + seller/customer zip codes to estimate distance per order. Connect to freight value, delivery time, and review scores. Could be the most interesting cross-table analysis in the whole project.
