<#
 .SYNOPSIS
    Deploys a template to Azure

 .DESCRIPTION
    Deploys an Azure Resource Manager template

 .PARAMETER subscriptionId
    The subscription id where the template will be deployed.

 .PARAMETER resourceGroupName
    The resource group where the template will be deployed. Can be the name of an existing or a new resource group.

 .PARAMETER resourceGroupLocation
    Optional, a resource group location. If specified, will try to create a new resource group in this location. If not specified, assumes resource group is existing.

 .PARAMETER deploymentName
    The deployment name.

 .PARAMETER templateFilePath
    Optional, path to the template file. Defaults to template.json.

 .PARAMETER parametersFilePath
    Optional, path to the parameters file. Defaults to parameters.json. If file is not found, will prompt for parameter values based on template.
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
    Write-Output "Deleting resource group $resourceGroupName"
    Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Force
}

Write-Output "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'"
New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation

# Start the deployment
Write-Output "Starting deployment..."
if(Test-Path $templateFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath
}