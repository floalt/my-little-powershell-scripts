# Auto-Mapping für Admin in Outlook deaktivieren
# author: flo.alt@fa-netz.de
# Ver 0.8

# Verwendung: .\del-mapping [Mailalias]

param(
[string]$mailbox
)

Remove-MailboxPermission -Identity $mailbox -User admin -AccessRights FullAccess -Confirm:$false
Add-MailboxPermission -Identity $mailbox -User admin -AccessRights FullAccess -AutoMapping:$false
