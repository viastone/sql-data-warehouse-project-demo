/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/



-- Create Database 
USE master;
GO

-- Drop and recreate the 'DataWarehouseDemo' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouseDemo')
BEGIN
  ALTER DATABASE dataWarehouseDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP DATABASE DataWarehouseDemo;
END;
GO

CREATE DATABASE DataWarehouseDemo;
GO

USE DataWarehouseDemo;

-- Create Schemas
CREATE SCHEMA bronze;
GO -- separages batches when working with multiple SQL statements
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
