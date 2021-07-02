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
    downloads a file from a url
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



function check-versions {

    <#
    downloads a array of files from a url
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

    <#
    checking version of setup-file and installed version
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
        install-app_exe
    } else {
        "INFO: $app_name ist uptodate: $setup_version Skipping Update" >> $log_tempfile
    }
}


function install-app_exe {

    <#
    performing software installation of exe-file
    needs this functions:
        errorcheck
        check-versions (optional, see variable $setup_version)
    usage:
        declare outside this function:
            $app_name
            $deploypath
            $setupfile
            $setup_param
            $setup_version (optional, see function check-versions)
    #>

    $yeah = "OK: Installing $app_name $setup_version done successfully."
    $shit = "FAIL: Installing $app_name $setup_version failed"
    Start-Process $deploypath\$setupfile -Wait -ArgumentList $setup_param; errorcheck
}
