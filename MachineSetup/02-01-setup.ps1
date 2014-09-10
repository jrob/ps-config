# clone relevant repositories
git clone https://github.com/jrob/vim-config.git ~\vim
git clone https://github.com/bbusschots/xkpasswd.pm.git ~\Scripts\Perl\xkpasswd

# powershell profile linking
$profilecontent = @'
$scripts = "~\scripts"
$usepscx3 = $True
. "$scripts\PowerShell\profile.ps1"
'@
$profilecontent | Out-File ~\documents\Documents\WindowsPowerShell\Profile.ps1
