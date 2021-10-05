###Import File Shares
## Fonctionne avec ExportFileShares.ps1
## Besoin de rehaussement

$PathToCsv = ""
$PathToErrorsCsv = ""



$Shares = Import-Csv $PathToCsv
$ExistingShares = Get-SmbShare

$Errors = @()


foreach ($s in $Shares) {
    if ($ExistingShares.Name -contains $s.Name) {
        Write-Error $s.Name + "Already exists"
    } else {
        try {
            $NewShare = New-SmbShare -Name $s.Name -Description $s.Description -Path $s.ConvertedPath
        } catch {
            $Error = [pscustomobject]@{
                $State = 'Failed'
                $ShareName = $s.Name
                $SharePath = $s.Path
                $Details = 'Failed to create share'
            }
            $Errors = $Errors + $Error
        }
        if ($NewShare) {
            foreach ($p in $s.Permissions.Full) {
                try {
                    $NewShare | Grant-SmbShareAccess -AccountName $p -AccessRight Full
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
            }
            foreach ($p in $s.Permissions.Change) {
                try {
                    $NewShare | Grant-SmbShareAccess -AccountName $p -AccessRight Change
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
            }

            foreach ($p in $s.Permissions.Read) {
                try {
                    $NewShare | Grant-SmbShareAccess -AccountName $p -AccessRight Read
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
            }
        
            foreach ($p in $s.PermissionsDeny.Full) {
                try {
                    $NewShare | Block-SmbShareAccess -AccountName $p
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
        
            }
            foreach ($p in $s.Permissions.Change) {
                try {
                    $NewShare | Block-SmbShareAccess -AccountName $p
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
        
            }
            foreach ($p in $s.Permissions.Read) {
                try {
                    $NewShare | Block-SmbShareAccess -AccountName $p
                } catch {
                    $Error = [pscustomobject]@{
                        $State = 'FailedPermApply'
                        $ShareName = $s.Name
                        $SharePath = $s.Path
                        $Details = ('Apply:'+$p)
                    }
                    $Errors = $Errors + $Error
                }
            }

        }

    }


}


Write-Host "Write the path for the error report"
$Errors | Export-Csv $ErrorsCsv -NoTypeInformation
