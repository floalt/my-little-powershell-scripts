$nas = "192.168.22.240"
$shares = @(
    'veeam-offsite-1',
    'veeam-offsite-2'
    )
$link = "c:\offsite"


# looking for the available share (only one of the shares is available)

    foreach($share in $shares) {

        $check = Get-ChildItem \\$nas\$share

        if ($check) {
            $unc = "\\$nas\$share"
            }
        }


# create or update a symbolic link
    
    New-Item -ItemType SymbolicLink -Path $link -Target $unc -Force
