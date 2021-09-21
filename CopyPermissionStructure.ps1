$New = "" #New Path
$Old = "" # Old Path
$Srip = "" # What to strip


function AutoAcl {
    param (
        [string]$Path,
        [int]$Depth
    )

    if ($Path -like '*$RECYCLE.BIN*') {
        Write-Host "Path contains Recycle, skipping"
        return
    }

    $Childs = Get-ChildItem -Directory -Path $Path

    $i = 0
    foreach ($c in $Childs) {
        $i = $i + 1
        $NewPath = $c.FullName.Replace($strip, $new)
        Write-Progress -Id $Depth -Activity "Scanning $NewPath, current depth $Depth" -PercentComplete ($i/$Childs.Count*100) -ParentId ($Depth-1)
        #Write-Host "Writing ACL for $NewPath"
        if ((Get-Acl -Path $c.FullName).Sddl -ne (Get-Acl -Path $NewPath).Sddl) {
            Get-Acl -Path $c.FullName | Set-Acl -Path $NewPath
            Write-Error -Message "Permissions that don't match found at $NewPath"
        }
        AutoAcl -Path $NewPath -Depth ($Depth+1)
     
    }
}

AutoAcl -Path $Old -Depth 0
