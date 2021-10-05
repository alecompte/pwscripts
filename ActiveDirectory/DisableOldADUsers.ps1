$Days = 365

$Users = Get-AdUser -Filter * -Properties LastLogonDate

foreach ($u in $Users) {
    
    if (!$u.LastLogonDate) {
        Write-Host $u.Name "Has never logged in"
        Disable-AdAccount -Identity $u.DistinguishedName   
    } elseif ((New-TimeSpan -Start ($u.LastLogonDate) -End (Get-Date)).Days -ge $Days) {
    
        Write-Host $u.Name "Last Logon Greater than 365 days"
        Disable-AdAccount -Identity $u.DistinguishedName   
    }

}