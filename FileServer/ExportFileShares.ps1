## Script pour exporté les permssions/shares d'un serveur.
## Fonctionne avec ImportFileShares.ps1

## Liste de disques originals ici, à modifié bien sur


$OriginalDrives = @('C:\', 'D:\', 'F:\')
$TargetDrives = @(
    [pscustomobject]@{
        Original = 'C:\'
        Target = 'D:\'
    },
    [pscustomobject]@{
        Original = 'D:\'
        Target = 'D:\'
    },
    [pscustomobject]@{
        Original = 'F:\'
        Target = 'D:\'
    }
)







###Rien Modifié ici


$Shares = Get-SmbShare | Where {($_.Name -notlike 'ADMIN$') -or ($_.Name -notlike 'IPC$') -or ($_.Name -notlike 'C$')}
$SharePermMap = @()

foreach ($s in $Shares) {
    $ShareObject = [pscustomobject]@{
        ConvertedPath = ''
        PermissionsAllow = [pscustomobject]@{
            Full = @()
            Change = @()
            Read = @()
        }
        PermisisonsDeny = [pscustomobject]@{
            Full = @()
            Change = @()
            Read = @()
        }
    }

    foreach ($d in $OriginalDrives) {
        if ($s.Path -like ($d + '*')) {
            $ShareObject.ConvertedPath = $s.Path.Replace($d, ($TargetDrives | Where {$_.Original -eq $d}).Target)
        }
    }

    $Perm = $s | Get-SmbShareAccess 
    
    foreach ($p in $Perm) {
        if ($p.AccessControlType -eq 'Allow') {
            $PermType = [string]$p.AccessRight
            $ShareObject.PermissionsAllow.$PermType = $ShareObject.PermissionsAllow.$PermType + [string]$p.AccountName
        } elseif ($p.AccessControlType -eq 'Deny') {
            $PermType = [string]$p.AccessRight
            $ShareObject.PermissionsDeny.$PermType = $ShareObject.PermissionsDeny.$PermType + [string]$p.AccountName
        } else {
            Write-Error 'Unhandled Access Control Type: ' + $PermType + ' for user: ' + $p.AccountName + ' on share ' + $s.Name
        
        }
    }


    $FinalObject = [pscustomobject]@{
        Name = $s.Name
        Description = $s.Description
        OriginalPath = $s.Path
        ConvertedPath = $ShareObject.ConvertedPath
        Permissions = [pscustomobject]@{
            Full = ($ShareObject.PermissionsAllow.Full -join ',')
            Change = ($ShareObject.PermissionsAllow.Change -join ',')
            Read = ($ShareObject.PermissionsAllow.Read -join ',')
        }
        PermissionsDeny = [pscustomobject]@{
            Full = ($ShareObject.PermissionsDeny.Full -join ',')
            Change = ($ShareObject.PermissionsDeny.Change -join ',')
            Read = ($ShareObject.PermissionsDeny.Read -join ',')
        }
    }

    $SharePermMap = $SharePermMap + $FinalObject

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

$SharePermMap | Select -Property * | Export-Csv -NoTypeInformation -Path $FilePath
