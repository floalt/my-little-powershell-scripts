<#

    Starting OpenVPN Service only when not in company lan

    author: flo.alt@fa-netz.de
    https://github.com/floalt/gpo-scripts
    version: 0.6

#>

# Settings

    $logfile = "c:\scripts\checklog.txt"
    $lan = "192.168.123."

# start the party

    Set-Content $logfile "Starting the script..."

# check if you are in local network

    $addresses = (Get-NetIPAddress -AddressFamily IPv4).IPAddress
    if ($addresses -match $lan) {
        # do nothing but a log entry
        Add-Content $logfile "you are in local network"
    } else {
        # start OpenVPN
        Add-Content $logfile "startin openVpn"
        Start-Service OpenVPNService | Add-Content $logfile
    }