workflow Setup-Machine {
    Set-ExecutionPolicy RemoteSigned -force
    iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
    choco install git
    Restart-Computer -Wait

    git clone https://github.com/jrob/ps-config.git "$home\Scripts\Powershell"
    Installs-01
    Restart-Computer -Wait

    Installs-02
    Restart-Computer -Wait

    Installs-03
    Restart-Computer -Wait

    Setup-01
    Restart-Computer -Wait
}

function Installs-01
{
    # system
    choco install powershell4
    choco install pscx
    choco install conemu

    # Web
    choco install firefox
    choco install GoogleChrome

    # utils
    choco install adobereader
    choco install 7zip
    choco install notepadplusplus
    choco install ccleaner
    choco install winscp
    choco install autohotkey
    choco install f.lux
    choco install spacesniffer
    choco install syncback
    choco install mousewithoutborders

    # apps
    choco install keepass
    choco install dropbox
    choco install evernote
    choco install linqpad4

    # Dev
    choco install gitextensions
    choco install virtualbox
    choco install VirtualBox.ExtensionPack
    choco install beyondcompare
    cinst VisualStudio2013Ultimate -InstallArguments "/Features:'SQL Blend' /ProductKey:"
    choco install MsSqlServerManagementStudio2014Express
    choco install resharper

    #frameworks
    choco install mingw
    choco install StrawberryPerl
    choco install python
}

function Installs-02
{
    choco install poshgit
    choco install easy.install
}
function installs-03
{
    choco install pip
}

function Setup-01
{
    # clone relevant repositories
    git clone https://github.com/jrob/vim-config.git "$home\vim"
    git clone https://github.com/bbusschots/xkpasswd.pm.git "$home\Scripts\Perl\xkpasswd"
    mkdir -p $home/.vim/bundle
    git clone https://github.com/Shougo/neobundle.vim $home/.vim/bundle/neobundle.vim

    # Powershell Profile
    $profilecontent = @'
$scripts = "~\scripts"
$usepscx3 = $True
. "$scripts\PowerShell\profile.ps1"
'@
    $profilecontent | Out-File ~\documents\Documents\WindowsPowerShell\Profile.ps1

    # Bitvise Ssh Server
    Invoke-WebRequest http://dl.bitvise.com/BvSshServer-Inst.exe -OutFile BvSshServer-Inst.exe
    ./BvSshServer-Inst.exe -defaultSite
    net start BvSshServer

    # Bitvise Ssh Client
    Invoke-WebRequest http://dl.bitvise.com/BvSshClient-Inst.exe -OutFile BvSshClient-Inst.exe
    ./BvSshClient-Inst.exe -acceptEula -noDesktopIcon -installDir="${env:ProgramFiles(x86)}\Bitvise SSH Client"

    # Vim Cream
    Invoke-WebRequest http://superb-dca2.dl.sourceforge.net/project/cream/Vim/7.4.423/gvim-7-4-423.exe -UserAgent [Microsoft.PowerShell.Commands.PSUserAgent]::FireFox -outfile gvim-7-4-423.exe
    ./gvim-7-4-423.exe /S

    # Vim Profile
    $homeesc = $home.replace("\","\\")
    $vimprofile = @"
let myvimpath="$homeesc\\vim"
source $home\vim\.vimrc
"@
    [System.IO.File]::WriteAllLines("$home\.vimrc", $vimprofile)

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

Setup-Machine
