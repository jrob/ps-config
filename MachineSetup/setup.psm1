function Setup-Basic
{
    Git-Config
    Git-Clones
    Create-Profiles

    git clone https://github.com/lukesampson/concfg "$home\scripts\concfg"
    & $home\scripts\concfg\bin\concfg.ps1 import "$home\scripts\powershell\jrob.light.json" --non-interactive
    & $home\scripts\concfg\bin\concfg.ps1 clean
}

function Install-AppsMinimum
{
    choco install -y git
    choco install -y vim --allow-empty-checksums
    #choco install -y psget
    Install-PsGet
    Get-Consolas

    # Prep-Powershell
    Install-Module Posh-Git
}

function Install-AppsCommon
{
    choco install -y git-credential-manager-for-windows
    choco install -y nssm --allow-empty-checksums
    choco install -y sysinternals
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
    choco install -y f.lux --allow-empty-checksums --ignore-checksums
    choco install -y spacesniffer
    choco install -y gitextensions
    choco install -y beyondcompare --allow-empty-checksums
    choco install -y visualstudiocode

    # apps
    choco install -y keepass
    choco install -y autohotkey.portable --allow-empty-checksums
    choco install -y dropbox
    choco install -y evernote --allow-empty-checksums
    choco install -y linqpad4 --allow-empty-checksums

    choco install -y python
    [Environment]::SetEnvironmentVariable("path", $env:path + ";C:\Python36\Scripts\", "Process")
    [Environment]::SetEnvironmentVariable("path", $env:path + ";C:\Python36\", "Process")

    choco install -y nodejs
    [Environment]::SetEnvironmentVariable("path", $env:path + ";C:\Program Files\nodejs\", "Process")
    npm install -g cfn-include
    npm install -g proxy-agent

    choco install -y activeperl
}

function Install-AppsHome
{
    choco install -y picasa --allow-empty-checksums
    choco install -y calibre
    choco install -y curse-voice
    choco install -y adobe-creative-cloud
    choco install -y comicrack
    choco install -y minecraft
    choco install -y postbox

    Install-MinecraftLaunchers
    Install-Office
}

function Install-AppsWork
{
    # JetBrains tools
    choco install -y resharper-platform --allow-empty-checksums
    choco install -y resharper
    choco install -y dotmemory
    choco install -y dottrace
    choco install -y dotcover
    choco install -y vcredist2010 --allow-empty-checksums
    choco install -y vagrant
    choco install -y packer

    # Dev
    choco install -y virtualbox
    choco install -y visualstudio2015enterprise
    Install-SsdtVs2015
    choco install -y sql-server-management-studio
    choco install -y awscli
    choco install -y chefdk
    choco install -y wixtoolset --allow-empty-checksums

    # bfg-repo-cleaner
    choco install -y jre8 --allow-empty-checksums
    choco install -y vcredist2015
    choco install -y bfg-repo-cleaner
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

function Install-Vs2102
{
    $InstallerDirectory = "C:\temp\vs2012-ultimate"
    if (Test-Path $InstallerDirectory) { Remove-Item $InstallerDirectory -Force -Recurse }
    New-Item $InstallerDirectory -force -ItemType directory
    & 'C:\Program Files\7-Zip\7z.exe' x -o"$InstallerDirectory" D:\Archives\en_visual_studio_ultimate_2012_x86_dvd_2262106.iso
    $file = "$InstallerDirectory\vs_ultimate.exe"
    $arglist = @("/Quiet", "/Passive", "/Log", """$env:USERPROFILE\Logs\vs2012\vs2012install.log""")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Remove-Item $InstallerDirectory -Force -Recurse
}

function Install-SsdtVs2012
{
    # https://msdn.microsoft.com/en-us/jj650015
    # http://go.microsoft.com/fwlink/?LinkID=518814&clcid=0x409
    # SSDT_11.1.50512.0_EN.iso
    $InstallerDirectory = "C:\temp\vs2012-ssdt"
    if (Test-Path $InstallerDirectory) { Remove-Item $InstallerDirectory -Force -Recurse }
    New-Item $InstallerDirectory -force -ItemType directory
    & 'C:\Program Files\7-Zip\7z.exe' x -o"$InstallerDirectory" D:\Archives\SSDT_11.1.50512.0_EN.iso
    $file = "$InstallerDirectory\SSDTSETUP.exe"
    $arglist = @("/silent")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Remove-Item $InstallerDirectory -Force -Recurse
}

function Install-SsdtVs2015
{
    # https://msdn.microsoft.com/en-us/mt186501.aspx
    # C:\Users\robeje10\Downloads\SSDTSetup.exe /layout D:\archives\ssdt-2015
    $file = "D:\archives\ssdt-2015\SSDTSetup.exe"
    $arglist = @("/silent", "/norestart")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
}

function Install-ParallelsClient ($settingsFile)
{
    $file = "D:\archives\RASClient-x64_Parllels_15.0.4_3830_hf4.msi"
    cp $settingsFile D:\archives\2xsettings.2xc
    $arglist = @("/i", $file, "/passive", "/norestart", "OVERRIDEUSERSETTINGS=1")
    Start-Process -FilePath msiexec -ArgumentList $arglist -Wait
    remove-item D:\archives\2xsettings.2xc
}

function Install-Visio
{
    # visio
    $InstallerDirectory = "C:\temp\visio"
    if (Test-Path $InstallerDirectory) { Remove-Item $InstallerDirectory -Force -Recurse }
    $ConfigFile = "$installerDirectory\visio_config.xml"
    $file = "D:\Archives\en_visio_professional_2013_with_sp1_x64_3910816.exe"
    $arglist = @("/extract:$InstallerDirectory")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
@"
<Configuration>
<Display Level="none" AcceptEula="yes" />
<!-- <Logging Type="standard" Path="%temp%" Template="Microsoft Office Professional Plus Setup(*).txt" /> -->
<!-- <USERNAME Value="Customer" /> -->
<!-- <COMPANYNAME Value="MyCompany" /> -->
<!-- <INSTALLLOCATION Value="%programfiles%\Microsoft Office" /> -->
<!-- <LIS CACHEACTION="CacheOnly" /> -->
<!-- <LIS SOURCELIST="\\server1\share\Office;\\server2\share\Office" /> -->
<!-- <DistributionPoint Location="\\server\share\Office" /> -->
<!-- <OptionState Id="OptionID" State="absent" Children="force" /> -->
<!-- <Setting Id="SETUP_REBOOT" Value="IfNeeded" /> -->
<!-- <Command Path="%windir%\system32\msiexec.exe" Args="/i \\server\share\my.msi" QuietArg="/q" ChainPosition="after" Execute="install" /> -->
</Configuration>
"@ | Out-File $ConfigFile
    $file = "$InstallerDirectory\setup.exe"
    $arglist = @("/config $ConfigFile")
    Start-Process $file -ArgumentList $arglist -Wait -NoNewWindow
    Remove-Item $InstallerDirectory -Force -Recurse
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

function Install-MinecraftLaunchers
{
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

    git config --global diff.tool bc
    git config --global diff.guitool bc
    git config --global difftool.bc.path "c:/Program Files/Beyond Compare 4/BComp.exe"
    git config --global merge.tool bc
    git config --global mergetool.bc.path "c:/Program Files/Beyond Compare 4/BComp.exe"

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
        if ((test-path d:\Archives\Consolas\$font) -eq $false)
        {
            Invoke-WebRequest ($url + $font + "?raw=true") -OutFile d:\Archives\Consolas\$font
        }
        Add-Font d:\Archives\Consolas\$font
    }
}

function Install-PsGet
{
    $wc = new-object net.webclient
    if ($useProxy)
    {
        $wc.UseDefaultCredentials = $true
        $wc.Proxy.Credentials = $wc.Credentials
    }
    $wc.DownloadString("http://psget.net/GetPsGet.ps1") | iex
}

function Replace-In-File($filename, $before, $after)
{
    (Get-Content $filename) |
    ForEach-Object {$_ -replace $before, $after } |
    Set-Content $filename
}

function Enable-TaskSchedulerHistory
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
