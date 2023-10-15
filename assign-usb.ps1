$DiskID = "StoreJet"
$DriveLetter = "V"

Clear-Variable -Name check
$check = Get-Partition | ? DriveLetter -eq $DriveLetter
if (!$check) {
    Get-Partition | ? DiskId -like "*$DiskID*" | Set-Partition -NewDriveLetter $DriveLetter
}