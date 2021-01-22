# Wartungsscript für UC Server
# author: flo.alt@fa-netz.de
# Ver 0.6

$service = "PBX Call Assist"

$delpath = "C:\Program Files\Auerswald\UCServer\logs"
$Daysback = "-21"


# Logfiles löschen, älter als $daysback

$CurrentDate = Get-Date
$DatetoDelete = $CurrentDate.AddDays($Daysback)
Get-ChildItem $delpath | Where-Object { $_.LastWriteTime -lt $DatetoDelete } | Remove-Item


# Dienst neu starten
Get-Service -DisplayName "*$service*" | Restart-Service