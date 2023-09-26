

# ------------------------- ERRORCHECK / LOGFILES / SCRIPTUPDATE ------------------------- #


function errorcheck {

    <#
    writing $yeah and $shit in logfile and counting errors
    needs this functions:
        start-logfile (for $log_tempfile)
        close-logfile
    usage:
        declare at the beginning of your script: $errorcount = 0
        set '-ErrorVariable errchk' to every cmdlet you want to errorcheck
        
        $yeah = "OK: everything went allright"
        $shit = "ERROR: this didnt work"
        [do someting complicated] -ErrorVariable errchk; errorcheck
    #>

    if (!$errchk) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
    }
}


function errorcheck {

    <#
    writing $yeah and $shit in standard output and counting errors

    usage:
        declare at the beginning of your script: $errorcount = 0
        set '-ErrorVariable errchk' to every cmdlet you want to errorcheck
        
        $yeah = "OK: everything went allright"
        $shit = "ERROR: this didnt work"
        [do someting complicated] -ErrorVariable errchk; errorcheck
    #>

    if (!$errchk) {
        write-host $yeah -F Green
    } else {
        write-host $shit -F Red
    }

    $errchk = $null
}


function failcheck {

    <#
    writing $yeah and $shit in logfile and breaks the script in case of error
    needs this functions:
        start-logfile (for $log_tempfile)
        close-logfile
    usage:
        declare at the beginning of your script: $errorcount = 0
        make a function 'fail-rollback' with steps to do at the end, e.g. disconnect smb share
        set '-ErrorVariable errchk' to every cmdlet you want to errorcheck
        
        $yeah = "OK: everything went allright"
        $shit = "FAIL: this didnt work"
        [do someting real important] -ErrorVariable errchk; failcheck
    #>

    if (!$errchk) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
        "FAIL: This is a fatal error. It is better to stop here!" >> $log_tempfile
        
        fail-rollback
        close-logfile
        exit 1
    }

    $errchk = $null
}


function start-logfile {

    <#
    starting a logifile in a central $logpath
    e.g. for deploying software via gpo
    if no errors, you get $log_okfile, otherwise $log_errorfile
    needs this functions:
        close-logfile
        errorcheck
    usage:
        call at the beginning of your script
        declare outside this function:
            $logpath = "\path\to\log\folder\"
            $logname = "what-i-do-here"
    #>

    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  "C:\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
    $script:log_errorfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}



function start-logfile {

    <#
    starting a logifile in a local $logpath
    if no errors, you get $log_okfile, otherwise $log_errorfile
    needs this functions:
        close-logfile
        errorcheck
    usage:
        call at the beginning of your script
        declare outside this function:
            $logpath = "\path\to\log\folder\"
            $logname = "what-i-do-here"
    #>

    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  $logpath + "\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "\" + $logname + "_ok" + ".log"
    $script:log_errorfile = $logpath + "\" + $logname + "_fail" + ".log"
    $script:log_today = $logpath + "\" + $logname + "-" + $(Get-Date -Format yyyyMMdd-HHmmss) + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}



function close-logfile {

    <#
    finnishing logfile
    if no errors, you get $log_okfile, otherwise $log_errorfile
    needs this functions:
        start-logfile
        errorcheck
    usage:
        call at the end of your script
        declare outside this function:
            $logpath = "\path\to\log\folder"
            $logname = "what-i-do-here"
    #>

    "End: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
    if ($log_today) {cp $log_tempfile $log_today}
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
    } else {
        mv $log_tempfile $log_errorfile -Force
    }
}


function remove-logfiles {

    <#
    deletes logfiles older then $logdays
    needs this functions:
        close-logfiles
    usage:
        call at the end of your script
        declare outside this function:
            $logdays = 21
    #>

    [int]$Daysback = "-" + $logdays

    $CurrentDate = Get-Date
    $DatetoDelete = $CurrentDate.AddDays($Daysback)
    Get-ChildItem $logpath | Where-Object { ($_.Extension -eq ".log") -and ($_.LastWriteTime -lt $DatetoDelete) } | Remove-Item

}



function start-scriptupdate {

    <#
    this is a update-myself function ;-)
    downloads the current script source from GitHub
    
    usage:
        call at the end of your script (before closing logfiles)
        declare outside this function:
            $scriptsrc = "https://raw.githubusercontent.com/full/path/to/the/script.ps1"
            $scriptpath = (Split-Path -parent $PSCommandPath)
            $scriptname = $MyInvocation.MyCommand.Name
            $scriptfullpath = $scriptpath + "\" + $scriptname
        declare in config-file (or within the script)
            $autoupdate = 1
    #>

    if ($autoupdate -eq 1) {
        $yeah="OK: Self-Update of this script successful"
        $shit="FAIL: Self-Update of this script failed"
        Invoke-WebRequest -Uri $scriptsrc -OutFile $scriptfullpath; errorcheck
    }
}





# ------------------------- Downlaods ------------------------- #



function dl-file {

    <#
    downloads a file from a url
    needs this function:
        errorcheck
    usage:
        declare outsite this script
            $dl_name = "This nice file"
            $url = "https://my.domain.org/file"
            $dl_folder = "path\to\download\folder"
    #>
        $yeah="OK: Downloading $dl_name successful"
        $shit="FAIL: Downloading $dl_name failed"
    Start-BitsTransfer $url $dl_folder; errorcheck
}



function dl-morefiles {

    <#
    downloads a array of files from a url
        uses Bits-Transfer
    needs this function:
        errorcheck
    usage:
        declare outsite this script
            $dl_files = @{
                @{name='My first file';url='https://my.domain.org/file1'}
                @{name='My second file';url='https://my.domain.org/file2'}
            }
            $dl_folder = "path\to\download\folder"
    #>

    foreach ($file in $dl_files) {
        $yeah="OK: Downloading $file.name successful"
        $shit="FAIL: Downloading $file.name failed"
        Start-BitsTransfer $file.url $dl_folder; errorcheck
        write-host $file.name
    }
}



function dl-morefiles {

    <#
    downloads a array of files from a url
        uses Invoke-WebRequest
    needs this function:
        errorcheck
    usage:
        declare outsite this script
            $dl_files = @{
                @{name='My first file';url='https://my.domain.org/file1';file = 'file1'}
                @{name='My second file';url='https://my.domain.org/file2';file = 'file2'}
            }
            $dl_folder = "path\to\download\folder"
    #>

    foreach ($element in $dl_files) {

        $output = $dl_folder + "\" + $element.file

        $yeah="OK: Downloading " + $element.name + " successful"
        $shit="FAIL: Downloading " + $element.name + " failed"
        Invoke-WebRequest $element.url -Outfile $output; errorcheck
    }
}





# ------------------------- delete files ------------------------- #


# Delete files out of array

$filestodelete = @(
    "$env:PUBLIC\Desktop\File1.lnk",
    "$env:PUBLIC\Desktop\Other File.lnk"
    )

function remove-files {
    foreach ($item in $filestodelete) {
        if (test-path $item) {rm $item}
    }
}


# Delete Files, keep newest (wenn Datum über den Dateinamen abgebildet wird)

$tidypath = C:\Path\To\Folder
$filter = "string*"
$keep = 4

function tidyup {

    $items = Get-ChildItem -Path $tidypath -Filter $filter | Sort-Object Name -Descending
    $counts = $items.Count

    $c = $counts - 1   # remember: arrays start at [0] and not at [1]
    $e = $keep - 1

    while ($c -gt $e) {
        Write-Host "Deleting:" $items[$c].FullName
        Remove-Item -Recurse $items[$c].FullName
        $c = $c -1
    }
}




# Delete Files, wenn size exceeded

$pathtofile = "C:\test\files\file.dat"
$size = 4       # [MB]

function tidyupsize {

    $item = Get-ChildItem -Path $pathtofile
    if ( $item.Length/1MB -gt $size ) {
        Remove-Item $pathtofile
        echo "Removing $pathtofile"
    } else {
        echo "nothing to do"
    }

}

# ------------------------- SMB-Shares ------------------------- #



function connect-smb {

    <#
        declare outside the function:
            $smb_lw = "T:"
            $smb_share = "\\server\share"
            $smb_user = "DOMAIN\user"
            $smb_pass = "mysecretpassword"
    #>

    if (!(test-path $smb_lw)) {
        $yeah = "OK: SMB share connected"
        $shit = "FAIL: Cannot connect to SMB Share"
        net use $smb_lw $smb_share /user:$smb_user $smb_pass; failcheck
    }
}


function disconnect-smb {

    $yeah = "OK: SMB share disconnected"
    $shit = "ERROR: Cannot disconnect SMB share"
    if (test-path $smb_lw) {net use $smb_lw /delete /yes; errorcheck}

}









# ------------------------- Install / Update / Check version ------------------------- #



function get-version-app {

    <#
    checking, if app is installed and what release version

    usage:
        declare outside this function:
            $search_name
        $installed_version = (get-version-app)
    #>
    
    # first check registry for 64bit software
        $version = (Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name*").DisplayVersion

    # then check registry for 32bit software
        if (!$version) {
            $version = (Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | ? DisplayName -like "*$search_name*").DisplayVersion
        }
    
    # last try this way:
        if (!$version) {
            $version = (Get-Package -Provider Programs | Where-Object {$_.Name -like "*$search_name*"}).Version
        }

    return $version
}



function convert-version ($version) {
    
    <#
    your version value may be 2.3.4.56789 as a string or version type
    this function converts to value 2.3.4 as a string
    
    needs this function:
        get-version-app (optinal)
        
    usage:
        $converted_version = (convert-version $original_version)[1]
        eg: $installed_version = (convert-version $installed_version)[1]
    #>

    if (($version.GetType()).Name -eq "String") {
        Write-Output "This is a string"
        $version_str = $version

    } elseif (($version.GetType()).Name -eq "Version") {
        Write-Output "This is a version, converting to string"
        $version_str = $version.ToString()

    } else {
        Write-Output "FAIL: This is not a string or a version"
    }

    $version_short = '{0}.{1}.{2}' -f $version_str.split('.')
        
    return $version_short
}



function compare-versions {

    <#
    compareing version of setup-file and installed version
    writes everything in logfile
    needs this functions:
        start-logfile
        close-logfile
    usage:
        declare outside this function:
            $app_name
    #>

    $script:setup_version = $null
    $script:installed_version = $null
    [version]$script:setup_version = (Get-ChildItem $deploypath\$setupfile).VersionInfo.ProductVersion
    "INFO: Version to install: $setup_version" >> $log_tempfile
    [version]$script:installed_version = (Get-Package -Provider Programs | Where-Object {$_.Name -like "$app_name*"}).Version
    "INFO: Installed version: $installed_version" >> $log_tempfile

    <#
    now you can do things like these:

        # check if $app_name is installed or not
            if ($installed_version -eq $null) {
                "INFO: $app_name not installed. Nothing to do." >> $log_tempfile
                sleep 1

            } else {
                [go on with your script]
                ...
            }

        # Install the Update, you need this function
            start-update
    #>
}


function start-update {

    <#
    tells you if update is available and installs the update
    needs this functions:
        check-versions
        install-app_exe
        errorcheck
        start-logfile
        close-logfile
    usage:
        declare outside this function:
            $app_name
            $deploypath
            $setupfile
            $setup_param (e.g. "/VERYSILENT")
    #>

    if ($installed_version -lt $setup_version) {
        "INFO: Update for $app_name available. Performing Update..." >> $log_tempfile
        install-app
    } else {
        "INFO: $app_name ist uptodate: $setup_version Skipping Update" >> $log_tempfile
    }
}


function install-app {

    <#
    performing software installation of exe or msi-files
    needs this functions:
        errorcheck
        compare-versions (optional, see variable $setup_version)
        errorcheck-app (optional, if you want to check if installation went all right)
    usage:
        declare outside this function:
            $app_name
            $deploypath
            $setup_file
            $setup_param_exe
            $setup_param_msi
            $setup_version (optional, see function check-versions)
            $setup = $deploypath + $setup_file
    #>
    
    "OK: Starting installation of $app_name..." >> $log_tempfile
    $ext = (Get-Item $setup).extension
        
    $yeah = "OK: Starting to install $app_name $setup_version successfully."
    $shit = "FAIL: Installing $app_name $setup_version failed"
    
    # installing exe file

    if ($ext -eq ".exe") {
        if ($setup_param_exe -eq "") {
            Start-Process $setup -Wait
            errorcheck
        } else {
            Start-Process $setup -Wait -ArgumentList $setup_param_exe
            errorcheck
        }

    # installing msi file
    
    } elseif ($ext -eq ".msi") {
        if ($setup_param_msi -eq "") {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup"
            errorcheck
        } else {
            Start-Process msiexec.exe -Wait -ArgumentList "/passive /i $setup $setup_param_msi"
            errorcheck
        }
    
    # fail if neither exe nor msi
    
    } else {
            "FAIL: setup file has no vaild extension (exe or msi)" >> $log_tempfile
            $script:errorcount = $script:errorcount + 1
        }
    
    errorcheck-app
}


function errorcheck-app {
    
    <#
    checks, if installation went all right
    by comparing $installed_version with $setup_version
    needs this function
        install-app
        get-version-app
    #>
    
    $installed_version = (get-version-app)
    
    if ($installed_version) {
        $installed_version = (convert-version $installed_version)[1]
    }

    if ($installed_version -eq $setup_version) {
        "OK: $app_name ver $setup_version is installed successfully." >> $log_tempfile
    } else {
        "FAIL: $app_name ver $setup_version could not be installed." >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
        $script:instfail = $script:instfail +1
    }
}


function Get-AppPath ($mysoftware) {

    <#
    description
        determinates the application path of an installed app (c:\programfiles...)
        outputs, if App is 32 or 64 bit or if not installed
        returns $mypath with full path in it

    usage:
        $mypath = Get-AppPath [NameOfTheApp]
    #>

    $check32 = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
    if (!$check32) {
        $check64 = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Where-Object {$_.DisplayName -like "*$mysoftware*"}
        if (!$check64) {
            Write-Host "INFO: $mysoftware is not installed" -F Red
        } else {
            Write-Host "OK: found $mysoftware 64-bit." -F Green
            $details = $check64
        }

    } else {
        Write-Host "OK: found $mysoftware 32-bit." -F Green
        $details = $check32
    }

    $mypath = $details.InstallLocation
    return $mypath
}








# ------------------------- Interactive Scripting ------------------------- #



function read-userinput {
    
    <#
    asking the user for a input (string)
    
    usage:
        declare outside that function:
            $question
            $repeat_question
    #>

    $script:user_input = Read-Host "$question"

    # check if input is empty
    if (!$user_input) {
        Write-Host "$repeat_question" -ForegroundColor Red
        read-userinput
    }
}



function ask-yesno ([string]$question) {

    <#
    asking user yes or no question
    yes is default answer
    
    usage:
        $question = "Should I stay or should I go now?"
        ask-yesno $question
            
    #>
    
    letsdoit = Read-Host $question [J/n]
    if (($letsdoit -eq "j") -or (!$letsdoit)) {
        $script:doit = 1
        $script:question = $null
    } elseif ($letsdoit -eq "n") {
        $script:doit = 0
        $script:question = $null
    } else {
        Write-Host "Bitte 'j' oder 'n' eingeben (Enter für Ja)" -F Red
        ask-adduser
    }
}



function press-anykey-to-close {

    <#
    asks the user to press any key to close the window / script
    #>
    
    Read-Host "
    ENDE: Drücke die Entertaste, um das Fenster zu schließen."
    exit

}





