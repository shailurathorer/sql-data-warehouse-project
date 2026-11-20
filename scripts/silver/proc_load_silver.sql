/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    Performs the ETL process to fill the 'silver' tables from the 'bronze' tables.
    - Truncates each silver table.
    - Inserts cleaned and standardized data from bronze into silver.

Usage Example:
    CALL silver.load_silver();
===============================================================================
*/

DROP PROCEDURE IF EXISTS silver.load_silver;

DELIMITER $$

CREATE PROCEDURE silver.load_silver()
BEGIN
    DECLARE v_start_time        DATETIME(3);
    DECLARE v_end_time          DATETIME(3);
    DECLARE v_batch_start_time  DATETIME(3);
    DECLARE v_batch_end_time    DATETIME(3);
    DECLARE v_errno             INT;
    DECLARE v_msg               TEXT;

    -- Error handling (like TRY...CATCH in SQL Server)
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_errno = MYSQL_ERRNO, v_msg = MESSAGE_TEXT;
        SELECT '==========================================' AS log_message;
        SELECT 'ERROR OCCURRED DURING LOADING SILVER LAYER' AS log_message;
        SELECT CONCAT('Error Number : ', v_errno) AS log_message;
        SELECT CONCAT('Error Message: ', v_msg) AS log_message;
        SELECT '==========================================' AS log_message;
        RESIGNAL;
    END;

    SET v_batch_start_time = NOW(3);

    SELECT '================================================' AS log_message;
    SELECT 'Loading Silver Layer' AS log_message;
    SELECT '================================================' AS log_message;

    SELECT '------------------------------------------------' AS log_message;
    SELECT 'Loading CRM Tables' AS log_message;
    SELECT '------------------------------------------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 1. silver.crm_cust_info
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.crm_cust_info' AS log_message;
    TRUNCATE TABLE silver.crm_cust_info;
    SELECT '>> Inserting Data Into: silver.crm_cust_info' AS log_message;
    INSERT INTO silver.crm_cust_info (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname)  AS cst_lastname,
        CASE
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            ELSE 'n/a'
        END AS cst_marital_status,  -- Normalize marital status to readable format
        CASE
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,            -- Normalize gender to readable format
        cst_create_date
    FROM (
        SELECT
            *,
            ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
        FROM bronze.crm_cust_info
        WHERE cst_id != 0
    ) t
    WHERE flag_last = 1;            -- Keep the most recent record per customer
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 2. silver.crm_prd_info
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.crm_prd_info' AS log_message;
    TRUNCATE TABLE silver.crm_prd_info;
    SELECT '>> Inserting Data Into: silver.crm_prd_info' AS log_message;
    INSERT INTO silver.crm_prd_info (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )
    SELECT
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,        -- Extract category id
        SUBSTRING(prd_key, 7, LENGTH(prd_key))      AS prd_key,       -- Extract product key
        prd_nm,
        COALESCE(prd_cost, 0) AS prd_cost,
        CASE UPPER(TRIM(prd_line))
            WHEN 'M' THEN 'Mountain'
            WHEN 'R' THEN 'Road'
            WHEN 'S' THEN 'Other Sales'
            WHEN 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,                                              -- Map codes to descriptive values
        CAST(prd_start_dt AS DATE) AS prd_start_dt,
        CAST(
            DATE_SUB(
                LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt),
                INTERVAL 1 DAY
            ) AS DATE
        ) AS prd_end_dt                                               -- End date = day before next start date
    FROM bronze.crm_prd_info;
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 3. silver.crm_sales_details
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.crm_sales_details' AS log_message;
    TRUNCATE TABLE silver.crm_sales_details;
    SELECT '>> Inserting Data Into: silver.crm_sales_details' AS log_message;
    INSERT INTO silver.crm_sales_details (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
        sls_quantity,
        sls_price
    )
    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        CASE
            WHEN sls_order_dt = 0 OR LENGTH(sls_order_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_order_dt AS CHAR) AS DATE)
        END AS sls_order_dt,
        CASE
            WHEN sls_ship_dt = 0 OR LENGTH(sls_ship_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_ship_dt AS CHAR) AS DATE)
        END AS sls_ship_dt,
        CASE
            WHEN sls_due_dt = 0 OR LENGTH(sls_due_dt) != 8 THEN NULL
            ELSE CAST(CAST(sls_due_dt AS CHAR) AS DATE)
        END AS sls_due_dt,
        CASE
            WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
        END AS sls_sales,           -- Recalculate sales if original value is missing or incorrect
        sls_quantity,
        CASE
            WHEN sls_price IS NULL OR sls_price <= 0
                THEN sls_sales / NULLIF(sls_quantity, 0)
            ELSE sls_price
        END AS sls_price            -- Derive price if original value is invalid
    FROM bronze.crm_sales_details;
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    SELECT '------------------------------------------------' AS log_message;
    SELECT 'Loading ERP Tables' AS log_message;
    SELECT '------------------------------------------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 4. silver.erp_cust_az12
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.erp_cust_az12' AS log_message;
    TRUNCATE TABLE silver.erp_cust_az12;
    SELECT '>> Inserting Data Into: silver.erp_cust_az12' AS log_message;
    INSERT INTO silver.erp_cust_az12 (
        CID,
        BDATE,
        GEN
    )
    SELECT
        CASE
            WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LENGTH(cid))   -- Remove 'NAS' prefix
            ELSE cid
        END AS cid,
        CASE
            WHEN bdate > NOW() OR bdate < '1900-01-01' THEN NULL       -- Future or invalid birthdates -> NULL
            ELSE bdate
        END AS bdate,
        CASE
            WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
            WHEN UPPER(TRIM(gen)) IN ('M', 'MALE')   THEN 'Male'
            ELSE 'n/a'
        END AS gen                                                     -- Normalize gender values
    FROM bronze.erp_cust_az12;
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 5. silver.erp_loc_a101
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.erp_loc_a101' AS log_message;
    TRUNCATE TABLE silver.erp_loc_a101;
    SELECT '>> Inserting Data Into: silver.erp_loc_a101' AS log_message;
    INSERT INTO silver.erp_loc_a101 (
        CID,
        CNTRY
    )
    SELECT
        REPLACE(cid, '-', '') AS cid,
        CASE
            WHEN TRIM(cntry) = 'DE'              THEN 'Germany'
            WHEN TRIM(cntry) IN ('US', 'USA')    THEN 'United States'
            WHEN TRIM(cntry) = '' OR cntry IS NULL THEN 'n/a'
            ELSE TRIM(cntry)
        END AS cntry                -- Normalize and handle missing or blank country codes
    FROM bronze.erp_loc_a101;
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    -- ------------------------------------------------------------------
    -- 6. silver.erp_px_cat_g1v2
    -- ------------------------------------------------------------------
    SET v_start_time = NOW(3);
    SELECT '>> Truncating Table: silver.erp_px_cat_g1v2' AS log_message;
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    SELECT '>> Inserting Data Into: silver.erp_px_cat_g1v2' AS log_message;
    INSERT INTO silver.erp_px_cat_g1v2 (
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    )
    SELECT
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    FROM bronze.erp_px_cat_g1v2;
    SET v_end_time = NOW(3);
    SELECT CONCAT('>> Load Duration: ', TIMESTAMPDIFF(SECOND, v_start_time, v_end_time), ' seconds') AS log_message;
    SELECT '>> -------------' AS log_message;

    SET v_batch_end_time = NOW(3);
    SELECT '==========================================' AS log_message;
    SELECT 'Loading Silver Layer is Completed' AS log_message;
    SELECT CONCAT('   - Total Load Duration: ', TIMESTAMPDIFF(SECOND, v_batch_start_time, v_batch_end_time), ' seconds') AS log_message;
    SELECT '==========================================' AS log_message;
END$$

DELIMITER ;
