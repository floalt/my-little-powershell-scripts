# Grundsätzliche Berechtigungen für eine neue Shared Mailbox
# author: flo.alt@fa-netz.de
# Ver 0.8
 
# Verwendung: .\make-perms -mailbox [MailboxName] -suser [Schreib-Gruppe] -luser [Lese-Gruppe]
# Beispiel: .\make-perms -mailbox einkauf -suser sg-einkauf-s -luser sg-einkauf-l

param([string]$mailbox,[string]$suser,[string]$luser)# Sprache der Ordnernamen:Set-MailboxRegionalConfiguration $mailbox -Language de-DE -LocalizeDefaultFolderName
# Hier werden die Schreibrechte festgelegt
Add-MailboxFolderPermission -Identity $mailbox -User $suser -AccessRights PublishingEditor -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Posteingang" -User $suser -AccessRights PublishingEditor -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Gesendete Elemente" -User $suser -AccessRights PublishingEditor -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Gelöschte Elemente" -User $suser -AccessRights PublishingEditor -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Junk-E-Mail" -User $suser -AccessRights PublishingEditor -Confirm:$False
# Hier werden die Leserechte festgelegt
Add-MailboxFolderPermission -Identity $mailbox -User $luser -AccessRights Reviewer -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Posteingang" -User $luser -AccessRights Reviewer -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Gesendete Elemente" -User $luser -AccessRights Reviewer -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Gelöschte Elemente" -User $luser -AccessRights Reviewer -Confirm:$FalseAdd-MailboxFolderPermission -Identity $mailbox":\Junk-E-Mail" -User $luser -AccessRights Reviewer -Confirm:$False
# Hier Senderechte für suser vergeben
Add-RecipientPermission -Identity $mailbox -AccessRights SendAs -Trustee $suser -Confirm:$False
