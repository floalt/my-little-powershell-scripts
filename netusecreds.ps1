﻿<#
description:

    this script adds login credentials in local store

    You have to do this:
    - make a GPO that maps the desired network drive
    - Add to this GPO the option to set a RUN-Value in registry
    (only if $env:APPDATA\atriumcreds doesnt exists)
    This RUN-Value will start this script. Include the parameters within the RUN-Value.

    And thats how it runs:
    1. The RUN-Value starts this script on Logon
    2. The file $env:APPDATA\netusecreds is created
    3. THE RUN-Value will be deleted
    4. On next User Logon, the GPO mapping the network drive will be working

author: flo.alt@fa-netz.de

#>

param(
    $server,
    $user,
    $pass
)

$check = (cmdkey /list | Where-Object {$_ -like "*target=$server*"})

if (!$check) {
    cmdkey /add:$server /user:$user /pass:$pass
    Write-Host > $env:APPDATA\netusecreds
    reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v netusecreds /f
} else {
    reg delete HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run /v netusecreds /f
}