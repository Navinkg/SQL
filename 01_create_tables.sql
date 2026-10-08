/* ==========================================================
   AMAZON SALES SQL PROJECT
   Script: 01_create_tables.sql
   Purpose: Create a normalized schema (dimension + fact tables)
            from the raw flat amazon_sales_dataset.csv so the
            project can be used to practice intermediate SQL
            concepts such as JOINs, GROUP BY/HAVING, CTEs,
            window functions and views.
   ========================================================== */

DROP TABLE IF EXISTS fact_orders;
DROP TABLE IF EXISTS dim_category;
DROP TABLE IF EXISTS dim_region;
DROP TABLE IF EXISTS dim_payment;

-- ---------- Dimension: Product Category ----------
CREATE TABLE dim_category (
    category_id     INTEGER PRIMARY KEY AUTOINCREMENT,
    category_name   TEXT NOT NULL UNIQUE
);

-- ---------- Dimension: Customer Region ----------
CREATE TABLE dim_region (
    region_id       INTEGER PRIMARY KEY AUTOINCREMENT,
    region_name     TEXT NOT NULL UNIQUE
);

-- ---------- Dimension: Payment Method ----------
CREATE TABLE dim_payment (
    payment_id      INTEGER PRIMARY KEY AUTOINCREMENT,
    payment_method  TEXT NOT NULL UNIQUE
);

-- ---------- Fact: Orders ----------
CREATE TABLE fact_orders (
    order_id            INTEGER PRIMARY KEY,
    order_date           DATE NOT NULL,
    product_id            INTEGER NOT NULL,
    category_id           INTEGER NOT NULL REFERENCES dim_category(category_id),
    price                  DECIMAL(10,2) NOT NULL,
    discount_percent       INTEGER NOT NULL,
    quantity_sold          INTEGER NOT NULL,
    region_id              INTEGER NOT NULL REFERENCES dim_region(region_id),
    payment_id             INTEGER NOT NULL REFERENCES dim_payment(payment_id),
    rating                 DECIMAL(2,1),
    review_count           INTEGER,
    discounted_price       DECIMAL(10,2) NOT NULL,
    total_revenue          DECIMAL(12,2) NOT NULL
);

CREATE INDEX idx_orders_date     ON fact_orders(order_date);
CREATE INDEX idx_orders_category ON fact_orders(category_id);
CREATE INDEX idx_orders_region   ON fact_orders(region_id);
CREATE INDEX idx_orders_payment  ON fact_orders(payment_id);
CREATE INDEX idx_orders_product  ON fact_orders(product_id);
