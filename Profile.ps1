#$s=Get-Date

$env:Path += ";" + $scripts + "\powershell"
$env:Path += ";" + $scripts + "\python"
$env:Path += ";" + $scripts + "\Perl\ack"
$env:PATHEXT += ";.py"
$env:PATHEXT += ";.pl"

if ($usepscx3 -eq $True)
{
    Import-Module Pscx
}
else
{
    Import-Module "$pscx\pscx.psd1" -arg "$scripts\powershell\Pscx.UserPreferences.ps1"
}

Import-Module "$scripts\powershell\posh-git"
Import-Module PSReadLine
Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward

#$e=Get-Date; ($e - $s).TotalSeconds

#. "$scripts\powershell\ssh-agent-utils.ps1"

#Set-Alias pn "C:\Program Files (x86)\Programmer's Notepad\pn.exe"
#Set-Alias sz "C:\Program Files\7-Zip\7z.exe"
#Set-Alias vim "C:\Program Files (x86)\Vim\vim73\vim.exe"
#Set-Alias sub "C:\Program Files\Sublime Text 2\sublime_text.exe"
#Set-Alias bc "C:\Program Files (x86)\Beyond Compare 3\BComp.com"
Set-Alias di ls

Function ve { gvim --remote-tab-silent $args }

Set-Alias mr ($scripts + "\PowerShell\MassRename.ps1")
Set-Alias which ($scripts + "\PowerShell\Which.ps1")

Set-Alias formd ($scripts + "\Python\formd\src\formd.py")

function mako { python ($scripts + "\Python\mako-render.py") $args }

# To force git to display colors
#$env:TERM = 'cygwin'
#$env:LESS = 'FRSX'

#$a = (Get-Host).UI.RawUI
#$a.BackgroundColor = "rgb(50,50,50)"

# http://www.nivot.org/nivot2/post/2008/06/27/WorkaroundToForcePowerShellRedirectionOperatorToUseASCIIEncoding.aspx
#function out-file($FilePath, $Encoding, [switch]$Append) {
#    $input | microsoft.powershell.utility\out-file $filepath -encoding ascii -append:$append
#}

# http://blog.clintarmstrong.net/2011/05/powershell-history-persistence.html
#$MaximumHistoryCount = 31KB

#function bye
#{
#    Get-History -Count 31KB | Export-CSV ~\PowerShell-history.csv
#    exit
#}

#if (Test-Path ~\PowerShell-History.csv)
#{
#    Import-CSV ~\PowerShell-History.csv | Add-History
#    Get-History -Count 31KB | Export-CSV ~\PowerShell-history.csv
#}

cd ~

# Shamelessly modified from http://winterdom.com/2008/08/mypowershellprompt
$Global:skip = $true
function prompt {
    #$hid = $myinvocation.historyID
    #if ($hid -gt 1 -and -not $skip) {
    #    Get-History ($myinvocation.historyID -1 ) |
    #        ConvertTo-Csv |
    #        Select -last 1 |
    #        Add-Content -Encoding UTF8 ~\PowerShell-History.csv
    #}
    #$Global:skip = $false

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
