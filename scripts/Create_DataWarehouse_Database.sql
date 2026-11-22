/*
================================================================================
    Script Name:    Create_DataWarehouse_Database
    Description:    This script creates the DataWarehouse database and
                    initializes its three schemas:
                        - Bronze: Raw data layer
                        - Silver: Cleaned and transformed data layer
                        - Gold:   Business-ready data layer

    Operations:
        1. Check if the DataWarehouse database already exists.
        2. Switch the database to SINGLE_USER mode and roll back active
           transactions if it exists.
        3. Drop the existing database.
        4. Create a new DataWarehouse database.
        5. Create Bronze, Silver, and Gold schemas.

    WARNING:
        Running this script will permanently delete the existing
        DataWarehouse database and all its data.

================================================================================
*/

-- Create Database 'DataWarehouse'

USE master;
GO

-- Drop and recreate the 'DataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

-- Create schemas: Bronze, Silver, and Gold

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO

-- Create Database 'DataWarehouse'

USE master;
GO

-- drop and recreate the 'DataWarehouse' database
IF EXISTS(SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
	ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE DataWarehouse;
END;
GO

CREATE DATABASE DataWarehouse;
GO

-- create schemas bronze,silver,gold

USE DataWarehouse;
GO

CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
