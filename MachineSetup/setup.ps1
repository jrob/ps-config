function Choco-Installs
{
    # system
    choco install -y conemu

    # Web
    choco install -y firefox
    choco install -y GoogleChrome

    # utils
    choco install -y adobereader
    choco install -y 7zip
    choco install -y notepadplusplus
    choco install -y ccleaner
    choco install -y winscp
    choco install -y autohotkey
    choco install -y f.lux
    choco install -y spacesniffer
    choco install -y mousewithoutborders
    choco install -y teamspeak

    # apps
    choco install -y keepass
    choco install -y dropbox
    choco install -y evernote
    choco install -y linqpad4
    choco install -y picasa

    # Dev
    choco install -y gitextensions
    choco install -y virtualbox
    choco install -y VirtualBox.ExtensionPack
    choco install -y vagrant
    choco install -y packer
    choco install -y beyondcompare
    #cinst VisualStudio2013Ultimate -InstallArguments "/Features:'SQL Blend' /ProductKey:"
    #choco install MsSqlServerManagementStudio2014Express
    #choco install resharper

    #frameworks
    choco install -y -x86 mingw
    .\Remove-PathFolders.ps1 C:\tools\mingw64\bin user
    .\Add-PathFolders.ps1 C:\tools\mingw32\bin user

    choco install -y StrawberryPerl
    .\Remove-PathFolders.ps1 C:\strawberry\c\bin machine

    choco install -y jre8

    choco install -y python
    .\Add-PathFolders.ps1 C:\tools\python process

    echoco install -y easy.install
    .\Add-PathFolders.ps1 C:\tools\python\Scripts process
    
    choco install -y pip
}

function Manual-Installs
{
    # Bitvise Ssh Server
    if ((test-path d:\installers\BvSshServer-Inst.exe) -eq $false)
    {
        Invoke-WebRequest http://dl.bitvise.com/BvSshServer-Inst.exe -OutFile d:\installers\BvSshServer-Inst.exe
    }
    d:\installers\BvSshServer-Inst.exe -acceptEULA -defaultSite
    net start BvSshServer

    # Bitvise Ssh Client
    if ((test-path d:\installers\BvSshClient-Inst.exe) -eq $false)
    {
        Invoke-WebRequest http://dl.bitvise.com/BvSshClient-Inst.exe -OutFile d:\installers\BvSshClient-Inst.exe
    }
    d:\installers\BvSshClient-Inst.exe -acceptEula -noDesktopIcon -installDir="${env:ProgramFiles(x86)}\Bitvise SSH Client"

    # Vim Cream
    if ((test-path d:\installers\gvim-7-4-423.exe) -eq $false)
    {
        Invoke-WebRequest http://superb-dca2.dl.sourceforge.net/project/cream/Vim/7.4.423/gvim-7-4-423.exe -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -outfile d:\installers\gvim-7-4-423.exe
    }
    d:\installers\gvim-7-4-423.exe /S

    # Free file sync
    if (Test-Path d:\installers\FreeFileSync_6.14_Windows_Setup.exe)
    {
        d:\installers\FreeFileSync_6.14_Windows_Setup.exe /S /D="$env:ProgramFiles\FreeFileSync"
    }

    if ((test-path d:\installers\pandoc-1.13.2-windows.msi) -eq $false)
    {
        Invoke-WebRequest https://github.com/jgm/pandoc/releases/download/1.13.2/pandoc-1.13.2-windows.msi -outfile d:\installers\pandoc-1.13.2-windows.msi
    }
    d:\installers\pandoc-1.13.2-windows.msi /quiet
}

function Git-Clones
{
    # clone relevant repositories
    git clone https://github.com/jrob/ps-config.git "$home\Scripts\Powershell"
    git clone https://github.com/jrob/vim-config.git "$home\vim"
    git clone https://github.com/bbusschots/xkpasswd.pm.git "$home\Scripts\Perl\xkpasswd"
    mkdir -Path $home/.vim/bundle
    git clone https://github.com/Shougo/neobundle.vim "$home\vim\bundle\neobundle.vim"
}

function Create-Profiles
{
    # Powershell Profile
    $profilecontent = @'
$scripts = "$env:homedrive$env:homepath\scripts"
$usepscx3 = $True
. "$scripts\PowerShell\profile.ps1"
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
    #merge.tool=BeyondCompare3
    #difftool.BeyondCompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #difftool.beyondcompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #difftool.beyondcompare3.cmd="C:/Program Files (x86)/Beyond Compare 3/bcomp.exe" "$LOCAL" "$REMOTE"
    #mergetool.BeyondCompare3.path=C:/Program Files (x86)/Beyond Compare 3/bcomp.exe
    #mergetool.BeyondCompare3.cmd="C:/Program Files (x86)/Beyond Compare 3/bcomp.exe" "$LOCAL" "$REMOTE" "$BASE" "$MERGED"
    #core.editor="C:/Program Files (x86)/vim/vim74/gvim.exe" -f
    #alias.lg=log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative
    #reviewboard.url=https://manager.petnetsolutions.net/sd/rb/
}

function Setup-Cli-Installers
{
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex
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

function Prep-Powershell
{
    choco install -y powershell4
    choco install -y pscx
    Install-Module PSReadline
    Install-Module Posh-Git
}

function Replace-In-File($filename, $before, $after)
{
    (Get-Content $filename) |
    ForEach-Object {$_ -replace $before, $after } |
    Set-Content $filename
}

function Fix-Choco-Config
{
    # Open Notepad as administrator
    # Modify C:\ProgramData\chocolatey\chocolateyinstall\chocolatey.config
    #    <cacheLocation>D:\choco</cacheLocation>
    # Close and reopen Powershell
    $file = "C:\ProgramData\chocolatey\chocolateyinstall\chocolatey.config"
    $before = "<cacheLocation></cacheLocation>"
    $after = "<cacheLocation>D:\choco</cacheLocation>"
    Replace-In-File  $file $before $after
}

function Prep-Git
{
    choco install -y git
    .\Add-PathFolders.ps1 "C:\Program Files (x86)\Git\cmd" process
    Git-Config
}

function phase1
{
    Setup-Cli-Installers
    Fix-Choco-Config
    Prep-Powershell
    Prep-Git
    Git-Clones
    Create-Profiles
    cmd /c mklink %appdata%\ConEmu.xml %homedrive%%homepath%\Scripts\Powershell\ConEmu.xml    
}

function phase2
{
    Choco-Installs
    Cleanup-Paths
    Manual-Installs
    Get-Consolas
}

pushd d:\

# Manual step
#Set-ExecutionPolicy RemoteSigned -force

#phase1
phase2

#& cipher.exe /e D:\crypto-test\
#& cipher.exe /x:D:\crypto-test\ d:\efs.key
#& certutil -f -p password -importpfx D:\efs.password.PFX

#rm C:\Users\jrob\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1

popd