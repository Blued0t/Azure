param
(
    [Parameter (Mandatory=$false)]
    [object] $webhookData
)

function restartVirtual {
    param (
        [Parameter(Mandatory=$true)]
        [String] $vmToRestart,
        [Parameter(Mandatory=$true)]
        [String] $resourceGroup
    )

    
    Write-Output "In Function"
    Write-Output $vmToRestart

    $Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Connect-AzureRmAccount -ServicePrincipal -Tenant $Conn.TenantID -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint | Out-Null
    Restart-AzVM -ResourceGroupName $resourceGroup -Name $vmToRestart    
}

Write-Output $PSEdition

#Write-Output $webhookData

$vms = (ConvertFrom-Json -InputObject $webhookData.RequestBody)

ForEach ($vm in $vms)
{
    $vmName = $vm.Name
    $rg = $VM.ResourceGroup
    Write-Output "$rg $vmName"
}


#Called by
#
# $bodyParams = @( @{ Name = "vm1"; ResourceGroup="uniweb-dev"} )
# $body = ConvertTo-Json -InputObject $bodyParams
# Invoke-WebRequest -uri https://s12events.azure-automation.net/webhooks?token=5hvvwCbNpOfac1cXJFnvQYP8AKu%2bZYNkRC%2fvN%2fRwWOs%3d -Method POST -Body $body