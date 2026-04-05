SHOW TABLES ;

SET GLOBAL local_infile = 1;

SHOW GLOBAL VARIABLES
WHERE Variable_name LIKE '%local%';

-- Customers Table
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_customers_dataset.csv' 
INTO TABLE customers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- GeoLocation Table -- Removed PKs. Currently, showing warnings for lat and lng columns
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_geolocation_dataset.csv' 
INTO TABLE geolocation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Order Items Table
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_order_items_dataset.csv' 
INTO TABLE order_items
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Order Payments Table
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_order_payments_dataset.csv' 
INTO TABLE order_payments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Order Reviews Table -- Fixed, imported date and time as varchar
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- Orders Table -- Fixed, imported date and time as varchar
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_orders_dataset.csv' 
INTO TABLE orders
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Products Table -- Null values = 0
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_products_dataset.csv' 
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Sellers Table
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/olist_sellers_dataset.csv' 
INTO TABLE sellers
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- Translation Table
LOAD DATA LOCAL INFILE 'C:/Users/Mostafa/Desktop/Data Analysis/VS Code Folders/Google Certificate Cap Stone/archive/product_category_name_translation.csv' 
INTO TABLE translation
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;