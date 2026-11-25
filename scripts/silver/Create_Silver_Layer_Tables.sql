/*
================================================================================
    Script Name:    Create_Silver_Layer_Tables
    Database:       DataWarehouse
    Schema:         Silver

    Description:
        This script creates the Silver layer tables in the DataWarehouse
        database.

        The Silver layer stores cleaned, standardized, and transformed data
        loaded from the Bronze layer, preparing it for further integration
        and analytical processing.

    Source Systems:

        1. CRM (Customer Relationship Management)
            - crm_cust_info
            - crm_prd_info
            - crm_sales_details

        2. ERP (Enterprise Resource Planning)
            - erp_cust_az12
            - erp_loc_a101
            - erp_px_cat_g1v2

    Tables Created:
        1. silver.crm_cust_info
        2. silver.crm_prd_info
        3. silver.crm_sales_details
        4. silver.erp_cust_az12
        5. silver.erp_loc_a101
        6. silver.erp_px_cat_g1v2

    Operations:
        1. Check whether each Silver table already exists.
        2. Drop existing tables to allow recreation.
        3. Create the six Silver layer tables with their respective columns
           and data types.
        4. Add a dwh_create_date column to each table to record the
           data warehouse record creation timestamp.

    Technical Details:
        - Uses DROP TABLE to remove existing tables.
        - Uses CREATE TABLE to define table structures.
        - Uses DATETIME2 for the warehouse creation timestamp.
        - Uses DEFAULT GETDATE() to automatically populate dwh_create_date
          when a new record is inserted without specifying this column.

    Important Notes:
        - Running this script will permanently delete existing Silver tables
          and all their data.
        - Bronze layer tables are not affected.
        - The script creates table structures only; data loading is handled
          separately by the silver.load_silver stored procedure.

================================================================================
*/

USE DataWarehouse;
GO

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO


CREATE TABLE silver.crm_cust_info(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_firstname NVARCHAR(50),
	cst_lastname NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.crm_prd_info','U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info(
	prd_id INT,
	prd_key NVARCHAR(50),
	cat_id NVARCHAR(50),
	prd_nm NVARCHAR(50),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
	);
GO

IF OBJECT_ID('silver.crm_sales_details','U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quant INT,
	sls_price INT,
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_cust_az12','U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_loc_a101','U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

IF OBJECT_ID('silver.erp_px_cat_g1v2','U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2 DEFAULT GETDATE()
);
GO

