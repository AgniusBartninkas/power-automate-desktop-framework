# Database SQLite

This is a simplified standard structure for SQLite-based database for handling work items. It includes SQL scripts for creating the required tables, indexes, triggers and populating some utility tables with data.
It is relevant when using the `FlowTemplate` flow in combination with the `WorkItemHandler` flow and setting the database type to 'SQLite'.

## Version compatibility

N/A

## Minimal path to awesome

1. Download and install appropriate software and drivers on your machine: 
    1. [SQLite core](https://www.sqlite.org/download.html)  
    1. SQLite ODBC drivers. Any drivers will work. The most frequently used are [here](https://www.ch-werner.de/sqliteodbc/)
    1. A database tool. Anything that you prefer will work, as long as it is compatible with SQLite. My recommendation is for [DBeaver](https://dbeaver.io/)
1. Create a new blank database via the tool of your choice. Store it wherever you want.
1. Run the queries in `/source/`:
    1. Create tables using the queries in `/source/tables/`
    1. Create indexes using the queries in `/source/indexes/`
    1. Create triggers using the queries in `/source/triggers/`
    1. Populate the Status and Priority tables using the queries in `/source/insert/`
1. Save a copy of the database for backup as well as having separate databases for DEV/TEST/PROD (optional, but recommended).

