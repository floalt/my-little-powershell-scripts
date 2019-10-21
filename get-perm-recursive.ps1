# Rekursive Berechtigungen für einen bestimmten Benutzer in Shared Mailboxes anzeigen
# author: flo.alt@fa-netz.de
# Ver 0.8
 
# Verwendung: .\get-perm-recursive -mailbox [MailboxName] -usr [User|Group] -folder ["/Foldername"]
# Beispiel: .\set-perm-recursive -mailbox teampostfach -usr sg-team-s -folder "/Ordner/Unter Ordner"

param(
[string]$mailbox,
[string]$usr,
[string]$folder
)

ForEach($f in (Get-MailboxFolderStatistics $mailbox | 
Where {$_.FolderPath.Contains($folder) -eq $True } ) ) `
{$fname = $mailbox +":" + $f.FolderPath.Replace("/","\").Replace([char]63743,"/");`
Get-MailboxFolderPermission $fname -User $usr }