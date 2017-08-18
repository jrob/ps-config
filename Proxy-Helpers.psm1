function Set-NoProxy($noProxy)
{
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Machine")
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Process")
}

function Set-Proxy {
    [CmdletBinding()] param(
        [String[]]$Proxy,

        [AllowEmptyString()]
        [String[]]$Acs
    )            

    Clear-Proxy
    Set-ProxyEnvironmentVariable $Proxy
    Set-IeProxy $Proxy $Acs
}

function Clear-Proxy
{
    Set-ProxyEnvironmentVariable $null
    Clear-IeProxy
}

function Set-IeProxy {
    [CmdletBinding()] param(
        [String[]]$Proxy,

        [AllowEmptyString()]
        [String[]]$acs
    ) 
    $null = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
    $sid = Get-CurrentUserSID
    $reg = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    Set-ItemProperty -Path $reg -Name ProxyServer -Value $proxy
    Set-ItemProperty -Path $reg -Name ProxyEnable -Value 1
    if($acs) {
        Set-ItemProperty -Path $reg -Name AutoConfigURL -Value $acs
    }
    else {
        Remove-ItemProperty -Path $reg -Name AutoConfigURL -ErrorAction SilentlyContinue
    }
    Remove-PSDrive -Name HKU

    $ie = new-object -ComObject internetexplorer.application
    $ie.quit()
}

function Clear-IeProxy {
    [CmdletBinding()] param()            

    $null = New-PSDrive -PSProvider Registry -Name HKU -Root HKEY_USERS
    $sid = Get-CurrentUserSID
    $reg = "HKU:\$sid\Software\Microsoft\Windows\CurrentVersion\Internet Settings"

    Remove-ItemProperty -Path $reg -Name ProxyServer -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $reg -Name ProxyEnable -Value 0
    Remove-ItemProperty -Path $reg -Name AutoConfigURL -ErrorAction SilentlyContinue
    Remove-PSDrive -Name HKU

    $ie = new-object -ComObject internetexplorer.application
    $ie.quit()
}

function Set-ProxyEnvironmentVariable($proxy)
{
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Machine")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Machine")
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Process")
    $http_proxy = $proxy
    $https_proxy = $proxy
}

function Get-CurrentUserSID {            
    [CmdletBinding()] param()            

    $objUser = New-Object System.Security.Principal.NTAccount( $env:USERDOMAIN, $env:USERNAME)
    $strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
    return $strSID.Value
}

export-modulemember -function Set-Proxy
export-modulemember -function Clear-Proxy
