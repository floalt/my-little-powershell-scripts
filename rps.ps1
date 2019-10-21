# Connect to a remote server via PowerShell Enter-PSSession
# author: flo.alt@fa-netz.de
# ver: 0.6

# set default values here

param(
$defhost = "serv12-dc",     # default remote host name
$defuser = "Administrator"  # default remote user name
)

echo "Connecting to remote Server Enter-PSSession"

# read values from user interface

$remhost = Read-Host "remote server name (default: serv12-dc)"
$remdomain = Read-Host "domain (without postfix)"
$remuser = Read-Host "user (default: Administrator)"

if ($remhost -eq $null) {$remhost = $defhost}
if ($remhost -eq "") {$remhost = $defhost}
if ($remuser -eq $null) {$remuser = $defuser}
if ($remuser -eq "") {$remuser = $defuser}

$fqdn = $remhost + "." + $remdomain + "." + "local" 
$fulluser = $remdomain + "\" + $remuser

# connect to remote host

echo "Connectiong to $fqdn as $fulluser"

Enter-PSSession -ComputerName $fqdn -Credential $fulluser