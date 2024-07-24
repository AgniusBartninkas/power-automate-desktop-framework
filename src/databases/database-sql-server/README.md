# Database SQL Server

This is a simplified standard structure for SQL Server-based database for handling work items as well as storing Configs. It includes SQL scripts for creating the required tables, constraints, functions, stored procedures, views, etc., as well as populating some utility tables with data.
It is relevant when using the `FlowTemplate` flow in combination with the `WorkItemHandler` flow and setting the database type to 'SQL Server'. as well as when using `ConfigReader` and storing configs in 'Database'.

## Version compatibility

N/A

## Minimal path to awesome

1. Download and install appropriate software and drivers on your machine: 
    1. [SQL Server](https://www.microsoft.com/en-us/sql-server/sql-server-downloads). Assuming you do not have it already, SQL Server Express will do just fine.
    1. [SQL Server ODBC driver](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server?view=sql-server-ver16#download-for-windows)
    1. [SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-ver16#download-ssms)
1. Run the queries in `/source/`:
    1. Create the databases using the query in `/source/databases/`. This will create two databases - one for PROD and one for DEV. If you need more, copy the code block with a new database name and run it.
    1. Create the encryptions using the query in `/source/encryptions/`. See **Notes** for more info.
    1. Create tables using the queries in `/source/tables/`. Run this on all databases you have created.
    1. Add constraints to the tables using the query in `/source/constraints/`. Run this on all databases you have created.
    1. Create functions using the queries in `/source/functions/`. Run this on all databases you have created.
    1. Create stored procedures using the queries in `/source/stored-procedures/`. Run this on all databases you have created.
    1. Create the view for work items using the query in `/source/views/` (optional). Run this on all databases you have created.
    1. Populate the Status and Priority tables using the queries in `/source/insert/`. Run this on all databases you have created.
1. Create any additional functions and stored procedures as needed (e.g. if you want to separate updating and inserting values).
1. Create appropriate users and security roles in SQL Server to secure the database before creating any connections or using this in any of your flows (see **Notes** for more info).


## Notes

### Encryption
The `create-encryptions.sql` query will create AES_256-based encryptions for storing sensitive information in SQL Server. This can then be used to store values in certain tables as well as decrypt them by providing the appropriate password.
This is not as secure as using a proper key vault, so important credentials should not be stored this way. But in some scenarios it does work and the provided 'Credentials' table can be used, and the related Stored Procedures will be able to both create entries there, as well as retrieve decrypted values.
However, this is **not recommended**. The recommended approach for storing credentials and other secrets properly is a proper key vault, such as the Azure Key Vault, CyberArk or things like that.

### Securing SQL Server
When we use SQL Server connections in our flows (whether cloud or desktop), we shouldn't use the user that created the database and has admin/owner permissions. Instead, SQL Server users should be created with appropriate roles that only supply permissions on a need to have basis. For example, a flow that interacts with work items should be allowed to execute (and only execute, nothing else) the stored procedures for getting, upserting and completing work items, but it should not be allowed, for example, to upsert projects or configs.
This is very important, especially when sharing flows and connections with users. For more info on how to create users and security roles in SQL Server, see [here](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/getting-started-with-database-engine-permissions).

