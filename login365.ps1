# Verbindung mit Office365 herstellen

$LiveCred = Get-Credential    # hier Anmeldedaten vom Office365-Admin in PopUp-Fenster eingeben
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://ps.outlook.com/powershell/ -Credential $LiveCred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService –Credential $LiveCred
