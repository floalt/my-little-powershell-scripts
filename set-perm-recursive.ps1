# Rekursive Berechtigungen in Shared Mailboxes ändern
# author: flo.alt@fa-netz.de
# Ver 0.8
 
# Verwendung: .\set-perm-recursive -mailbox [MailboxName] -usr [User|Group] -folder ["/Foldername"] -perm [AccessRight]
# Beispiel: .\set-perm-recursive -mailbox teampostfach -usr sg-team-s -folder "/Ordner/Unter Ordner" -perm PublishingEditor

param(
[string]$mailbox,
[string]$usr,
[string]$folder,
[string]$perm
)

ForEach($f in (Get-MailboxFolderStatistics $mailbox | 
Where {$_.FolderPath.Contains($folder) -eq $True } ) ) `
{$fname = $mailbox +":" + $f.FolderPath.Replace("/","\").Replace([char]63743,"/");`
Set-MailboxFolderPermission $fname -User $usr -AccessRights $perm }