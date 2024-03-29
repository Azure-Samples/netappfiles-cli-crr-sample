---
page_type: sample
languages:
- bash
- azurecli
products:
- azure
- azure-netapp-files
description: This project demonstrates how to use Azure CLI commands for Azure NetAppFiles to a Cross-Region Replication NFSv4.1 Volume.
---

# Azure CLI NetAppFiles CRR Sample Script

This project demonstrates how to deploy a cross-region replication with enabled NFS 4.1 protocol volume using Azure CLI module and Azure NetApp Files SDK.

In this sample application we perform the following operations:

* Creation
  * Primary NetApp account
    * Primary capacity pool
      * Primary NFS v3 volume
  * Secondary NetApp account
    * Secondary capacity pool
      * Secondary NFS v3 Data Replication volume with reference to the primary volume Resource ID
* Authorize primary volume with secondary volume Resource ID
* Clean up created resources (not enabled by default) 
 
 * Deletion, the clean up process takes place (not enabled by default, please set the parameter SHOULD_CLEANUP to true if you want the clean up code to take a place),deleting all resources in the reverse order following the hierarchy otherwise we can't remove resources that have nested resources still live. 

If you don't already have a Microsoft Azure subscription, you can get a FREE trial account [here](http://go.microsoft.com/fwlink/?LinkId=330212).

## Prerequisites

1. Azure Subscription.
2. Subscription needs to have Azure NetApp Files resource provider registered. For more information, see [Register for NetApp Resource Provider](https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-register).
3. Resource Group created
4. Virtual Network with a delegated subnet to Microsoft.Netapp/volumes resource. For more information, please refer to [Guidelines for Azure NetApp Files network planning](https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-network-topologies)
5. Make sure [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) is installed.
6. Windows with WSL enabled (Windows Subsystem for Linux) or Linux to run the script. This was developed/tested on Ubuntu 18.04 LTS (bash version 4.4.20).
7. Make sure [jq](https://stedolan.github.io/jq/) package is installed before executing this script.

	
# How the project is structured

The following table describes all files within this solution:

| Folder     | FileName                | Description                                                                                                                         |
|------------|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| src        | CreateANFCRR.sh         | Authenticates and executes all operations                                                                                           |


# How to run the script

1. Clone it locally
    ```powershell
    git clone https://github.com/Azure-Samples/netappfiles-cli-crr-sample.git
    ```
	
1. Open a bash session and execute the following Run the script

	 * Change folder to **netappfiles-cli-crr-sample\src\**
	 * Open CreateANFCRR.sh and edit all the parameters
	 * Save and close
	 * Run the following command
	 ``` Terminal
	 ./CreateANFCRR.sh
	 ```

	Sample output
	![e2e execution](./media/e2e-execution.PNG)

	
# References

* [Azure NetApp Files Az commands](https://docs.microsoft.com/en-us/cli/azure/netappfiles?view=azure-cli-latest)
* [Resource limits for Azure NetApp Files](https://docs.microsoft.com/en-us/azure/azure-netapp-files/azure-netapp-files-resource-limits)
* [Azure Cloud Shell](https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart)
* [Download Azure SDKs](https://azure.microsoft.com/downloads/)
