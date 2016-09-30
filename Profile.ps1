$scripts = "${env:home}\scripts"

$env:Path += ";$scripts\powershell"
$env:Path += ";$scripts\python"
$env:Path += ";$scripts\Perl\ack"
$env:PATHEXT += ";.py"
$env:PATHEXT += ";.pl"

Import-Module "$scripts\PowerShell\Proxy-Helpers.psm1"
Import-Module Posh-Git

Function vi { & "C:\Program Files (x86)\vim\vim74\gvim.exe" --remote-tab-silent $args }

Set-Alias mr "$scripts\PowerShell\MassRename.ps1"
Set-Alias which "$scripts\PowerShell\Which.ps1"

Import-Module PSReadLine
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
Set-PSReadlineOption -HistoryNoDuplicates
Set-PSReadlineOption -MaximumHistoryCount 16384

cd ~

# Shamelessly modified from http://www.winterdom.com/powershell/2008/08/13/mypowershellprompt.html
$Global:skip = $true
function prompt {
    # our theme
    $cdelim = [ConsoleColor]::DarkCyan
    $ctime = [ConsoleColor]::Blue
    $chost = [ConsoleColor]::Green
    $cloc = [ConsoleColor]::Cyan

    #write-host -NoNewline -ForegroundColor $cloc "$([char]0x0A7) "
    Write-Host -NoNewline -ForegroundColor $ctime (Get-Date -Format "yyyy-MM-dd HHmm ")
    Write-Host -NoNewline -ForegroundColor $chost "$env:username@"
    Write-Host -NoNewline -ForegroundColor $chost ([net.dns]::GetHostName())
    #write-host -NoNewline -ForegroundColor $cdelim ' {'
    Write-Host -NoNewline -ForegroundColor $cdelim ' '
    Write-Host -NoNewline -ForegroundColor $cloc (shorten-path (pwd).Path)
    #write-host -f $cdelim '}'
    Write-VcsStatus
    Write-Host -ForegroundColor $cdelim ''
    Write-Host -NoNewline '$'
    return ' '
}

function shorten-path([string] $path) {
   # For Win 7
   $loc = $path.Replace($HOME, '~')
   # For XP
   $loc = $loc.Replace($env:home, '~')
   # remove prefix for UNC paths
   $loc = $loc -replace '^[^:]+::', ''
   # make path shorter like tabs in Vim,
   # handle paths starting with \\ and . correctly
   # $loc = $loc -replace '\\(\.?)([^\\])[^\\]*(?=\\)','\$1$2'
   return $loc
}
