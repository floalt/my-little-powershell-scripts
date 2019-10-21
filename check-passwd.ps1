# Passwort-Informationen anzeigen lassen
# author: flo.alt@fa-netz.de
# Ver 0.8

# Verwendung: .\check-passwd [Mailadresse]

param(
[string]$mailadress
)

get-MsolUser -UserPrincipalName $mailadress | fl LastPasswordChangeTimestamp , PasswordNeverExpires
