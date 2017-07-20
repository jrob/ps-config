param(
    [string]
    $BackupCsv = "backups.csv",

    [string]
    [ValidateSet("Backup","Restore")]
    $Action = "Backup",

    [switch]
    $ScheduleTask=$false,

    [switch]
    $WhatIf=$false,

    [switch]
    $Force=$false,

    [string]
    $Type = "*"

)

if ($ScheduleTask.IsPresent)
{
    $actions = @(
        New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NonInteractive -NoProfile -File ""D:\backup.ps1""" -WorkingDirectory "D:\"
    )

    $Stt = New-ScheduledTaskTrigger -Daily -At 3am

    $user = Read-Host -Prompt "Enter username"
    $securepass = Read-Host -Prompt "Enter password" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securepass)
    $pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    $arglist = @{
        '-TaskName'="Run-Backups";
        "-Action"=$actions;
        "-Description"="Run backup script.";
        "-Trigger"=$Stt;
        "-RunLevel"="Highest";
        "-User"=$user;
        "-Password"=$pass
        }

    Register-ScheduledTask @arglist -Force
    exit
}

$csv = Import-Csv $BackupCsv | Where-Object { $_.Computer -eq $env:COMPUTERNAME -and $_.Type -like $Type }

ForEach ($line in $csv) {
    $src = $line.Source
    if (-Not (Test-Path $src))
    {
        if ($WhatIf.IsPresent -or $Force.IsPresent)
        {
            Write-Host "location invalid: $src"
        }
        else
        {
            throw "location invalid: $src"
        }
    }

    $dst = $line.Destination
    if (-Not (Test-Path $dst))
    {
        if ($WhatIf.IsPresent -or $Force.IsPresent)
        {
            Write-Host "location invalid: $dst"
        }
        else
        {
            throw "location invalid: $dst"
        }
    }
}

$logfilepath = "C:\users\jrob\robocopy.log"
$logopt = "/log:$logfilepath"
ForEach ($line in $csv) {
    Write-Host ""
    Write-Host "------------------------------------------------"
    Write-Host $action $line.Type $line.Name

    if($Action -eq "Backup")
    {
        $src = $line.Source
        $dst = $line.Destination
    }
    else
    {
        $dst = $line.Source
        $src = $line.Destination
    }

    $arglist = @(
        $src,
        $dst,
        "/MIR",
        "/ZB",
        "/MT",
        #"/V",
        $logopt
    )
    if ($WhatIf.IsPresent)
    {
        write-host "C:\Windows\System32\Robocopy.exe" $arglist
    }
    else
    {
        & C:\Windows\System32\Robocopy.exe $arglist
    }
    $logopt = "/log+:$logfilepath"
}

