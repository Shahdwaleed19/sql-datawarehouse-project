/*
================================================================================
    Script Name:    Silver_Layer_Data_Loading_Procedure
    Database:       DataWarehouse
    Procedure:      silver.load_silver

    Description:
        This stored procedure transforms and loads data from the Bronze layer
        into the Silver layer of the DataWarehouse database.

        It performs data cleansing, standardization, validation, and
        transformation to improve data quality and prepare the data
        for downstream analytical processing.

    Source Layers:
        Bronze -> Silver

    Source Systems and Target Tables:

        1. CRM (Customer Relationship Management)
            - bronze.crm_cust_info
                -> silver.crm_cust_info
            - bronze.crm_prd_info
                -> silver.crm_prd_info
            - bronze.crm_sales_details
                -> silver.crm_sales_details

        2. ERP (Enterprise Resource Planning)
            - bronze.erp_cust_az12
                -> silver.erp_cust_az12
            - bronze.erp_loc_a101
                -> silver.erp_loc_a101
            - bronze.erp_px_cat_g1v2
                -> silver.erp_px_cat_g1v2

    Transformation Operations:

        1. Customer Information:
            - Remove duplicate customer records using ROW_NUMBER().
            - Exclude records with NULL customer IDs.
            - Trim whitespace from customer names.
            - Standardize marital status and gender values.

        2. Product Information:
            - Extract product keys and category IDs.
            - Replace NULL product costs with zero.
            - Standardize product line values.
            - Calculate product end dates using LEAD().

        3. Sales Details:
            - Validate and convert date fields.
            - Handle invalid or missing dates.
            - Recalculate sales amounts when values are invalid.
            - Derive valid product prices when missing or incorrect.
            - Prevent division by zero using NULLIF().

        4. ERP Customer Information:
            - Remove the 'NAS' prefix from customer IDs when present.
            - Handle future birth dates.
            - Standardize gender values.

        5. ERP Location Information:
            - Remove hyphens from customer IDs.
            - Standardize country codes and country names.
            - Handle NULL and empty country values.

        6. ERP Product Categories:
            - Load category, subcategory, and maintenance information.

    Procedure Workflow:

        1. Capture the batch start time.
        2. Truncate existing Silver layer tables.
        3. Transform and insert data from Bronze into Silver.
        4. Calculate and display individual table loading durations.
        5. Capture the batch end time.
        6. Display the total batch execution duration.
        7. Handle errors using TRY...CATCH.

    Logging:
        - Display loading progress for each table.
        - Display individual table loading durations.
        - Display total batch execution duration.
        - Display error message, error number, and error state.

    Load Strategy:
        Full Load (TRUNCATE + INSERT INTO ... SELECT)

    Important Notes:
        - Existing Silver table data is deleted before each reload.
        - Bronze tables remain unchanged.
        - Transformations are applied during the INSERT operation.
        - The procedure does not implement transaction rollback.
        - Errors are displayed through the CATCH block.

================================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME , @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		SET @batch_start_time = GETDATE();

		PRINT '=============================================';
		PRINT 'Starting loading silver tables';
		PRINT '=============================================';

		PRINT '----------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>Truncating table: [silver].[crm_cust_info]';
		TRUNCATE TABLE [silver].[crm_cust_info] ;

		PRINT '>Inserting into table: [silver].[crm_cust_info]';
		INSERT INTO [silver].[crm_cust_info](
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
			TRIM(cst_firstname) as cst_firstname,
			TRIM(cst_lastname) as cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'N/A'
			END AS cst_marital_status,
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'N/A'
			END AS cst_gndr,
			cst_create_date
		FROM(
		SELECT 
			*,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date desc) as RN
		FROM 
			[bronze].[crm_cust_info]
		) T
		WHERE RN=1 AND cst_id IS NOT NULL;

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();

		PRINT '>Truncating table: [silver].[crm_prd_info]';

		TRUNCATE TABLE [silver].[crm_prd_info];

		PRINT '>Inserting into table: [silver].[crm_prd_info]';
		INSERT INTO silver.crm_prd_info(
			prd_id,
			prd_key,
			cat_id,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,
			REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
			prd_nm,
			ISNULL(prd_cost,0) AS prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'T' THEN 'Touring'
				WHEN 'S' THEN 'Other Sales'
				ELSE 'N/A'
			END AS prd_line	,
			prd_start_dt,
			DATEADD(
				DAY,
				-1,
				LEAD(prd_start_dt) OVER( PARTITION BY prd_key ORDER BY prd_start_dt)
			) AS prd_end_dt
		FROM
			bronze.crm_prd_info;


		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();
		PRINT '>Truncating table: [silver].[crm_sales_details]';
		TRUNCATE TABLE [silver].[crm_sales_details];

		PRINT '>Inserting into table: [silver].[crm_sales_details]';
		INSERT INTO silver.crm_sales_details(
			sls_ord_num ,
			sls_prd_key ,
			sls_cust_id ,
			sls_order_dt ,
			sls_ship_dt ,
			sls_due_dt ,
			sls_sales ,
			sls_quant ,
			sls_price
			)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			CASE
				WHEN sls_order_dt IS NULL OR LEN(sls_order_dt) < 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,
			CASE
				WHEN sls_ship_dt IS NULL OR LEN(sls_ship_dt) < 8 THEN NULL
				ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
			END AS sls_ship_dt,
			CASE
				WHEN sls_due_dt IS NULL OR LEN(sls_due_dt) < 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
			CASE
				WHEN sls_sales<=0 OR sls_sales IS NULL OR  sls_sales != sls_quant * ABS(sls_price) THEN sls_quant *ABS(sls_price) 
				ELSE sls_sales
			END AS sls_sales,
			sls_quant,
			CASE
				WHEN sls_price IS NULL OR sls_price<=0 THEN sls_sales/NULLIF(sls_quant,0)
				ELSE sls_price
			END AS sls_price
		from
			[bronze].[crm_sales_details];

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		PRINT '----------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '----------------------------------------------';
		SET @start_time = GETDATE();
		PRINT '>Truncating table: [silver].[erp_cust_az12]';
		TRUNCATE TABLE [silver].[erp_cust_az12];

		PRINT '>Inserting into table: [silver].[erp_cust_az12]';
		INSERT INTO silver.erp_cust_az12(
				cid,
				bdate,
				gen
		)

		SELECT
			CASE 
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))
				ELSE cid
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M','MALE') THEN 'Male'
				ELSE 'N/A'
			END AS gen
		FROM
			bronze.erp_cust_az12

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();
		
		PRINT '>Truncating table: [silver].[erp_loc_a101]';
		TRUNCATE TABLE [silver].[erp_loc_a101];

		PRINT '>Inserting into table: [silver].[erp_loc_a101]';
		INSERT INTO silver.erp_loc_a101(
			cid,
			cntry
		)
		SELECT
			REPLACE(cid,'-','') AS cid,
			CASE
				WHEN TRIM(cntry) = 'DE' THEN 'Germany'
				WHEN TRIM(cntry) IN ('US','USA') THEN 'United States'
				WHEN TRIM(cntry) = '' or cntry IS NULL THEN 'N/A'
				ELSE TRIM(cntry)
			END AS cntry
		FROM
			bronze.erp_loc_a101;


		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();

		PRINT '>Truncating table: [silver].[erp_px_cat_g1v2]';
		TRUNCATE TABLE [silver].[erp_px_cat_g1v2];

		PRINT '>Inserting into table: [silver].[erp_px_cat_g1v2]';
		INSERT INTO silver.erp_px_cat_g1v2(
			cat,
			subcat,
			maintenance
		)

		SELECT
			cat,
			subcat,
			maintenance
		FROM
			bronze.erp_px_cat_g1v2;

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=============================================';
		PRINT ' Silver layer is completed';
		PRINT '=============================================';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';

	END TRY
	BEGIN CATCH
		PRINT '=============================================';
		PRINT 'Error occurred during loading silver tables';
		PRINT '=============================================';
		PRINT 'Error message: ' + ERROR_MESSAGE();
		PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
