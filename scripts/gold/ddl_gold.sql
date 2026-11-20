/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    Creates the views for the Gold layer (star schema).
    Each view combines and cleans data from the Silver layer into
    business-ready dimension and fact tables.

Usage:
    These views can be queried directly for analytics and reporting.
    Note: Gold is made of views, so it has no load procedure.
===============================================================================
*/

-- Drop the fact view first because it depends on the dimension views
DROP VIEW IF EXISTS gold.fact_sales;
DROP VIEW IF EXISTS gold.dim_products;
DROP VIEW IF EXISTS gold.dim_customers;

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================
CREATE VIEW gold.dim_customers AS
SELECT
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
    ci.cst_id                              AS customer_id,
    ci.cst_key                             AS customer_number,
    ci.cst_firstname                       AS first_name,
    ci.cst_lastname                        AS last_name,
    la.CNTRY                               AS country,
    ci.cst_marital_status                  AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr   -- CRM is the master for gender info
        ELSE COALESCE(ca.GEN, 'n/a')
    END                                    AS gender,
    ca.BDATE                               AS birthdate,
    ci.cst_create_date                     AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca ON ca.CID = ci.cst_key
LEFT JOIN silver.erp_loc_a101  la ON la.CID = ci.cst_key;

-- =============================================================================
-- Create Dimension: gold.dim_products
-- =============================================================================
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
    pn.prd_id       AS product_id,
    pn.prd_key      AS product_number,
    pn.prd_nm       AS product_name,
    pn.cat_id       AS category_id,
    pc.CAT          AS category,
    pc.SUBCAT       AS subcategory,
    pc.MAINTENANCE  AS maintenance_required,
    pn.prd_cost     AS cost,
    pn.prd_line     AS product_line,
    pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pc.ID = pn.cat_id
WHERE pn.prd_end_dt IS NULL;   -- Filter out all historical data

-- =============================================================================
-- Create Fact Table: gold.fact_sales
-- =============================================================================
CREATE VIEW gold.fact_sales AS
SELECT
    sd.sls_ord_num  AS order_number,
    pr.product_key  AS product_key,
    cu.customer_key AS customer_key,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt  AS shipping_date,
    sd.sls_due_dt   AS due_date,
    sd.sls_sales    AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price    AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers cu ON cu.customer_id    = sd.sls_cust_id
LEFT JOIN gold.dim_products  pr ON pr.product_number = sd.sls_prd_key;
