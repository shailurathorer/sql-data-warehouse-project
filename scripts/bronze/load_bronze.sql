/*
===============================================================================
Script: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    Loads data into the 'bronze' schema from external CSV files.
    - Truncates the bronze tables before loading.
    - Uses LOAD DATA INFILE to load the CSV files.

Note:
    MySQL does not allow LOAD DATA INFILE inside stored procedures,
    so this is a plain script. Run the whole file each time.

Usage:
    Run ddl_bronze.sql first, then run this file.
===============================================================================
*/

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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
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
SELECT CONCAT('>>>>>> Load duration: ', TIMESTAMPDIFF(SECOND, @start_time, @end_time), ' seconds') AS log_message;
SELECT '>>>-----------' AS log_message;

SET @batch_end_time = NOW(3);
SELECT '===================================================================' AS log_message;
SELECT 'Loading Bronze Layer is Completed' AS log_message;
SELECT CONCAT(' - Total load duration: ', TIMESTAMPDIFF(SECOND, @batch_start_time, @batch_end_time), ' seconds') AS log_message;
SELECT '===================================================================' AS log_message;
