$DiskID = "StoreJet"
$DriveLetter = "V"

Clear-Variable -Name check
$check = Get-Partition | ? DriveLetter -eq $DriveLetter
if (!$check) {
    Get-Partition | Where-Object {($_.DiskId -like "*$DiskID*") -and ($_.Type -eq "Basic")} | Set-Partition -NewDriveLetter $DriveLetter
}