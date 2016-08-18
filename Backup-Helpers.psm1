function Run-Backups($locations)
{
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$src" "$dst" /MIR /ZB /NP
    }
}

function Restore-Backups($locations)
{
    foreach ($i in $locations)
    {
        $src = $i.src
        $dst = $i.dst
        robocopy "$dst" "$src" /E /NP
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
        $newTask = New-ScheduledTaskAction -Execute 'C:\Windows\System32\Robocopy.exe' -Argument """$src"" ""$dst"" /MIR /ZB /NP $logopt"
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
