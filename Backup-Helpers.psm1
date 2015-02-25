function Run-Backups($locations)
{
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$src" "$dst" /MIR /ZB /V
    }
}

function Restore-Backups($locations)
{
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$dst" "$src" /E
    }
}

function Schedule-Backup-Tasks($locations, $logfilepath)
{
    $actions = @()

    $logopt = "/log:$logfilepath"
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        #Write-Host """$src"" ""$dst"" /MIR /ZB /V"
        $newTask = New-ScheduledTaskAction -Execute 'C:\Windows\System32\Robocopy.exe' -Argument """$src"" ""$dst"" /MIR /ZB /V $logopt"
        $actions += $newTask
        $logopt = "/log+:$logfilepath"
    }

    $Stt = New-ScheduledTaskTrigger -Daily -At 3am

    Register-ScheduledTask -Action $actions -TaskName "Run-Robocopy" -Description "Run robocopy batch jobs." -Trigger $Stt -RunLevel Highest
}
