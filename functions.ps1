

# ------------------------- BASIC FUNCTIONS ------------------------- #


function errorcheck {

    <#
    writing $yeah and $shit in logfile counts errors
    needs this functions:
        start-logfile (for $log_tempfile)
        end-logfile
    usage:
        declare at the beginning of your script: $errorcount = 0
        $yeah = "OK: everything went allright"
        $shit = "FAIL: this didnt work"
        [do someting complicated]; errorcheck
    #>

    if ($?) {
        $yeah >> $log_tempfile
    } else {
        $shit >> $log_tempfile
        $script:errorcount = $script:errorcount + 1
    }
}



function start-logfile {

    <#
    starting a logifile in a central $logpath
    e.g. for deploying software via gpo
    if no errors, you get $log_okfile, otherwise $log_errorfile
    needs this functions:
        end-logfile
        errorcheck
    usage:
        call at the beginning of your script
        declare outside this function:
            $logpath = "\path\to\log\folder"
            $logname = "what-i-do-here"
    #>

    if (!(test-path $logpath)) {mkdir $logpath}
    $script:log_tempfile =  "C:\" + $logname + "_log_tempfile" + ".log"
    $script:log_okfile = $logpath + "ok_" + $env:COMPUTERNAME + ".log"
    $script:log_errorfile = $logpath + "fail_" + $env:COMPUTERNAME + ".log"
    "Beginning: $(Get-Date -Format yyyy-MM-dd_HH:mm:ss)" >> $log_tempfile
}



function end-logfile {

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
    if ($errorcount -eq 0) {
        mv $log_tempfile $log_okfile -Force
    } else {
        mv $log_tempfile $log_errorfile -Force
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



# ------------------------- delete files ------------------------- #


$filestodelete = @(
    "$env:PUBLIC\Desktop\File1.lnk",
    "$env:PUBLIC\Desktop\Other File.lnk"
    )

function delete-files {
    foreach ($item in $filestodelete) {
        if (test-path $item) {rm $item}
    }
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
            $version = (Get-Package -Provider Programs | where {$_.Name -like "*$search_name*"}).Version
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
        echo "This is a string"
        $version_str = $version

    } elseif (($version.GetType()).Name -eq "Version") {
        echo "This is a version, converting to string"
        $version_str = $version.ToString()

    } else {
        echo "FAIL: This is not a string or a version"
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
        end-logfile
    usage:
        declare outside this function:
            $app_name
    #>

    $script:setup_version = $null
    $script:installed_version = $null
    [version]$script:setup_version = (Get-ChildItem $deploypath\$setupfile).VersionInfo.ProductVersion
    "INFO: Version to install: $setup_version" >> $log_tempfile
    [version]$script:installed_version = (Get-Package -Provider Programs | where {$_.Name -like "$app_name*"}).Version
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
            do-update
    #>
}


function do-update {

    <#
    tells you if update is available and installs the update
    needs this functions:
        check-versions
        install-app_exe
        errorcheck
        start-logfile
        end-logfile
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
            $setup = $deploypath + $setupfile
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
            Start-Process msiexec.exe -Wait -ArgumentList "/i $setup"
            errorcheck
        } else {
            Start-Process msiexec.exe -Wait -ArgumentList "/i $setup $setup_param_msi"
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
    
    function shutup {
    Read-Host "
    ENDE: Drücke die Entertaste, um das Fenster zu schließen."
    exit
}





