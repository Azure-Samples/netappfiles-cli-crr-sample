#!/bin/bash
set -euo pipefail

# Mandatory variables for ANF resources
# Change variables according to your environment 
SUBSCRIPTION_ID="f557b96d-2308-4a18-aae1-b8f7e7e70cc7"

#Primary AND variables
PRIMARY_LOCATION="WestUS"
PRIMARY_RESOURCEGROUP_NAME="adghabboPrim-rg"
PRIMARY_VNET_NAME="adghabboPrim-rg-vnet"
PRIMARY_SUBNET_NAME="primsubnet"
PRIMARY_NETAPP_ACCOUNT_NAME="anfaccount1"
PRIMARY_NETAPP_POOL_NAME="pool1"
PRIMARY_NETAPP_VOLUME_NAME="vol1"
PRIMARY_SERVICE_LEVEL="Premium"

# Secondary ANF variables
SECONDARY_LOCATION="EastUS"
SECONDARY_RESOURCEGROUP_NAME="adghabboSecon-rg"
SECONDARY_VNET_NAME="adghabboSecon-rg-vnet"
SECONDARY_SUBNET_NAME="seconsubnet"
SECONDARY_NETAPP_ACCOUNT_NAME="anfaccounts2"
SECONDARY_NETAPP_POOL_NAME="pools2"
SECONDARY_NETAPP_VOLUME_NAME="vols2"
SECONDARY_SERVICE_LEVEL="Standard"
#Common variables
NETAPP_POOL_SIZE_TIB=4
NETAPP_VOLUME_SIZE_GIB=100
PROTOCOL_TYPE="NFSv4.1"
ALLOWED_CLIENTS_IP="0.0.0.0/0"
SHOULD_CLEANUP="true"

# Exit error code
ERR_ACCOUNT_NOT_FOUND=100

# Utils Functions
display_bash_header()
{
    echo "--------------------------------------------------------------------------------------------------------------------------------------------"
    echo "Azure NetApp Files CLI CRR Sample  - Sample Bash script that creates Azure NetApp Files Cross-Region Replication (CRR) uses NFSv4.1 protocol"
    echo "--------------------------------------------------------------------------------------------------------------------------------------------"
}

display_cleanup_header()
{
    echo "----------------------------------------"
    echo "Cleaning up Azure NetApp Files Resources"
    echo "----------------------------------------"
}

display_message()
{
    time=$(date +"%T")
    message="$time : $1"
    echo $message
}
# ANF create functions

# Create Azure NetApp Files Account
create_or_update_netapp_account()
{    
    local __resultvar=$1
    local _RESOURCE_GROUP_NAME=$2
    local _NETAPP_ACCOUNT_NAME=$3
    local _LOCATION=$4
    local _NEW_ACCOUNT_ID=""

    _NEW_ACCOUNT_ID=$(az netappfiles account create --resource-group $_RESOURCE_GROUP_NAME \
        --name $_NETAPP_ACCOUNT_NAME \
        --location $_LOCATION | jq ".id")

    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'${_NEW_ACCOUNT_ID}'"
    else
        echo "${_NEW_ACCOUNT_ID}"
    fi
}


# Create Azure NetApp Files Capacity Pool
create_or_update_netapp_pool()
{
    local __resultvar=$1
    local _RESOURCE_GROUP_NAME=$2
    local _NETAPP_ACCOUNT_NAME=$3
    local _NETAPP_POOL_NAME=$4
    local _LOCATION=$5
    local _NETAPP_POOL_SIZE=$6
    local _SERVICE_LEVEL=$7
    local _NEW_POOL_ID=""

    _NEW_POOL_ID=$(az netappfiles pool create --resource-group $_RESOURCE_GROUP_NAME \
        --account-name $_NETAPP_ACCOUNT_NAME \
        --name $_NETAPP_POOL_NAME \
        --location $_LOCATION \
        --size $_NETAPP_POOL_SIZE \
        --service-level $_SERVICE_LEVEL | jq ".id")

    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'${_NEW_POOL_ID}'"
    else
        echo "${_NEW_POOL_ID}"
    fi
}


# Create Azure NetApp Files Volume
create_or_update_netapp_volume()
{
    local __resultvar=$1
    local _RESOURCE_GROUP_NAME=$2
    local _NETAPP_ACCOUNT_NAME=$3
    local _NETAPP_POOL_NAME=$4
    local _NETAPP_VOLUME_NAME=$5
    local _LOCATION=$6
    local _NETAPP_VOLUME_SIZE=$7
    local _SERVICE_LEVEL=$8
    local _PROTOCOL_TYPE=$9
    local _VNET_NAME=${10}
    local _SUBNET_NAME=${11}
    local _ALLOWED_CLIENTS=${12}
    local _NEW_VOLUME_ID=""
    
    # Volumes are always created with a default Export Policy
    _NEW_VOLUME_ID=$(az netappfiles volume create --resource-group $_RESOURCE_GROUP_NAME \
        --account-name $_NETAPP_ACCOUNT_NAME \
        --file-path $_NETAPP_VOLUME_NAME \
        --pool-name $_NETAPP_POOL_NAME \
        --name $_NETAPP_VOLUME_NAME \
        --location $_LOCATION \
        --service-level $_SERVICE_LEVEL \
        --usage-threshold $_NETAPP_VOLUME_SIZE \
        --vnet $_VNET_NAME \
        --subnet $_SUBNET_NAME \
        --protocol-types $_PROTOCOL_TYPE | jq -r ".id")
        
    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'${_NEW_VOLUME_ID}'"
    else
        echo "${_NEW_VOLUME_ID}"
    fi      
}

create_netapp_datareplication_volume()
{
    local __resultvar=$1
    local _RESOURCE_GROUP_NAME=$2
    local _NETAPP_ACCOUNT_NAME=$3
    local _NETAPP_POOL_NAME=$4
    local _NETAPP_VOLUME_NAME=$5
    local _LOCATION=$6
    local _NETAPP_VOLUME_SIZE=$7
    local _SERVICE_LEVEL=$8
    local _PROTOCOL_TYPE=$9
    local _VNET_NAME=${10}
    local _SUBNET_NAME=${11}
    local _ALLOWED_CLIENTS=${12}
    local _PRIMARY_VOLUME_ID=${13}
    local _NEW_VOLUME_ID=""

    _NEW_VOLUME_ID=$(az netappfiles volume create --resource-group $_RESOURCE_GROUP_NAME \
        --account-name $_NETAPP_ACCOUNT_NAME \
        --file-path $_NETAPP_VOLUME_NAME \
        --pool-name $_NETAPP_POOL_NAME \
        --name $_NETAPP_VOLUME_NAME \
        --location $_LOCATION \
        --service-level $_SERVICE_LEVEL \
        --usage-threshold $_NETAPP_VOLUME_SIZE \
        --vnet $_VNET_NAME \
        --subnet $_SUBNET_NAME \
        --protocol-types $_PROTOCOL_TYPE \
        --endpoint-type "dst" \
        --remote-volume-resource-id $_PRIMARY_VOLUME_ID \
        --replication-schedule "hourly" \
        --volume-type "DataProtection" | jq -r ".id")
    
    if [[ "$__resultvar" ]]; then
        eval $__resultvar="'${_NEW_VOLUME_ID}'"
    else
        echo "${_NEW_VOLUME_ID}"
    fi      
}

# ANF cleanup functions

# Delete Azure NetApp Files Account
delete_netapp_account()
{
    az netappfiles account delete --resource-group $RESOURCEGROUP_NAME \
        --name $NETAPP_ACCOUNT_NAME    
}

# Delete Azure NetApp Files Capacity Pool
delete_netapp_pool()
{
    az netappfiles pool delete --resource-group $RESOURCEGROUP_NAME \
        --account-name $NETAPP_ACCOUNT_NAME \
        --name $NETAPP_POOL_NAME
    sleep 10    
}

# Delete Azure NetApp Files Volume
delete_netapp_volume()
{
    az netappfiles volume delete --resource-group $RESOURCEGROUP_NAME \
        --account-name $NETAPP_ACCOUNT_NAME \
        --pool-name $NETAPP_POOL_NAME \
        --name $NETAPP_VOLUME_NAME
    sleep 10
}

#Script Start
#Display Header
display_bash_header

# Login and Authenticate to Azure
display_message "Authenticating into Azure"
az login

# Set the target subscription 
display_message "setting up the target subscription"
az account set --subscription $SUBSCRIPTION_ID

# Provision Primary ANF Resources
display_message "Creating Azure NetApp Files Primary Account ..."
{    
    NEW_PRIMARY_ACCOUNT_ID="";create_or_update_netapp_account NEW_PRIMARY_ACCOUNT_ID $PRIMARY_RESOURCEGROUP_NAME $PRIMARY_NETAPP_ACCOUNT_NAME $PRIMARY_LOCATION
    display_message "Azure NetApp Files Primary Account was created successfully: $NEW_PRIMARY_ACCOUNT_ID"
} || {
    display_message "Failed to create Azure NetApp Files Primary Account"
    exit 1
}

display_message "Creating Azure NetApp Files Primary Capacity Pool ..."
{
    NEW_PRIMARY_POOL_ID="";create_or_update_netapp_pool NEW_PRIMARY_POOL_ID $PRIMARY_RESOURCEGROUP_NAME $PRIMARY_NETAPP_ACCOUNT_NAME $PRIMARY_NETAPP_POOL_NAME $PRIMARY_LOCATION $NETAPP_POOL_SIZE_TIB $PRIMARY_SERVICE_LEVEL
    display_message "Azure NetApp Files Primary pool was created successfully: $NEW_PRIMARY_POOL_ID"
} || {
    display_message "Failed to create Azure NetApp Files Primary pool"
    exit 1
}

display_message "Creating Azure NetApp Files Primary Volume..."
{
    NEW_PRIMARY_VOLUME_ID="";create_or_update_netapp_volume NEW_PRIMARY_VOLUME_ID $PRIMARY_RESOURCEGROUP_NAME $PRIMARY_NETAPP_ACCOUNT_NAME $PRIMARY_NETAPP_POOL_NAME $PRIMARY_NETAPP_VOLUME_NAME $PRIMARY_LOCATION $NETAPP_VOLUME_SIZE_GIB $PRIMARY_SERVICE_LEVEL $PROTOCOL_TYPE $PRIMARY_VNET_NAME $PRIMARY_SUBNET_NAME $ALLOWED_CLIENTS_IP
    display_message "Azure NetApp Files Primary volume was created successfully: $NEW_PRIMARY_VOLUME_ID"
} || {
    display_message "Failed to create Azure NetApp Files Primary volume"
    exit 1
}

# Provision Secondary ANF Resources
display_message "Creating Azure NetApp Files Secondary Account ..."
{    
    NEW_SECONDARY_ACCOUNT_ID="";create_or_update_netapp_account NEW_SECONDARY_ACCOUNT_ID $SECONDARY_RESOURCEGROUP_NAME $SECONDARY_NETAPP_ACCOUNT_NAME $SECONDARY_LOCATION
    display_message "Azure NetApp Files Secondary Account was created successfully: $NEW_SECONDARY_ACCOUNT_ID"
} || {
    display_message "Failed to create Azure NetApp Files Secondary Account"
    exit 1
}

display_message "Creating Azure NetApp Files Secondary Capacity Pool ..."
{
    NEW_SECONDARY_POOL_ID="";create_or_update_netapp_pool NEW_SECONDARY_POOL_ID $SECONDARY_RESOURCEGROUP_NAME $SECONDARY_NETAPP_ACCOUNT_NAME $SECONDARY_NETAPP_POOL_NAME $SECONDARY_LOCATION $NETAPP_POOL_SIZE_TIB $SECONDARY_SERVICE_LEVEL
    display_message "Azure NetApp Files Primary pool was created successfully: $NEW_SECONDARY_POOL_ID"
} || {
    display_message "Failed to create Azure NetApp Files Secondary pool"
    exit 1
}

display_message "Creating Azure NetApp Files Secondary Volume..."
{
    NEW_SECONDARY_VOLUME_ID="";create_netapp_datareplication_volume NEW_SECONDARY_VOLUME_ID $SECONDARY_RESOURCEGROUP_NAME $SECONDARY_NETAPP_ACCOUNT_NAME $SECONDARY_NETAPP_POOL_NAME $SECONDARY_NETAPP_VOLUME_NAME $SECONDARY_LOCATION $NETAPP_VOLUME_SIZE_GIB $SECONDARY_SERVICE_LEVEL $PROTOCOL_TYPE $SECONDARY_VNET_NAME $SECONDARY_SUBNET_NAME $ALLOWED_CLIENTS_IP $NEW_PRIMARY_VOLUME_ID
    display_message "Azure NetApp Files volume was created successfully: $NEW_SECONDARY_VOLUME_ID"
} || {
    display_message "Failed to create Azure NetApp Files Secondary volume"
    exit 1
}

display_message "Authorizing replication in primary volume..."
{
    az netappfiles volume replication approve --account-name $PRIMARY_NETAPP_ACCOUNT_NAME \
        --name $PRIMARY_NETAPP_VOLUME_NAME \
        --pool-name $PRIMARY_NETAPP_POOL_NAME \
        --remote-volume-resource-id $NEW_SECONDARY_VOLUME_ID \
        --resource-group $PRIMARY_RESOURCEGROUP_NAME
    display_message "Sucessfully authorized replication in primary volume"
} || {
    display_message "Failed to authorize replication in primary volume"
    exit 1
}
sleep 60

# Clean up resources
if [[ "$SHOULD_CLEANUP" == true ]]; then
    #Display cleanup header
    display_cleanup_header

    # Break volume replication
    display_message "Breaking replication connection..."
    {
        az netappfiles volume replication suspend --ids $NEW_SECONDARY_VOLUME_ID
        sleep 60
        display_message "Sucessfully broke replication connection"
    } || {
        display_message "Failed to break replication connection"
        exit 1
    }

    # Delete volume replication
    display_message "Deleting replication in secondary volume..."
    {
        az netappfiles volume replication remove --ids $NEW_SECONDARY_VOLUME_ID
        sleep 60
        display_message "Sucessfully deleted replication in Secondary volume"
    } || {
        display_message "Failed to delete replication in Secondary volume"
        exit 1
    }
    
    # Delete Secondary ANF Resources
    # Delete Volume
    display_message "Deleting Azure NetApp Files Secondary Volume..."
    {
        az netappfiles volume delete --ids $NEW_SECONDARY_VOLUME_ID
        sleep 60 
        display_message "Azure NetApp Files volume was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files secondary volume"
        exit 1
    }

    #Delete Capacity Pool
    display_message "Deleting Azure NetApp Files secondary Pool ..."
    {
        az netappfiles pool delete --ids $NEW_SECONDARY_POOL_ID
        sleep 60    
        display_message "Azure NetApp Files secondary pool was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files secondary pool"
        exit 1
    }

    #Delete Account
    display_message "Deleting Azure NetApp Files secondary Account ..."
    {
        az netappfiles account delete --ids $NEW_SECONDARY_ACCOUNT_ID
        display_message "Azure NetApp Files secondary Account was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files secondary Account"
        exit 1
    }

     # Delete Primary ANF Resources
    # Delete Volume
    display_message "Deleting Azure NetApp Files Primary Volume..."
    {
        az netappfiles volume delete --ids $NEW_PRIMARY_VOLUME_ID
        sleep 60   
        display_message "Azure NetApp Files Primary volume was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files Primary volume"
        exit 1
    }

    #Delete Capacity Pool
    display_message "Deleting Azure NetApp Files Primary Pool ..."
    {
        az netappfiles pool delete --ids $NEW_PRIMARY_POOL_ID
        sleep 60   
        display_message "Azure NetApp Files Primary pool was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files Primary pool"
        exit 1
    }

    #Delete Account
    display_message "Deleting Azure NetApp Files Primary Account ..."
    {
        az netappfiles account delete --ids $NEW_PRIMARY_ACCOUNT_ID
        display_message "Azure NetApp Files Primary Account was deleted successfully"
    } || {
        display_message "Failed to delete Azure NetApp Files Primary Account"
        exit 1
    }

fi



