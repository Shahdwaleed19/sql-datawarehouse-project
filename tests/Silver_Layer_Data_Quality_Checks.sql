/*
================================================================================
    Script Name:    Silver_Layer_Data_Quality_Checks
    Database:       DataWarehouse
    Layer:          Silver

    Description:
        This script performs data quality checks on CRM and ERP tables
        in the Silver layer to validate data accuracy, consistency,
        completeness, and standardization.

        The checks help identify data quality issues before the data
        moves to the Gold layer.

    Data Quality Dimensions:
        1. Completeness:
            - Identify NULL values in key columns and required fields.
        2. Uniqueness:
            - Detect duplicate customer IDs and product keys.
        3. Consistency:
            - Validate standardized values across categorical columns.
        4. Accuracy:
            - Check sales calculations, costs, and date validity.
        5. Validity:
            - Identify invalid dates, negative values, and unexpected
              date ranges.
        6. Standardization:
            - Detect extra whitespace and inconsistent formatting.

    Source Tables:
        CRM:
            - silver.crm_cust_info
            - silver.crm_prd_info
            - silver.crm_sales_details

        ERP:
            - silver.erp_cust_az12
            - silver.erp_loc_a101
            - silver.erp_px_cat_g1v2

    Validation Areas:
        - Customer ID uniqueness and completeness.
        - Customer name whitespace validation.
        - Marital status and gender standardization.
        - Product key uniqueness and completeness.
        - Product cost validation.
        - Product name whitespace validation.
        - Product date range validation.
        - Sales date and numerical consistency.
        - Customer birth date validation.
        - ERP gender and country value standardization.
        - Product category attribute whitespace validation.

    Expected Outcome:
        Identify records that violate the defined data quality
        conditions and require further investigation or correction.

    Important Notes:
        - This script is intended for data quality inspection.
        - It does not modify, delete, or transform existing records.
        - DISTINCT queries are used to inspect available categorical values.
        - Query results should be reviewed before proceeding to the Gold layer.

================================================================================
*/

-- ============================================================================
-- 1. CRM: CUSTOMER INFORMATION QUALITY CHECKS
-- ============================================================================

-- Check customer ID completeness and uniqueness.
-- Identify NULL customer IDs and IDs appearing more than once.
SELECT 
    cst_id,
    COUNT(*)
FROM 
    [silver].[crm_cust_info]
GROUP BY
    cst_id
HAVING
    COUNT(*) > 1 OR cst_id IS NULL;


-- Check customer first names for leading or trailing whitespace.
SELECT
    cst_firstname
FROM 
    [silver].[crm_cust_info]
WHERE 
    cst_firstname != TRIM(cst_firstname);


-- Check customer last names for leading or trailing whitespace.
SELECT
    cst_lastname
FROM 
    [silver].[crm_cust_info]
WHERE 
    cst_lastname != TRIM(cst_lastname);


-- Inspect distinct marital status values to verify standardization.
SELECT 
    DISTINCT(cst_marital_status)
FROM
    [silver].[crm_cust_info];


-- Inspect distinct gender values to verify standardization.
SELECT 
    DISTINCT(cst_gndr)
FROM
    [silver].[crm_cust_info];


-- ============================================================================
-- 2. CRM: PRODUCT INFORMATION QUALITY CHECKS
-- ============================================================================

-- Preview product records for general inspection.
SELECT TOP 100 *
FROM [silver].[crm_prd_info];


-- Check product key completeness and uniqueness.
-- Identify NULL product keys and keys appearing more than once.
SELECT 
    prd_key,
    COUNT(*)
FROM 
    [silver].[crm_prd_info]
GROUP BY
    prd_key
HAVING
    COUNT(*) > 1 OR prd_key IS NULL;


-- Identify missing or negative product costs.
SELECT
    *
FROM
    [silver].[crm_prd_info]
WHERE
    prd_cost < 0 OR prd_cost IS NULL;


-- Check product names for leading or trailing whitespace.
SELECT 
    prd_nm
FROM 
    [silver].[crm_prd_info]
WHERE
    prd_nm != TRIM(prd_nm);


-- Identify invalid product date ranges.
-- A product end date should not be earlier than its start date.
SELECT
    *
FROM 
    [silver].[crm_prd_info]
WHERE
    prd_end_dt < prd_start_dt;


-- Inspect distinct product names to review available values.
SELECT
    DISTINCT(prd_nm)
FROM
    [silver].[crm_prd_info];


-- ============================================================================
-- 3. CRM: SALES DETAILS QUALITY CHECKS
-- ============================================================================

-- Validate sales order dates.
-- Identify NULL dates and dates outside the expected range.
SELECT
    sls_order_dt
FROM
    [silver].[crm_sales_details]
WHERE
    LEN(sls_order_dt) < 8
    OR sls_order_dt IS NULL
    OR sls_order_dt > 20500101
    OR sls_order_dt < 19000101;


-- Validate the chronological order of sales dates.
-- Shipping dates should not precede order dates.
-- Due dates should not precede order dates.
SELECT
    *
FROM
    [silver].[crm_sales_details]
WHERE
    sls_ship_dt < sls_order_dt
    OR sls_order_dt > sls_due_dt;


-- Validate consistency between sales amount, quantity, and price.
-- Identify mismatched calculations, NULL values, and non-positive values.
SELECT DISTINCT
    sls_sales,
    sls_quant,
    sls_price
FROM
    [silver].[crm_sales_details]
WHERE
    sls_sales != (sls_quant * sls_price)
    OR sls_sales IS NULL
    OR sls_quant IS NULL
    OR sls_price IS NULL
    OR sls_sales <= 0
    OR sls_quant <= 0
    OR sls_price <= 0;


-- ============================================================================
-- 4. ERP: CUSTOMER INFORMATION QUALITY CHECKS
-- ============================================================================

-- Validate customer birth dates.
-- Identify dates earlier than 1924 or later than the current date.
SELECT DISTINCT
    bdate
FROM
    [silver].[erp_cust_az12]
WHERE
    bdate < '1924-01-01'
    OR bdate > GETDATE();


-- Inspect distinct gender values to verify standardization.
SELECT DISTINCT
    gen
FROM 
    [silver].[erp_cust_az12];


-- ============================================================================
-- 5. ERP: LOCATION INFORMATION QUALITY CHECKS
-- ============================================================================

-- Inspect distinct country values to review country standardization.
SELECT DISTINCT
    cntry
FROM 
    [silver].[erp_loc_a101];


-- ============================================================================
-- 6. ERP: PRODUCT CATEGORY QUALITY CHECKS
-- ============================================================================

-- Check product category attributes for leading or trailing whitespace.
SELECT
    *
FROM
    [silver].[erp_px_cat_g1v2]
WHERE
    cat != TRIM(cat)
    OR subcat != TRIM(subcat)
    OR maintenance != TRIM(maintenance);


-- Inspect distinct maintenance values to review standardization.
SELECT DISTINCT
    maintenance
FROM
    [silver].[erp_px_cat_g1v2];

-- ============================================================================
-- END OF SILVER LAYER DATA QUALITY CHECKS
-- ============================================================================
