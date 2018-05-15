$bastion = ""
$bastionUser = ""
$bastionKey = ""

$petnetProxyIp = ""
$petnetProxyPort = ""
$petnetProxyUrl = ""
$petnetBastion = ""
$petnetBastionUser = ""

$snxProxyIp = ""
$snxProxyPort = ""
$snxProxyUrl = ""
$snxAcs = ""

function Set-NetworkSnx
{
    Write-Host "Setting snx network"
    Remove-Ssh $petnetBastion
    Enable-NetAdapter Wi-Fi -Confirm:$False
    Disable-NetAdapter "Ethernet" -Confirm:$False
    Disable-NetAdapter "Ethernet 2" -Confirm:$False
    Set-Proxy -Proxy $snxProxyUrl -Acs $snxAcs
    Start-Ssh $bastion $bastionUser $bastionKey $snxProxyIp $snxProxyPort
}

function Set-ProxySnx
{
    Write-Host "Setting snx proxy"
    Set-Proxy -Proxy $snxProxyUrl -Acs $snxAcs
}

function Set-NetworkPetnet
{
    Write-Host "Setting petnet network"
    Remove-Ssh $bastion
    Disable-NetAdapter Wi-Fi -Confirm:$False
    Disable-NetAdapter "Ethernet" -Confirm:$False
    Enable-NetAdapter "Ethernet 2" -Confirm:$False
    Set-Proxy -Proxy $petnetProxyUrl
    Start-Ssh $petnetBastion $petnetBastionUser $bastionKey
}

function Set-ProxyPetnet
{
    Write-Host "Setting petnet proxy"
    Set-Proxy -Proxy $petnetProxyUrl
}

function Set-NetworkHome
{
    Write-Host "Setting home network"
    #Remove-Ssh $petnetBastion $petnetProxyIp
    Remove-Ssh $bastion $snxProxyIp
    Enable-NetAdapter "Wi-Fi" -Confirm:$False
    Enable-NetAdapter "Ethernet" -Confirm:$False
    Clear-Proxy
    #Start-Ssh $bastion $bastionUser
}

function Set-ProxyHome
{
    Write-Host "Setting home proxy"
    Clear-Proxy
}
