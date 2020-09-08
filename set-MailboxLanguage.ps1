# Parameter

param(
[string]$mailbox
)

# Check Usage

if ($mailbox -eq "") { Write-Host "

    Stellt die Ordnersprache von Office365-Postfächern auf 'deutsch' um.

    Verwendung: ./set-MailboxLanguage -mailbox <mailbox>

"
exit 0
}

echo "Mailbox: $mailbox"

# Verbindung mit Office365 herstellen

$LiveCred = Get-Credential    # hier Anmeldedaten vom Office365-Admin in PopUp-Fenster eingeben
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService –Credential $LiveCred

# Ordnersprache ändern

Set-MailboxRegionalConfiguration $mailbox -Language de-DE -LocalizeDefaultFolderName
Get-MailboxRegionalConfiguration $mailbox