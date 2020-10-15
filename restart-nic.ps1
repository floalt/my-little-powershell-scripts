# Restart Network Device

param(
$nic = "Ethernet"
)

Restart-NetAdapter -Name $nic -Confirm:$false