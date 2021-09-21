## This exports license count by domains

Connect-MsolService

$Users = Get-MsolUser -All | Where {$_.isLicensed -eq $True}
$Domains = Get-MsolDomain
$LicenseSummary = @()


foreach ($d in $Domains) {
    $DomainSummary = @()

    $domainFilter = '*@' + $d.name
    $Users = Get-MSolUser -All | Where {($_.isLicensed -eq $true) -and ($_.UserPrincipalName -like $domainFilter)}
    foreach ($u in $Users) {
        $licenses = @()
        foreach ($l in $u.Licenses) {
            $lic = $l.AccountSkuId.ToString()
            $lic = $lic.Replace("reseller-account:", '')

            $licenses = $licenses + $lic

            if ($DomainSummary.LicenseName -notcontains $lic) {


                $DomainSummary = $DomainSummary + [pscustomobject]@{
                    LicenseName =  $lic
                    Count = 1
                }
            } else {
                $DomainSummary | ?{$_.LicenseName -eq $lic} | %{$_.Count++}
            
            }

        }
    
    }
    $sum = [pscustomobject]@{
        Domain=$d.Name
        AAD_PREMIUM_P2=0
        O365_BUSINESS_PREMIUM=0
        O365_BUSINESS_ESSENTIALS=0
        FLOW_FREE=0
        EXCHANGESTANDARD=0
    }
    foreach ($l in $DomainSummary) {
        if ([bool]($sum.PSobject.Properties.name -match $l.LicenseName)) {
            $lName = $l.LicenseName
            $sum.$lName = $l.Count
        } else {
            $sum | Add-Member -NotePropertyName $l.LicenseName -NotePropertyValue $l.Count
        }
    
    }

    $LicenseSummary = $LicenseSummary + $sum

}


function Save-File()
{

    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null

    $OpenFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $OpenFileDialog.initialDirectory = $env:USERPROFILE
    $OpenFileDialog.filter = "CSV File | *.csv"
    $OpenFileDialog.ShowDialog() |  Out-Null

    return $OpenFileDialog.filename
} 


$FilePath = Save-File

$LicenseSummary | Select -Property * | Export-Csv -NoTypeInformation -Path $FilePath
