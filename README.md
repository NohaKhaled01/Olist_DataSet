# Olist E-Commerce Analysis

An end-to-end data analytics project built on the [Olist Brazilian E-Commerce public dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — covering database design, exploratory data analysis, and business insight generation.

> **Status:** Completed

---

## Project Overview
Olist is a Brazilian e-commerce marketplace that connects small retailers to major sales channels. This project analyzes their transactional data across 9 relational tables — covering orders, customers, sellers, products, payments, reviews, and geolocation — to uncover patterns in customer behavior, seller performance, delivery efficiency, and product demand.

The goal is to answer real business questions from raw data, while documenting the full analytical process from schema design to visual reporting.

---

## Key Findings
- Platform has a 3% customer repeat rate, despite more than 50% of orders having 5-stars review scores; satisfactory levels and repeat rates are not driving each other.
- Dissatisfied customers write twice as much as satisfied customers
- Late deliveries, despite taking up only 7% of the platform's deliveries, are a main drive for low review scores
- Payments, when split, are split mainly for the usage of discount vouchers, not due to financial difficulties
![alt text](01-overview.png)

## Dataset

- **Source:** [Kaggle — Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
- **Period:** 2016 to 2018
- **Scale:** ~100,000 orders across 9 tables
- **Tables:** orders, customers, sellers, products, order items, order payments, order reviews, geolocation, product category translation

---

## Project Structure

```
olist-ecommerce-analysis/
│
├── sql                     ← Folder contains SQL files
    ├── 01_schema                               ← Folder contains creating schema files
    ├── 02_cleaning                             ← Folder contains cleaning data and solving discrepancies files
    ├── 03_statisticalprofiles                  ← Folder contains exploratory profile files 
    ├── 04_analysis                             ← Folder contains analysis files
├── notes                   ← Folder contains note files creating during the the exploratory analysis
    ├── Discrepancies to investigate.txt        ← Grouped discrepancies found
    ├── eda_notes.md                            ← Exploratory notes
├── notes-html              ← Folder contains the notes, in an organized notepad, open-able in browser
    ├── olist_eda_notes_editable.html           ← eda_notes.md, organized, open-able in browser
    ├── olist_statistical_notes_editable.html   ← notes from statistical analysis, organized, open-able in browser
├── images                  ← Folder contains slide images from PowerBI report
└── README.md
```

---

## How to Reproduce DataSet

1. Download the CSV files from the Kaggle link above
2. Run `Creating_Tables_WO_FK.sql` to create the tables
3. Open `ImportingData_Into_Tables.sql`, update file paths, and run to import data into their respective tables

---

## Skills Demonstrated

**Database Design**
- Relational schema design across 9 tables
- Data type selection (CHAR vs VARCHAR, DECIMAL vs FLOAT, TINYINT vs INT)
- Primary key design including composite keys
- Foreign key direction and dependency ordering

**SQL**
- Multi-table joins across 4+ tables
- CTEs (Common Table Expressions)
- Window functions (ROW_NUMBER, COUNT OVER, LAG)
- Subqueries and derived tables
- Aggregate functions and distribution analysis
- CASE WHEN for bucketing and conditional logic
- Date functions (TIMESTAMPDIFF, DATEDIFF, DATE_FORMAT, WEEKDAY)
- GROUP_CONCAT for payment combination analysis
- Views for reusable query logic

**Exploratory Data Analysis**
- Structural profiling of each table before analysis
- Data quality investigation — nulls, orphaned records, inconsistencies
- Cross-table discrepancy resolution (tracked 775 orders across payment, items, and orders tables)
- Identification of dataset limitations (quantity recording inconsistency, review-level vs item-level mismatch)
- Hypothesis formation and data-driven verification

---

## Key Findings

**Customers**
- ~96.8% of customers ordered only once — repeat rate is approximately 3%
- 3,345 customers placed more than one order
- The low repeat rate reflects a one-time purchase through Olist, not a one-time product purchase, made evident by the overwhelmingly high review scores coupled with the low repeat rates. Customers could be re-buying products directly through sellers, or through other mediums
![Customers][images/02-customers.png]

**Reviews**
- Multiple reviews per order are triggered by separate delivery events, not customer initiative — each shipped item triggers its own review request email
- Review scores sometimes change between submissions for the same order, reflecting evolving customer sentiment
- More than 50% of the orders have a 5-star review, pointing to low repeat rates that are not driven by the satisfactory levels
![Reviews][images/03-reviews.png]

**Payments**
- All split payments (payment_sequential > 2) are credit card + voucher combinations — intentional discount usage, not financial difficulty
- Approval time varies significantly by payment type — boleto payments take longer than credit card
- A small number of orders used up to 29 sequential payments
- Vast majority of credit card users opt for 1 to 3 installments for their payments, with less orders for higher installments
![Payments][images/05-payments.png]
![Payments][images/06-payments.png]

**Orders & Delivery**
- 775 orders exist in the payments table with no corresponding items — fully traced to canceled, unavailable, invoiced, created, and shipped-but-undelivered statuses
- One delivered order has no payment record — identified as a data extraction anomaly
- Olist appears to pad delivery estimates deliberately — actual delivery consistently beats the estimate
- Delivery status strongly drives satisfaction levels, with late deliveries scoring low overall review scores versus early and on time deliveries
![Delivery][images/08-delivery&reviews.png]

**Products & Categories**
- 610 products have no category, name length, description length, or photo count
- The same product_id can be sold by multiple sellers at different prices — price variation is largely seller-driven, not seasonal
- A weak Q1 price dip pattern was observed across continuously purchased products — consistent across sellers, suggesting a market-level trend rather than individual seller behavior
- All product cateogries have very close overall review scores, pointing to a null relationship between categories and satisfaction levels

---

## Data Limitations
- The numbers computed in this project are for a beginner growing platform:
Olist was founded in 2015. The dataset spans from Sept 2016 to Oct 2018, a period during which the platform was still growing. Later analyses for later time periods could reveal different findings
- The current dataset does not keep an accurate record of the number of items per order, and doesnt provide a way to calculate delivery costs:
Several order items records were compared to the reviews comments for the same orders, and it was found that multiple orders recorded as having one item actually had multiple items based on the review comment.
Furthermore, a freight cost is added for each item in the records, and if the number of items is not presented accurately, it follows that the total freight cost per order can't be calculated based on the data given alone.
- Whether the platform pads its estimated delivery times or not is not determinable:
Early and on time deliveries are computed based on the platform's estimated delivery times, and the platform could be giving itself a large margin of error to get the early delivery badge, while keeping actual delivery times too long.

## Analysis Questions

**Answered**
- Frequency of each payment type
- Credit card installment distribution vs order value
- Payment combinations for split orders
- Does approval time change with payment method?
- Which product categories have the highest demand?
- Which categories have the highest and lowest review scores?
- Customer retention rate and repeat purchase frequency
- Seasonal price patterns for high-frequency products
- Delivery time vs review score
- Does unhappiness drive longer written reviews?

---

## Tools

- **MySQL** — schema design, data loading, SQL analysis
- **PowerBI** — visualization and reporting

---

## Author

Noha Khaled
[GitHub Profile](https://github.com/NohaKhaled01)

[Linked Profile](https://www.linkedin.com/in/nuha-khaled-mahmoud/)

[Upwork Profile](https://www.upwork.com/freelancers/~011a02d544a2fd59bb?mp_source=share)
