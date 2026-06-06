# Olist E-Commerce Analysis

An end-to-end data analytics project built on the [Olist Brazilian E-Commerce public dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — covering database design, exploratory data analysis, and business insight generation.

> **Status:** In progress — analysis ongoing. PowerBI report in development.

---

## Project Overview

Olist is a Brazilian e-commerce marketplace that connects small retailers to major sales channels. This project analyzes their transactional data across 9 relational tables — covering orders, customers, sellers, products, payments, reviews, and geolocation — to uncover patterns in customer behavior, seller performance, delivery efficiency, and product demand.

The goal is to answer real business questions from raw data, while documenting the full analytical process from schema design to visual reporting.

---

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

## Key Findings (so far)

**Payments**
- All split payments (payment_sequential > 2) are credit card + voucher combinations — intentional discount usage, not financial difficulty
- Approval time varies significantly by payment type — boleto payments take longer than credit card
- A small number of orders used up to 29 sequential payments

**Orders & Delivery**
- 775 orders exist in the payments table with no corresponding items — fully traced to canceled, unavailable, invoiced, created, and shipped-but-undelivered statuses
- One delivered order has no payment record — identified as a data extraction anomaly
- Olist appears to pad delivery estimates deliberately — actual delivery consistently beats the estimate

**Products & Categories**
- 610 products have no category, name length, description length, or photo count
- The same product_id can be sold by multiple sellers at different prices — price variation is largely seller-driven, not seasonal
- A weak Q1 price dip pattern was observed across continuously purchased products — consistent across sellers, suggesting a market-level trend rather than individual seller behavior

**Customers**
- ~96.8% of customers ordered only once — retention rate is approximately 3%
- 3,345 customers placed more than one order

**Reviews**
- Multiple reviews per order are triggered by separate delivery events, not customer initiative — each shipped item triggers its own review request email
- Review scores sometimes change between submissions for the same order, reflecting evolving customer sentiment

---

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

**In progress**
- Review response time vs review score
- Does unhappiness drive longer written reviews?
- Late delivery patterns by region
- Seller geographical distribution and order concentration
- Delivery time vs seller/customer location distance

---

## Tools

- **MySQL** — schema design, data loading, SQL analysis
- **PowerBI** — visualization and reporting (in progress)

---

## Author

Noha Khaled
[GitHub Profile](https://github.com/NohaKhaled01)
