<#
 .SYNOPSIS
    Deploys a network, NIC, NSG, Public IP address, storage account and a VM

 .DESCRIPTION
    ParentTemplate calls linked templates

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Path to the template file. Defaults to template.json.

.OUTPUTS
  None

.NOTES
  Version:        1.3
  Author:         Jon Kidd
  Creation Date:  31.05.19
  Purpose/Change:
  Very rough and ready linked template deployment from parentTemplate.json.
  Needs running a few times to allow for resources to be built.
  No reference or depends actions 
  
.EXAMPLE
.\LinkedARM-1.3.ps1 -resourceGroupName:"Linked-ARM-1.2" -ame:"LinkedARMDeployment" -Verbose -subscriptionId:############## -resourceGroupLocation:uksouth -templateFilePath: ".\ParentTemplate.json"

#>

[CmdletBinding()]
param(
 [Parameter(Mandatory=$true)]
 [string]$subscriptionId,
 [Parameter(Mandatory=$True)]
 [string]$resourceGroupName,
 [Parameter(Mandatory=$True)]
 [string]$resourceGroupLocation,
 [Parameter(Mandatory=$True)]
 [string]$deploymentName,
 [Parameter(Mandatory=$True)]
 [string]$templateFilePath
)

<#
.SYNOPSIS
    Registers RPs
#>
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Output "Registering resource provider '$ResourceProviderNamespace'"
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace
}

#******************************************************************************
# Script body
# Execution begins here
#******************************************************************************
$ErrorActionPreference = "Stop"

# sign in
Write-Output "Logging in..."
Login-AzureRmAccount

# select subscription
Write-Output "Selecting subscription '$subscriptionId'"
Select-AzureRmSubscription -SubscriptionID $subscriptionId

# Register RPs
$resourceProviders = @("microsoft.network")
if($resourceProviders.length) {
    Write-Output "Registering resource providers"
    foreach($resourceProvider in $resourceProviders) {
        RegisterRP($resourceProvider)
    }
}

#Create or check for existing resource group
$resourceGroup = Get-AzureRmResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
if($resourceGroup)
{
    Write-Output "Found resource group $resourceGroupName"
    #Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Force
}else{
    Write-Output "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'"
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}

# Start the deployment
Write-Output "Starting deployment..."
if(Test-Path $templateFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath
}