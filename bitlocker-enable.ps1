<#
description

    Checks the bitlocker state of local hard disk
    If it is not encrypted: encryption starts
    Saves key in Active Directory

author: flo.alt@fa-netz.de

#>

# ------------------------ FUNCTIONS ------------------------ #

function errorcheck {

    <#
    writing $yeah and $shit in standard output and counting errors

    usage:
        declare at the beginning of your script: $errorcount = 0
        set '-ErrorVariable errchk' to every cmdlet you want to errorcheck
        $yeah = "OK: everything went allright"
        $shit = "ERROR: this didnt work"
        [do someting complicated]; errorcheck
    #>

    if (!$errchk) {
        write-host $yeah -F Green
    } else {
        write-host $shit -F Red
    }

    $errchk = $null
}





# ------------------------ Here is the Script ------------------------ #


# Checks the bitlocker state of local hard disk

    $encryptvolume = (Get-BitLockerVolume | Where-Object {$_.VolumeType -eq "OperatingSystem"})

    switch ($encryptvolume.VolumeStatus) {
        FullyEncrypted {
            write-host "INFO: Local Disk is already fully encrpyted. Doing nothing."
            break
        }
        EncryptionInProgress {
            $percentage = ($encryptvolume.EncryptionPercentage)
            write-host "INFO: Encryption is in progress: $percentage%"
            break
        }
        FullyDecrypted {
            write-host "OK: Local Disk is NOT encrpyted. Enabling Bitlocker now..."
            $do_encrypt = "pending"
            break
        }
        Default {
            Write-Host "FAIL: Something strange has happened. Cannot decide if it is a good idea to start encryption right now."
            break
        }
    }



# Starting to encrypt


    if ($do_encrypt -eq "pending") {
        
        # check if USB device is connected

        $check_usb = (GET-WMIOBJECT win32_diskdrive | where { $_.InterfaceType -eq "USB" })
        if ($check_usb) {
            write-host "WARNING: There is a USB-Stick connected. I better do not enable Bitlocker"
            exit
        }

        # enable Bitlocker

        $yeah = "OK: Bitlocker is now enabled. Waiting for reboot to start encryption"
        $shit = "ERROR: Could not enable Bitlocker"
        $encryptvolume | Enable-BitLocker -EncryptionMethod Aes256 -RecoveryPasswordProtector -ErrorVariable errchk; errorcheck
        
    }



