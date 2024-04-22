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
The README.md files under each flow should outline the version of Power Automate Desktop in which the flow code was generated. 
In most cases, Power Automate Desktop code is compatible with the same version and later versions of the application. Backward compatibility is not guaranteed, but it may still work either fully or partially.

In case you are trying to paste a code snippet that is made with a later version of Power Automate Desktop than yours, your options are:

* Update your instance of Power Automate Desktop to the latest version
* Try pasting the actions anyway
* Paste them one by one avoiding those that are not accepted and create the invalid actions manually

If the syntax of a certain action has changed in the later version, pasting the entire code block will be cancelled by the designer and you will not get any actions at all.
To get at least some of them pasted, you can try splitting the block into smaller chunks or pasting the actions one by one, until you hit one that is not accepted.
It is very likely that most actions will still be accepted anyway, especially simple actions, such as **Set variable**, **Run subflow**, etc., while more recent actions or actions with more custom attributes may not be allowed.

Then create the actions that were not accepted manually by following the screenshots, the descriptions or the code that is provided for the flow.

## Preparation needed

Some general preparation is recommended before attempting to implement any of the flows and other functionalities within the framework.

### Environments

The Framework should have its own dedicated development environment. This is the only environment where the Framework should reside as an unmanaged solution. 

It should be imported as a managed solution to all other environments where flows will use the framework, including normal DEV, TEST, UAT and other non-production environments. This is so that changes cannot be made to the framework outside of its own DEV environment, but it can be used by calling utility flows such as the **Logger** as child flows, as well as making copies of the template flows for new projects.

### Solution

All of the flows you want to implement in your tenant should be added into a single solution that should reside as unmanaged in the dedicated environment (see above), but exported as managed to any other environments.
The recommended name of the solution is **PADFramework**.