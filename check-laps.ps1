<#
    description:  This script retrieves information about computers in the Windows domain that have applied the LAPS policy.
        It collects LAPS information for each computer and outputs a table with computer information.
        Optionally, the "-AsPlainText" switch can be used to display passwords in plaintext.

        usage: .\script.ps1 [-AsPlainText]
        author: flo.alt@fa-netz.
    
    https://github.com/floalt
    version: 0.6

#>