function Run-Backups($locations, $logfile)
{
    $count = 0
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$src" "$dst" /MIR /ZB /NP /MT /LOG:"$logfile$count.txt"
        $count++
    }
}

function Restore-Backups($locations, $logfile)
{
    $count = 0
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$dst" "$src" /E /NP /MT /LOG:"$logfile$count.txt"
        $count++
    }
}

function Schedule-Backup-Tasks($locations, $logfilepath, $user, $pass)
{
    $actions = @()

    $logopt = "/log:$logfilepath"
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        #Write-Host """$src"" ""$dst"" /MIR /ZB /NP"
        $newTask = New-ScheduledTaskAction -Execute 'C:\Windows\System32\Robocopy.exe' -Argument """$src"" ""$dst"" /MIR /ZB /NP /MT $logopt"
        $actions += $newTask
        $logopt = "/log+:$logfilepath"
    }

    $Stt = New-ScheduledTaskTrigger -Daily -At 3am

    $arglist = @{
        '-TaskName'="Run-Robocopy";
        "-Action"=$actions;
        "-Description"="Run robocopy batch jobs.";
        "-Trigger"=$Stt;
        "-RunLevel"="Highest"
        }

    if ($user){ $arglist += @{"-User"=$user; "-Password"=$pass} }

    Register-ScheduledTask @arglist -Force
}
