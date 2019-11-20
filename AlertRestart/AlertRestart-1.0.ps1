param
(
    [Parameter (Mandatory=$false)]
    [object] $WebhookData
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


Write-Output "Running anyway :o)"
Write-Output $WebhookData
#$WebhookData = $using:WebhookData		
$ErrorActionPreference = "stop"

if ($WebhookData){
    $a = (ConvertFrom-Json -InputObject $WebhookData.RequestBody)
    #Write-Output $a
    #Write-Output $a.SchemaId
    #Write-Output ($a | Get-Member)
    #Write-Output "Converted"
    #Write-Output $a.SearchResults.tables
    #Write-Output "Table"
    #Write-Output $a.data.SearchResults.tables.columns
    #Write-Output "Columns"
    #Write-Output $a.SearchResults.tables.rows
    #Write-Output $a

    $cols = @($a.data.SearchResults.tables[0].columns)
    Write-Output "Cols $cols"
    #Write-Output $a.SearchResults.tables.rows
    #Write-Output $a.SearchResults.tables.rows.Length

    for ($z = 0; $z -lt $a.data.SearchResults.tables[0].rows.Length; $z++)    
    {
        Write-Output "in Z Loop"
        Write-Output $z
        $vmInfo = @($a.data.SearchResults.tables[0].rows[$z])
        $colCount = 0
        foreach ($col in $cols){
            Write-Output $col
            if ($col.name -eq 'Computer'){
                $vmToReboot = $vmInfo[$colCount]            
            }
            if ($col.name -eq 'ResourceGroup'){
                $resGroup = $vmInfo[$colCount]            
            }        
            $colCount ++
        }
        Write-Output $vmToReboot
        Write-Output $resGroup
        restartVirtual $vmToReboot $resGroup
    }
}



