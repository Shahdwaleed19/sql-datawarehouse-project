/*
================================================================================
    Script Name:    Bronze_Layer_Data_Loading_Procedure
    Database:       DataWarehouse
    Procedure:      bronze.load_bronze

    Description:
        This stored procedure loads raw data from CRM and ERP source CSV files
        into the Bronze layer tables.

        It uses a Full Load strategy by truncating existing table data
        before loading fresh data using BULK INSERT.

    Source Systems:

        1. CRM (Customer Relationship Management)
            - cust_info.csv       -> bronze.crm_cust_info
            - prd_info.csv        -> bronze.crm_prd_info
            - sales_details.csv   -> bronze.crm_sales_details

        2. ERP (Enterprise Resource Planning)
            - CUST_AZ12.csv       -> bronze.erp_cust_az12
            - LOC_A101.csv        -> bronze.erp_loc_a101
            - PX_CAT_G1V2.csv     -> bronze.erp_px_cat_g1v2

    Procedure Workflow:

        1. Capture the batch start time.
        2. Load CRM source tables:
            - Truncate existing table data.
            - Insert fresh data using BULK INSERT.
        3. Load ERP source tables:
            - Truncate existing table data.
            - Insert fresh data using BULK INSERT.
        4. Calculate and print individual table loading durations.
        5. Capture the batch end time.
        6. Display the total batch execution duration.
        7. Handle errors using TRY...CATCH.

    Logging:
        - Loading progress for each source table.
        - Individual table loading duration.
        - Total batch loading duration.
        - Error message, error number, and error state.

    Load Strategy:
        Full Load (TRUNCATE + BULK INSERT)

    Error Handling:
        TRY...CATCH block to capture and display loading errors.

    Important Notes:
        - Existing table data is deleted before each reload.
        - SQL Server must have access to the source CSV files.
        - The procedure does not implement transaction rollback.

================================================================================
*/
CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME , @batch_start_time DATETIME, @batch_end_time DATETIME
	BEGIN TRY
		
		SET @batch_start_time = GETDATE();

		PRINT '=============================================';
		PRINT 'Starting loading bronze tables';
		PRINT '=============================================';

		PRINT '----------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.crm_cust_info';
		TRUNCATE TABLE [bronze].[crm_cust_info];

		PRINT '>> Inserting data into table: bronze.crm_cust_info';
		BULK INSERT  [bronze].[crm_cust_info]
		FROM 'E:\DataOps\Learning\SQLProject\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: bronze.crm_prd_info';
		TRUNCATE TABLE [bronze].[crm_prd_info];


		PRINT '>> Inserting data into table: bronze.crm_prd_info';
		BULK INSERT [bronze].[crm_prd_info]
		FROM 'E:\DataOps\Learning\SQLProject\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: bronze.crm_sales_details';
		TRUNCATE TABLE [bronze].[crm_sales_details];

		PRINT '>> Inserting data into table: bronze.crm_sales_details';
		BULK INSERT [bronze].[crm_sales_details]
		FROM 'E:\DataOps\Learning\SQLProject\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		PRINT '----------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();

		PRINT '>> Truncating Table: bronze.erp_cust_az12';
		TRUNCATE TABLE [bronze].[erp_cust_az12];

		PRINT '>> Inserting data into table: bronze.erp_cust_az12';
		BULK INSERT [bronze].[erp_cust_az12]
		FROM 'E:\DataOps\Learning\SQLProject\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			ROWTERMINATOR = '\n',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_loc_a101';
		TRUNCATE TABLE [bronze].[erp_loc_a101];

		PRINT '>> Inserting data into table: bronze.erp_loc_a101';
		BULK INSERT [bronze].[erp_loc_a101]
		FROM 'E:\DataOps\Learning\SQLProject\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE [bronze].[erp_px_cat_g1v2];

		PRINT '>> Inserting data into table: bronze.erp_px_cat_g1v2';
		BULK INSERT [bronze].[erp_px_cat_g1v2]
		FROM 'E:\DataOps\Learning\SQLProject\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);

		SET @end_time = GETDATE();
		PRINT 'Load Duration : ' + CAST(DATEDIFF(SECOND,@start_time,@end_time) as nvarchar) + ' seconds';
		PRINT '----------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '=============================================';
		PRINT ' Bronze layer is completed';
		PRINT '=============================================';
        PRINT '   - Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds';
	END TRY
	BEGIN CATCH
		PRINT '=============================================';
		PRINT 'Error occurred during loading bronze tables';
		PRINT '=============================================';
		PRINT 'Error message: ' + ERROR_MESSAGE();
		PRINT 'Error number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
		PRINT 'Error state: ' + CAST(ERROR_STATE() AS NVARCHAR);
	END CATCH
END
