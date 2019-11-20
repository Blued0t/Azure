param
(
    [Parameter (Mandatory=$false)]
    [object] $webhookData
)

Write-Output $webhookData

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