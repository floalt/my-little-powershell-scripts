<#
    This is a very simple script test.
    If the script is running allright, there will be a file c:\yeah.txt
#>

$testfile = "C:\yeah.txt"

"$(Get-Date -Format yyyy-MM-dd_HH:mm:ss) - Alles ist Eins, ausser der Null" >>$testfile