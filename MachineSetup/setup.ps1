<#
# Manual commands or reboots required.
Set-ExecutionPolicy RemoteSigned -force
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
#>

<#
# Bootstrap
# https://chocolatey.org/install execute the following command in a elevated shell
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

choco config set cacheLocation <persistentPath>
choco upgrade -y git
refreshenv

git config --global user.name "<name>"
git config --global user.email <email>

git clone https://github.com/jrob/ps-config.git "$home\dev\ps-config"
pushd $home\dev\ps-config
git checkout updates
popd

New-Item –Path $Profile –Type File –Force
Add-Content $profile '. "$env:USERPROFILE\dev\ps-config\profile.ps1"'

$profilePS7 = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
New-Item –Path $ProfilePS7 –Type File –Force
Add-Content $profile '. "$env:USERPROFILE\dev\ps-config\profile.ps1"'
#>

choco upgrade `
    openssh `
    vim `
    git `
    microsoft-windows-terminal `
    7zip `
    beyondcompare `
    git-fork `
    keepass `
    greenshot `
    python `
    activeperl `
    nodejs `
    f.lux `
    inputdirector `
    gitextensions `
    vscode `
    paint.net `
    firefox `
    GoogleChrome `
    docker-desktop `
    spacesniffer `
    dropbox `
    slack `
    citrix-workspace `
    microsoft-teams `
    office365proplus `
    visualstudio2019enterprise `
    resharper-ultimate-all `
    sql-server-management-studio `
    awscli `
    -y

refreshenv

#Install-PackageProvider -Force -Name NuGet
#Install-Module -Force Posh-Git