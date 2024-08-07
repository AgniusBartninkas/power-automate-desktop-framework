# power-automate-desktop-framework
This repository contains the framework for building standardized Microsoft Power Automate Desktop flows.

![](./assets/PowerAutomate_scalable.svg) 

It contains the following frequently used functionalities as components:
* Error handling
* Logging
* Reading external configurations
* Processing work items
* Sending emails
* Launching and closing web browsers
* Launching and closing Excel
* A template for custom subflows

## Version Compatibility
A full exported unmanaged solution file is now available for importing to your enviroment if you have a Premium license of Power Automate. This file has been packaged with Power Automate Desktop version 2.46.163.24194. Power Automate will handle any updates needed to later versions as well. The flows may not be compatible with earlier versions and in cases like that - they will throw an error preventing them from being edited.

If you do not have a Premium license or want to use this with an earlier version of PAD, you can try using the code snippets in `/src/flows/`.

The README.md files under each flow should outline the version of Power Automate Desktop in which the flow code was generated. 
In most cases, Power Automate Desktop code is compatible with the same version of the application. Compatibility with other versions is not guaranteed, but it may still work either fully or partially.

In case you are trying to paste a code snippet that is made with a different version of Power Automate Desktop than yours, your options are:

* Update your instance of Power Automate Desktop to the latest version
* Try pasting the actions anyway
* Paste them one by one avoiding those that are not accepted and create the invalid actions manually

If the syntax of a certain action has changed in the later version, pasting the entire code block will be cancelled by the designer and you will not get any actions at all.
To get at least some of them pasted, you can try splitting the block into smaller chunks or pasting the actions one by one, until you hit one that is not accepted.
It is very likely that most actions will still be accepted anyway, especially simple actions, such as **Set variable**, **Run subflow**, etc., while more recent actions or actions with more custom attributes may not be allowed.

Then create the actions that were not accepted manually by following the screenshots, the descriptions or the code that is provided for the flow.

## Minimal path to awesome
1. If you have not prepared an environment for the framework yet:
    1. Open the browser and navigate to [Power Automate cloud portal](https://make.powerautomate.com/)
    1. Create an dedicated environment for the Framework (DEV environments for other flows should contain a managed solution of the Framework - see a note on **Environments** below)
1. Open the browser and navigate to [Power Automate cloud portal](https://make.powerautomate.com/)
1. Navigate to Connections and create the connections needed for the solution:
    1. Microsoft Dataverse
    1. Office 365 Outlook
    1. SharePoint
1. Navigate to Solutions and press *Import solution*
1. Follow the wizzard for importing solutions. When prompted to provide a solution file, select the zipped file in `/solution/`
1. When prompted to review connection references, map the connections you created to the connection references in the solution
1. Follow along with the wizzard and wait for the import to complete
1. Open Power Automate Desktop, select the environment you created for the framework and refresh the flows to see them

## Preparation needed

Some general preparation is recommended before attempting to implement any of the flows and other functionalities within the framework.

### Environments

The Framework should have its own dedicated development environment. This is the only environment where the Framework should reside as an unmanaged solution. 

It should be imported as a managed solution to all other environments where flows will use the framework, including normal DEV, TEST, UAT and other non-production environments. This is so that changes cannot be made to the framework outside of its own DEV environment, but it can be used by calling utility flows such as the **Logger** as child flows, as well as making copies of the template flows for new projects.

### Solution

All of the flows you want to implement in your tenant should be added into a single solution that should reside as unmanaged in the dedicated environment (see above), but exported as managed to any other environments.
The recommended name of the solution is **PADFramework**.