<#
 .SYNOPSIS
    Deploys a Network, NIC, Public IP address, storage account and a VM

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
  Version:        1.4
  Author:         Jon Kidd
  Creation Date:  11.06.19
  Purpose/Change:
  Linked template deployment from parentTemplate.json.
  Template dependencies use references (so waits until child deployments are complete)
  Further enhancements to follow in future releases
    Option to create multiple VM's
    Option to deploy Dev or Prod
    Windows PowerShell extensions deployed once VM's are built
    Custom PowerShell script will run on each VM
  
.EXAMPLE
.\LinkedARM-1.4.ps1 -resourceGroupName:"Linked-ARM-1.4" -name:"LinkedARMDeployment" -Verbose -subscriptionId:############## -resourceGroupLocation:uksouth -templateFilePath: ".\ParentTemplate.json"

#>

#---------------------------------------------------------[Initialisations]--------------------------------------------------------
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
 [string]$templateFilePath,
 [Parameter(Mandatory=$False)]
 [switch]$FreshDeployment,
 [Parameter(Mandatory=$False)]
 [int]$VMs = 1
)

#----------------------------------------------------------[Declarations]----------------------------------------------------------
[int]$VMs


#-----------------------------------------------------------[Functions]------------------------------------------------------------
Function RegisterRP {
    Param(
        [string]$ResourceProviderNamespace
    )

    Write-Output "Registering resource provider '$ResourceProviderNamespace'"
    Register-AzureRmResourceProvider -ProviderNamespace $ResourceProviderNamespace
}

#-----------------------------------------------------------[Execution]------------------------------------------------------------
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
    if ($FreshDeployment)
    {
        Write-Output "Removing $resourceGroupName"
        Remove-AzureRmResourceGroup -ResourceGroupName $resourceGroupName -Force
        Write-Output "Removed $resourceGroupName"
        Write-Output "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'"
        New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
    }
}else{
    Write-Output "Creating resource group '$resourceGroupName' in location '$resourceGroupLocation'"
    New-AzureRmResourceGroup -Name $resourceGroupName -Location $resourceGroupLocation
}

#Check for number of VMs to be built
if ($VMs)
{

}

# Start the deployment
Write-Output "Starting deployment..."
if(Test-Path $templateFilePath) {
    New-AzureRmResourceGroupDeployment -ResourceGroupName $resourceGroupName -Name $deploymentName -TemplateFile $templateFilePath -VMs $VMs
}