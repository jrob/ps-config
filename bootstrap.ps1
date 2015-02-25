Set-ExecutionPolicy RemoteSigned -force
iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y git
& "C:\Program Files (x86)\Git\cmd\git.exe" clone https://github.com/jrob/ps-config.git "$home\Scripts\Powershell"
exit
