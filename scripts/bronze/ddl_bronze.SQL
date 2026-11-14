/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This script loads data into the 'bronze' database from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `LOAD DATA INFILE` command to load data from CSV files.
===============================================================================
*/


DROP TABLE IF EXISTS bronze_crm_cust_info;
CREATE TABLE bronze.crm_cust_info (
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);

DROP TABLE IF EXISTS bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info (
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);

DROP TABLE IF EXISTS bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);

DROP TABLE IF EXISTS bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12 (
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101 (
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50)
);

DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
);


SET SESSION sql_mode = '';

SET @batch_start_time = NOW(3);

SELECT '===================================================================' AS log_message;
SELECT 'Loading Bronze Layer' AS log_message;
SELECT '===================================================================' AS log_message;

SELECT '--------------------------------------------------------------------' AS log_message;
SELECT 'Loading CRM Tables' AS log_message;
SELECT '--------------------------------------------------------------------' AS log_message;

-- 1. crm_cust_info
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.crm_cust_info' AS log_message;
TRUNCATE TABLE bronze.crm_cust_info;
SELECT '>> Inserting data into: bronze.crm_cust_info' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
INTO TABLE bronze.crm_cust_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

-- 2. crm_prd_info
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.crm_prd_info' AS log_message;
TRUNCATE TABLE bronze.crm_prd_info;
SELECT '>> Inserting data into: bronze.crm_prd_info' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
INTO TABLE bronze.crm_prd_info
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

-- 3. crm_sales_details
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.crm_sales_details' AS log_message;
TRUNCATE TABLE bronze.crm_sales_details;
SELECT '>> Inserting data into: bronze.crm_sales_details' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
INTO TABLE bronze.crm_sales_details
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

SELECT '--------------------------------------------------------------------' AS log_message;
SELECT 'Loading ERP Tables' AS log_message;
SELECT '--------------------------------------------------------------------' AS log_message;

-- 4. erp_cust_az12
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.erp_cust_az12' AS log_message;
TRUNCATE TABLE bronze.erp_cust_az12;
SELECT '>> Inserting data into: bronze.erp_cust_az12' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
INTO TABLE bronze.erp_cust_az12
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

-- 5. erp_loc_a101
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.erp_loc_a101' AS log_message;
TRUNCATE TABLE bronze.erp_loc_a101;
SELECT '>> Inserting data into: bronze.erp_loc_a101' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
INTO TABLE bronze.erp_loc_a101
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

-- 6. erp_px_cat_g1v2
SET @start_time = NOW(3);
SELECT '>> Truncating table: bronze.erp_px_cat_g1v2' AS log_message;
TRUNCATE TABLE bronze.erp_px_cat_g1v2;
SELECT '>> Inserting data into: bronze.erp_px_cat_g1v2' AS log_message;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
INTO TABLE bronze.erp_px_cat_g1v2
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
SET @end_time = NOW(3);
SELECT 
    CONCAT('>>>>>> Load duration: ',
            TIMESTAMPDIFF(SECOND,
                @start_time,
                @end_time),
            ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

SET @batch_end_time = NOW(3);
SELECT '===================================================================' AS log_message;
SELECT 'Loading Bronze Layer is Completed' AS log_message;
SELECT 
    CONCAT(' - Total load duration: ',
            TIMESTAMPDIFF(SECOND,
                @batch_start_time,
                @batch_end_time),
            ' seconds') AS log_message;
SELECT '===================================================================' AS log_message;
