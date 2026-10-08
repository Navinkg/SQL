/* ==========================================================
   AMAZON SALES SQL PROJECT
   Script: 02_load_data.sql
   Purpose: Documents how the raw CSV (data/amazon_sales_dataset.csv)
            is loaded into the normalized schema created in
            01_create_tables.sql.

   NOTE: database/amazon_sales.db is already built and populated
         for you (50,000 rows loaded), so you do NOT need to run
         this script to start practicing. It is provided so you
         can see -- and re-run if you like -- the exact loading
         logic, e.g. if you want to rebuild the DB from scratch
         in a tool like DB Browser for SQLite.
   ========================================================== */

-- Step 1: Load the raw CSV into a flat staging table.
-- (In SQLite CLI: .mode csv  ->  .import data/amazon_sales_dataset.csv stg_amazon_sales)
DROP TABLE IF EXISTS stg_amazon_sales;
CREATE TABLE stg_amazon_sales (
    order_id            INTEGER,
    order_date            TEXT,
    product_id             INTEGER,
    product_category       TEXT,
    price                   REAL,
    discount_percent       INTEGER,
    quantity_sold           INTEGER,
    customer_region         TEXT,
    payment_method           TEXT,
    rating                   REAL,
    review_count             INTEGER,
    discounted_price         REAL,
    total_revenue             REAL
);

-- After the .import above, populate the dimension tables
-- with the distinct values found in the staging table:

INSERT INTO dim_category (category_name)
SELECT DISTINCT product_category FROM stg_amazon_sales
ORDER BY product_category;

INSERT INTO dim_region (region_name)
SELECT DISTINCT customer_region FROM stg_amazon_sales
ORDER BY customer_region;

INSERT INTO dim_payment (payment_method)
SELECT DISTINCT payment_method FROM stg_amazon_sales
ORDER BY payment_method;

-- Step 2: Populate the fact table, replacing text attributes
-- with foreign keys via JOINs back to the staging table.
INSERT INTO fact_orders (
    order_id, order_date, product_id, category_id, price, discount_percent,
    quantity_sold, region_id, payment_id, rating, review_count,
    discounted_price, total_revenue
)
SELECT
    s.order_id,
    s.order_date,
    s.product_id,
    c.category_id,
    s.price,
    s.discount_percent,
    s.quantity_sold,
    r.region_id,
    p.payment_id,
    s.rating,
    s.review_count,
    s.discounted_price,
    s.total_revenue
FROM stg_amazon_sales s
JOIN dim_category c ON c.category_name  = s.product_category
JOIN dim_region   r ON r.region_name    = s.customer_region
JOIN dim_payment  p ON p.payment_method = s.payment_method;

-- Step 3: Drop the staging table once the fact table is populated.
DROP TABLE IF EXISTS stg_amazon_sales;
