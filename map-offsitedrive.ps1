$nas = "192.168.22.240"
$shares = @(
    'veeam-offsite-1',
    'veeam-offsite-2'
    )
$drive = "O"


$lw = $drive + ":"

# disconnect mapped share

    $checkdrive = Get-PSDrive | where { $_.Name -eq $drive }
    if ($checkdrive) {net use $lw /delete /yes}
        
# looking for the available share (only one of the shares is available)

    foreach($share in $shares) {

        $check = Get-ChildItem \\$nas\$share

        if ($check) {
            $unc = "\\$nas\$share"
            }
        }


# map the share to a drive
    
    net use $lw $unc