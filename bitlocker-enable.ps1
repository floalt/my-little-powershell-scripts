<#
description

    Checks the bitlocker state of local hard disk
    If it is not encrypted: encryption starts
    Saves key in Active Directory (depends on domain GPO)

author: flo.alt@fa-netz.de

#>

# Definitions & functions

    $logfile = "C:\Windows\Temp\bitlocker-enable.log"

    function start-logfile {
        "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $logfile
    }


# Checks the bitlocker state of local hard disk

    $encryptvolume = (Get-BitLockerVolume | Where-Object {$_.VolumeType -eq "OperatingSystem"})

    switch ($encryptvolume.VolumeStatus) {
        FullyEncrypted {
            start-logfile
            "INFO: Local Disk is already fully encrpyted. Doing nothing." >> $logfile
            break
        }
        EncryptionInProgress {
            start-logfile
            $percentage = ($encryptvolume.EncryptionPercentage)
            "INFO: Encryption is in progress: $percentage%" >> $logfile
            break
        }
        FullyDecrypted {
            if (test-path $logfile) {
                "INFO: Encryption is enabled, but waiting for reboot to start encrypting" >> $logfile
            }
            else {
                start-logfile
                "OK: Local Disk is NOT encrpyted. Enabling Bitlocker now..." >> $logfile
                $do_encrypt = "pending"
            }
            break
        }
        Default {
            start-logfile
            "FAIL: Something strange has happened. Cannot decide if it is a good idea to start encryption right now." >> $logfile
            break
        }
    }



# Starting to encrypt


    if ($do_encrypt -eq "pending") {
        
        # check if USB device is connected

        $check_usb = (GET-WMIOBJECT win32_diskdrive | where { $_.InterfaceType -eq "USB" })
        if ($check_usb) {
            "WARNING: There is a USB-Stick connected. I better do not enable Bitlocker" >> $logfile
            exit
        }

        # enable Bitlocker

        $yeah = "OK: Bitlocker is now enabled. Waiting for reboot to start encryption"
        $shit = "ERROR: Could not enable Bitlocker"
        $encryptvolume | Enable-BitLocker -EncryptionMethod Aes256 -RecoveryPasswordProtector

        # set marker for waiting-for-reboot

        "Waiting for reboot" >> $logfile
        
    }



