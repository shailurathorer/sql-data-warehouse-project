/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    Validates the integrity and consistency of the Gold layer. It checks:
    - Uniqueness of surrogate keys in dimension views.
    - Referential integrity between fact and dimension views.
    - Gender integration logic (CRM vs ERP).

Usage Notes:
    - Run after creating the gold views.
    - "Expectation: No Result" means the query should return zero rows.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Gender integration: CRM is the master, ERP fills in 'n/a'
SELECT DISTINCT
    ci.cst_gndr,
    ca.GEN,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE COALESCE(ca.GEN, 'n/a')
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ca.CID = ci.cst_key
LEFT JOIN silver.erp_loc_a101  la ON la.CID = ci.cst_key
ORDER BY 1, 2;

-- Duplicate customers (joins must not multiply rows)
-- Expectation: No Result
SELECT customer_key, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT customer_id, COUNT(*)
FROM gold.dim_customers
GROUP BY customer_id
HAVING COUNT(*) > 1;

-- Expectation: Female, Male, n/a
SELECT DISTINCT gender FROM gold.dim_customers;

-- Quality check table
SELECT * FROM gold.dim_customers;


-- ====================================================================
-- Checking 'gold.dim_products'
-- ====================================================================
-- Duplicate products
-- Expectation: No Result
SELECT product_key, COUNT(*)
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

SELECT product_number, COUNT(*)
FROM gold.dim_products
GROUP BY product_number
HAVING COUNT(*) > 1;

-- Quality check table
SELECT * FROM gold.dim_products;


-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Foreign key integrity (dimensions)
-- Expectation: No Result
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products  p ON p.product_key  = f.product_key
WHERE p.product_key IS NULL
   OR c.customer_key IS NULL;

-- Quality check table
SELECT * FROM gold.fact_sales;
