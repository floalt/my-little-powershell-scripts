# define unwanted printers

    $PrintersToDelete = @(
        'Microsoft XPS Document Writer'
        'COMpact / COMmander Fax'
        'Fax'
        '*Briefpapier*'
    )



# make a nice funktion

    function remove-unwantedprinter {
        $queryprinter = Get-WMIObject -Class Win32_Printer | Where-Object {$_.name -like $printer}
            if ($queryprinter) {
                Remove-Printer -Name $printer
                write-host "Lösche Drucker $printer"

                $querydelete = Get-WMIObject -Class Win32_Printer | Where-Object {$_.name -eq $printer}
                if ($querydelete) {
                    write-host "FEHLER: Der Drucker $printer konnte nicht gelöscht werden" -F Red
                    $script:errorcount = $script:errorcount + 1
                } else {
                    write-host "OK: Der Drucker $printer wurde gelöscht" -F Green
                }

            } else {
                write-host "INFO: Der Drucker $printer ist nicht vorhanden" -F Yellow
        }
    }



# delete all unwanted printers

    foreach ($printer in $PrintersToDelete) {
        remove-unwantedprinter
    }