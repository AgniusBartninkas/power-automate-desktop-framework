# ConfigReader

The ConfigReader flow retrieves externally stored config values for the parent flow based on the inputs provided.
It is to be called as a child flow by other flows, and as such it should reside as a utility flow that does not need to be copied, but can be re-used.

## Disclaimer
This utility flow is only required if you want to config data externally, and do not want to have a cloud flow retrieving it and passing it into the desktop flow as inputs. If you prefer using Power Platform environment variables in solutions, or have external configurations retrieved via a cloud flow, this utility flow is not needed.

## Version compatibility

The code is compatible with Power Automate Desktop version 2.45.375.24159 and later. Backward compatibility is not guaranteed, but it might work with earlier versions, too.
The code currently does not have a version for flows with Power Fx enabled. However, as this is a flow that should be called as a child flow by other flows, it should not matter. It should simply be created without enabling Power Fx.

## Inputs expected

There are several inputs required by this flow, and a couple that are optional (depending on other parameters):

1. **Input_ConfigAddress** - Should contain the connection string or a site address when the config type is 'Database' or 'SharePoint' respectively, or a file path when the type is 'Excel'. Should be marked as **sensitive** in case the string contains any sensitive information, such as credentials. Should also be marked as **optional** as it is optional for other config types.
1. **Input_ConfigPath** - Should contain the path to the config data. Should contain the file path when the config type is 'JSON', a sheet name when the type is 'Excel', a list name when the type is 'SharePoint', a table name when the type is 'Dataverse', or either a table name (not recommended) or a stored procedure name when the type is 'Database'. Should be marked as **sensitive** in case it contains any sensitive information.
1. **Input_ConfigType** - Should contain the config type. Currently supported options are:
    1. JSON
    1. Excel
    1. Database
    1. Dataverse
    1. SharePoint
1. **Input_ProjectName** - Should contain the name of the project to identify the relevant entries in the database. Should be marked as **optional**, as it is irrelevant when config type is 'JSON' or 'Excel'.

## Output produced

The flow produces several output variables that are returned to the parent flow after execution:

1. **Output_ConfigObject** - Returns the custom object with the config data. Should be marked as **sensitive** as the data may contain sensitive values.
1. **Output_Message** - Contains the response of the flow. Can either return a success, or a failure response. Should be used by the parent flow for any logging after calling the child flow. Should be marked as **sensitive** in case the message may contain any sensitive data.
1. **Output_Status** - Contains the status code for the response of the flow. Uses standard HTTP status codes. Can either return a success (200), or a failure status (4xx, 5xx). Should be checked by the parent flow to verify if the child flow succeeded.

## Minimal path to awesome

1. If you have not prepared an environment and a solution for the framework yet:
    1. Open the browser and navigate to [Power Automate cloud portal](https://make.powerautomate.com/)
    1. Create an dedicated environment for the Framework (DEV environments for other flows should contain a managed solution of the Framework - see **Notes** below)
    1. Create a solution called **PADFramework** in the new environment
1. Open **Power Automate Desktop**
1. Create a new flow called **PADFramework: WorkItemHandler** - make sure to not enable Power Fx when creating it

    ![View of the flow creation window in PAD](./assets/creating-the-flow.png)

1. Create the following input and output variables (use the same names for "Variable name" and "External name" fields to avoid unneccessary confusion):
    1. Input:
        1. Input_ConfigAddress (Data type - Text; Mark as sensitive - True; Mark as optional - False)

            ![View of the parameters for the 'Input_ConfigAddress' input variable in PAD](./assets/input-config-address-variable-parameters.png)

        1. Input_ConfigPath (Data type - Text; Mark as sensitive - True; Mark as optional - False)
        1. Input_ConfigType (Data type - Text; Mark as sensitive - False; Mark as optional - False)
        1. Input_ProjectName (Data type - Text; Mark as sensitive - False; Mark as optional - True)
    1. Output:
        1. Output_ConfigObject (Data type: Custom object; Mark as sensitive - True)
        1. Output_Message (Data type: Text; Mark as sensitive - True)

            ![View of the parameters for the 'Output_Message' input variable in PAD](./assets/output-message-variable-parameters.png)

        1. Output_Status (Data type: Number; Mark as sensitive - False)

1. Create new subflows (see **Notes**): 
    1. **PerformSQLServerOperations** 
    1. **PerformSQLiteOperations** 
    1. **SQLServerCompleteWorkItem**
    1. **SQLServerGetWorkItem**
    1. **SQLServerUpsertWorkItem**
    1. **SQLiteCompleteWorkItem**
    1. **SQLiteGetProjectId**
    1. **SQLiteGetStatuses**
    1. **SQLiteGetUnprocessedWorkItem**
    1. **SQLiteGetWorkItem**
    1. **SQLiteInsertWorkItemResult**
    1. **SQLiteUpdateAccumulatedRunTime**
    1. **SQLiteUpdateFlowName**
    1. **SQLiteUpdateWorkItemStatus**
    1. **SQLiteUpsertWorkItem**
1. Copy the code in the .txt files in `\source\` and paste it into Power Automate Desktop flow designer window into the appropriate subflows (see **Notes**):
    1. **main.txt** to the **Main** subflow
    1. **perform-sql-server-operations.txt** to the **PerformSQLServerOperations** subflow
    1. **perform-sqlite-operations.txt** to the **PerformSQLiteOperations** subflow
    1. **sql-server-complete-work-item.txt** to the **SQLServerCompleteWorkItem** subflow
    1. **sql-server-get-work-item.txt** to the **SQLServerGetWorkItem** subflow
    1. **sql-server-upsert-work-item.txt** to the **SQLServerUpsertWorkItem** subflow
    1. **sqlite-complete-work-item.txt** to the **SQLiteCompleteWorkItem** subflow
    1. **sqlite-get-project-id.txt** to the **SQLiteGetProjectId** subflow
    1. **sqlite-get-statuses.txt** to the **SQLiteGetStatuses** subflow
    1. **sqlite-get-unprocessed-work-item.txt** to the **SQLiteGetUnprocessedWorkItem** subflow
    1. **sqlite-get-work-item.txt** to the **SQLiteGetWorkItem** subflow
    1. **sqlite-insert-work-item-result.txt** to the **SQLiteInsertWorkItemResult** subflow
    1. **sqlite-update-accumulated-run-time.txt** to the **SQLiteUpdateAccumulatedRunTime** subflow
    1. **sqlite-update-flow-name.txt** to the **SQLiteUpdateFlowName** subflow
    1. **sqlite-update-work-item-status.txt** to the **SQLiteUpdateWorkItemStatus** subflow
    1. **sqlite-upsert-work-item.txt** to the **SQLiteUpsertWorkItem** subflow
1. Review the code for any syntax errors

    ![View of the code in the Main subflow in PAD](./assets/main-subflow-example.png)

1. Click **Save** in the flow designer
1. Add the **PADFramework: WorkItemHandler** flow to the **PADFramework** solution for exporting it to other environments

    ![View of the menu path to add an existing desktop flow to a solution](./assets/adding-existing-desktop-flow-to-solution.png)

1. When exporting to other environments, export it as a **Managed** solution, so that it can be used, but not modified. Logger should be managed even in DEV environments for other flows (see **Notes** below)
1. **Enjoy**

## Notes

### Environments

The Framework should have its own dedicated development environment. This is the only environment where the Framework should reside as an unmanaged solution. 

It should be imported as a managed solution to all other environments where flows will use the framework, including normal DEV, TEST, UAT and other non-production environments. This is so that changes cannot be made to the framework outside of its own DEV environment, but it can be used by calling utility flows such as the **WorkItemHandler** as child flows, as well as making copies of the template flows for new projects.

### Using direct SQL Statements vs Stored Procedures in SQL Server

Using Stored Procedures is the recommended approach when working with SQL Server, as SQL code is then handled by the database admin and it then becomes much easier to manage what a user or a group of users is allowed to do within the database. It requires actually creating those stored procedures, but it then enables much better governance.