#Check In a bunch of file to sharepoint online


$Folders = Get-PnPFolderItem -FolderSiteRelativeUrl "Documents" -ItemType Folder
$Folders | ForEach-Object -Parallel {
    $Name = $_.Name
    $Files = Get-PnPFolderItem -FolderSiteRelativeUrl "Documents/$Name" -ItemType File
    $ctx = Get-PnPContext
    $Files | %{
        if ($_.CheckOutType -ne "None") {
            $Success = $False
            try {
                $ctx.Load($_)
                $ctx.ExecuteQuery()
                $_.CheckIn("", "MajorCheckIn")
                $ctx.ExecuteQuery()
                $Success = $true
            } 
            catch {
                Write-Host $_
                Start-Sleep -Seconds 240
                Write-Host "Finished Sleeping"
                $Success = $False
            }
            if ($Success -eq $True) {
                Write-Host "CheckedIn" $_.Name
            }
        } else {
            Write-Host "Already CheckedIn" $_.Name
        }
    }

} -ThrottleLimit 4
