function Choco-Installs
{
    choco install -y git-credential-manager-for-windows
    choco install -y nssm --allow-empty-checksums
    choco install -y sysinternals
    Add-PathFolders.ps1 "C:\tools\sysinternals" process
    choco install -y pandoc
    choco install -y bitvise-ssh-client --allow-empty-checksums --ignore-checksums

    # Web
    choco install -y firefox
    choco install -y GoogleChrome

    # utils
    choco install -y adobereader --allow-empty-checksums
    choco install -y 7zip
    choco install -y notepadplusplus
    choco install -y ccleaner
    choco install -y winscp
    choco install -y autohotkey --allow-empty-checksums
    choco install -y f.lux --allow-empty-checksums
    choco install -y spacesniffer

    # apps
    choco install -y keepass
    choco install -y autohotkey.portable --allow-empty-checksums
    choco install -y dropbox
    choco install -y evernote --allow-empty-checksums
    choco install -y linqpad4 --allow-empty-checksums
    choco install -y picasa --allow-empty-checksums

    # Dev
    choco install -y gitextensions

    choco install -y virtualbox --allow-empty-checksums
    Start-Sleep -Seconds 10
    choco install -y VirtualBox.ExtensionPack --allow-empty-checksums
    choco install -y sql-server-management-studio

    choco install -y vcredist2010 --allow-empty-checksums
    choco install -y vagrant
    choco install -y packer
    choco install -y beyondcompare --allow-empty-checksums
    #choco install MsSqlServerManagementStudio2014Express
}

function Custom-Installs
{
    Enable-Net35
}

function Enable-Net35
{
    DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:D:\installers\35netsp1sources
}

function Get-UserPassword
{
    $response = Read-host "What's your password?" -AsSecureString
    $password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($response))
    return $password
}

function Install-DevExpress($custid, $email, $password)
{
    Write-Host "Install DevExpress"
    psexec -h -d "C:\Program Files\AutoHotkey\AutoHotkey.exe" "$($env:USERPROFILE)\Scripts\Powershell\MachineSetup\devexpress.ahk"
    $file = "D:\installers\DXperience-8.3.8.exe"
    $arglist = @(
        "/Q",
        "/EMAIL:$email",
        "/CUSTOMERID:$custid",
        "/PASSWORD:$password",
        "/DEBUG",
        '"Demos:False"'
        )
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Write-Host "DevExpress finished"
}

function Setup-VirtualMachineTask($vmname, $user, $pass)
{
    Write-Host "Setup VirtualMachineTask $vmname"
    # the following command can be used to shut the machine down.
    #& 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' controlvm machineName acpipowerbutton

    $Stt = New-ScheduledTaskTrigger -AtStartup
    $task = New-ScheduledTaskAction -Execute 'C:\Program Files\Oracle\VirtualBox\VBoxManage.exe' -Argument "startvm $vmname --type headless"

    $arglist = @{
        '-TaskName'="Run-VirtualBoxMachine";
        "-Description"="Start virtualmachine headless at machine start.";
        "-Action"=$task;
        "-Trigger"=$Stt
        }

    if ($user) { $arglist += @{"-User"=$user; "-Password"=$pass} }

    Register-ScheduledTask @arglist -Force
    Write-Host "Setup VirtualMachineTask $vmname finished"
}

function Set-PowerOptions
{
    powercfg /change monitor-timeout-ac 10
    powercfg /change standby-timeout-ac 0
    powercfg /change hibernate-timeout-ac 0
}

function Install-SsdtBi2013
{
    Write-Host "Install SsdtBi2013"
    # Sql BI tools for visual studio
    # run and extract to D:\installers\SSDTBI_x86_ENU
    # http://www.microsoft.com/en-us/download/details.aspx?id=42313
    $file = "D:\installers\SSDTBI_x86_ENU\SETUP.EXE"
    $arglist = @("/Q /IACCEPTSQLSERVERLICENSETERMS /ACTION=install /FEATURES=Tools")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Write-Host "SsdtBi2013 finished"
}

function Install-Ssdt
{
    Write-Host "Install Ssdt"
    # SSDT Tools
    # https://msdn.microsoft.com/en-us/data/hh297027
    # https://msdn.microsoft.com/en-us/dn864412
    # SSDTSetup.exe /layout <destination>
    $file = "D:\installers\ssdt\SSDTSetup.exe"
    $arglist = @("/silent")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Write-Host "Ssdt finished"
}

function Install-VsExtensions
{
    $installer = "C:\Program Files (x86)\Microsoft Visual Studio 12.0\Common7\IDE\VSIXInstaller.exe"

    Write-Host "Install CodeMaid"
    $url = "https://visualstudiogallery.msdn.microsoft.com/76293c4d-8c16-4f4a-aee6-21f83a571496/file/9356/29/"
    $file = "d:\Installers\CodeMaid_v0.7.5.vsix"
    Download-File $file $url
    & $installer /q $file
    Write-Host "CodeMaid finished"

    Write-Host "Install VsVim"
    $url = "https://visualstudiogallery.msdn.microsoft.com/59ca71b3-a4a3-46ca-8fe1-0e90e3f79329/file/6390/55/"
    $file = "d:\Installers\VsVim.vsix"
    Download-File $file $url
    & $installer /q $file
    Write-Host "VsVim finished"

    Write-Host "Install XamlStyler"
    $url = "https://visualstudiogallery.msdn.microsoft.com/3de2a3c6-def5-42c4-924d-cc13a29ff5b7/file/124126/12/"
    $file = "D:\Installers\XamlStyler.Package.vsix"
    Download-File $file $url
    & $installer /q $file
    Write-Host "XamlStyler finished"

    Write-Host "Install RelativeLineNumbers"
    $url = "https://visualstudiogallery.msdn.microsoft.com/74d68e2b-ff64-4c51-a2ed-d8b164eee858/file/96667/6/"
    $file = "D:\Installers\RelativeLineNumbers.vsix"
    Download-File $file $url
    & $installer /q $file
    Write-Host "RelativeLineNumbers finished"

    Write-Host "Install Resharper"
    choco install -y resharper
    Write-Host "Resharper finished"
}

function Install-BitviseSshServer($settings, $activationCode, $keypairFile)
{
    $packageParams =  "'/acceptEULA /activationCode=$activationCode /settings=$settings /keypairs=$keypairFile'"
    choco install -y bitvise-ssh-server --allow-empty-checksums --ignore-checksums --package-parameters $packageParams
}

function Install-Office
{
    Write-Host "Install Office"
    # Download and extract the ISO.
    # Office 2013 Pro Plus with Sp1
    # https://msdn.microsoft.com/subscriptions/securedownloads/?#FileId=57396
    $file = "D:\installers\office2013\setup.exe"
    $arglist = @("/config", """$env:USERPROFILE\scripts\powershell\Office2013_config.xml""")
    Download-Install $file "" $arglist
    Write-Host "Office finished"
}

function Install-Studio
{
    Write-Host "Install Studio2013U4"
    # Download and extract the ISO.
    # Visual Studio 2013 udpate 4
    # https://msdn.microsoft.com/subscriptions/securedownloads/?#FileId=61638
    $file = "D:\installers\vs2013UltUpdate4\vs_ultimate.exe"
    $arglist = @("/Quiet", "/Passive", "/Log", """$env:USERPROFILE\Logs\vs2013\vs2013install.log""")
    Download-Install $file "" $arglist
    Write-Host "Studio2013U4 finished"
}

function Install-ComicRack
{
    $url = "http://comicrack.cyolito.com/downloads/comicrack/func-download/131/chk,ea95a6e77aa9fc1cebadf75bfe77d009/no_html,1/"
    $file = "D:\installers\ComicRackSetup09176.exe"
    $arglist = @("/S")
    Download-Install $file $url $arglist
}

function Install-LightRoom
{
    $file = "D:\installers\lightroom_5_ccm\Adobe_Lightroom_x64.msi"
    $arglist = @("/i", $file, "/passive")
    Start-Process  -FilePath msiexec -ArgumentList $arglist -Wait
}

function Download-File($file, $url)
{
    $useragent = [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox
    if ((test-path $file) -eq $false -and $url)
    {
        Invoke-WebRequest $url -UserAgent $useragent -OutFile $file
    }
}

function Download-Install($file, $url, $arglist)
{
    Download-File $file $url
    if (Test-Path $file)
    {
        Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    }
}

function Install-Minecraft
{
    $file = "d:\installers\MinecraftInstaller.msi"
    if (Test-Path $file) { & $file /quiet }

    $file = "D:\installers\TechnicLauncher.exe"
    if (Test-Path $file) { cp $file $env:USERPROFILE\desktop }

    $file = "D:\installers\FTB_Launcher.exe"
    if (Test-Path $file) { cp $file $env:USERPROFILE\desktop }
}

function Git-Clones
{
    # clone relevant repositories
    git clone https://github.com/jrob/vim-config.git "$home\vim"
    git clone https://github.com/bbusschots/xkpasswd.pm.git "$home\Scripts\Perl\xkpasswd"
    mkdir -Path $home/.vim/bundle
    git clone https://github.com/Shougo/neobundle.vim "$home\vim\bundle\neobundle.vim"
}

function Create-Profiles
{
    # Powershell Profile
    $profilecontent = @'
. "$env:USERPROFILE\scripts\PowerShell\profile.ps1"
'@
    mkdir -Path ~\Documents\WindowsPowerShell -Force
    $profilecontent | Out-File $profile -Force

    # Vim Profile
    $homeesc = $home.replace("\","\\")
    $vimprofile = @"
let myvimpath="$homeesc\\vim"
source $home\vim\.vimrc
"@
    [System.IO.File]::WriteAllLines("$home\.vimrc", $vimprofile)
}

function Git-Config
{
    # git configuration
    git config --global user.name "Jeremy Roberts"          # Name
    git config --global user.email jeremy@robertsisland.com # Email
    git config --global branch.autosetuprebase always       # Force all new branches to automatically use rebase
    git config --global push.default simple

    git config --global core.editor "gvim -f"
    #merge.tool=BeyondCompare3
    #difftool.BeyondCompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #difftool.beyondcompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #difftool.beyondcompare3.cmd="C:/Program Files (x86)/Beyond Compare 3/bcomp.exe" "$LOCAL" "$REMOTE"
    #mergetool.BeyondCompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #mergetool.BeyondCompare3.cmd="C:/Program Files (x86)/Beyond Compare 3/bcomp.exe" "$LOCAL" "$REMOTE" "$BASE" "$MERGED"
    #core.editor="C:/Program Files (x86)/vim/vim74/gvim.exe" -f
    #alias.lg=log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
}

function Add-Font($fontpath)
{
    # http://stackoverflow.com/questions/16023238/installing-system-font-with-powershell
    $FONTS = 0x14
    $objShell = New-Object -ComObject Shell.Application
    $objFolder = $objShell.Namespace($FONTS)
    $objFolder.CopyHere($fontpath)
}

function Get-Consolas
{
    # https://github.com/runsisi/consolas-font-for-powerline
    $url = "https://github.com/runsisi/consolas-font-for-powerline/blob/master/"
    $fonts = "Powerline Consolas Bold Italic.ttf",
        "Powerline Consolas Bold.ttf",
        "Powerline Consolas Italic.ttf",
        "Powerline Consolas.ttf"

    foreach ($font in $fonts)
    {
        if ((test-path d:\installers\$font) -eq $false)
        {
            Invoke-WebRequest ($url + $font + "?raw=true") -OutFile d:\installers\$font
        }
        Add-Font d:\installers\$font
    }
}

function Install-PsGet($useProxy)
{
    $wc = new-object net.webclient
    if ($useProxy)
    {
        $wc.UseDefaultCredentials = $true
        $wc.Proxy.Credentials = $wc.Credentials
    }
    $wc.DownloadString("http://psget.net/GetPsGet.ps1") | iex
}

function Prep-Powershell
{
    choco install -y powershell4
    Install-Module PSReadline
    Install-Module Posh-Git
}

function Replace-In-File($filename, $before, $after)
{
    (Get-Content $filename) |
    ForEach-Object {$_ -replace $before, $after } |
    Set-Content $filename
}

function Prep-Conemu
{
    choco install -y conemu
    cmd /c mklink %appdata%\ConEmu.xml %homedrive%%homepath%\Scripts\Powershell\ConEmu.xml
}

function Enable-Task-Scheduler-History
{
    #http://stackoverflow.com/questions/23227964/how-can-i-enable-all-tasks-history-in-powershell
    $logName = 'Microsoft-Windows-TaskScheduler/Operational'
    $log = New-Object System.Diagnostics.Eventing.Reader.EventLogConfiguration $logName
    $log.IsEnabled=$true
    $log.SaveChanges()
}

function Enable-RemoteDesktop
{
    # Enable Remote Desktop
    set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server'-name "fDenyTSConnections" -Value 0
    set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 1
}

function Setup-Bin-Folder
{
    mkdir "$home/bin" -Force
    & $env:USERPROFILE\Scripts\Powershell\Add-PathFolders.ps1 "$($env:USERPROFILE)\bin" process
    & $env:USERPROFILE\Scripts\Powershell\Add-PathFolders.ps1 "$($env:USERPROFILE)\bin" user
    cmd /c mklink "%USERPROFILE%\bin\Add-PathFolders.ps1" "%USERPROFILE%\Scripts\Powershell\Add-PathFolders.ps1"
    cmd /c mklink "%USERPROFILE%\bin\Get-PathFolders.ps1" "%USERPROFILE%\Scripts\Powershell\Get-PathFolders.ps1"
    cmd /c mklink "%USERPROFILE%\bin\Remove-PathFolders.ps1" "%USERPROFILE%\Scripts\Powershell\Remove-PathFolders.ps1"
}

function phase2
{
    Choco-Installs
    Manual-Installs
}

function Setup-Basic
{
    Git-Config
    Git-Clones
    Setup-Bin-Folder
    Prep-Powershell
    Create-Profiles
    Prep-Conemu
    choco install -y vim --allow-empty-checksums
    Get-Consolas
}

function Setup-MsDevTools
{
    Install-Studio
    Install-VsExtensions
    Install-SsdtBi2013
    Install-Ssdt
}

# Manual steps
# run bootstrap
