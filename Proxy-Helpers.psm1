function Set-NoProxy($noProxy)
{
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Machine")
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Process")
}

function Set-Proxy($proxy)
{
    Set-ProxyEnvironmentVariable $Proxy
}

function Clear-Proxy
{
    Set-ProxyEnvironmentVariable $null
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

export-modulemember -function Set-Proxy
export-modulemember -function Clear-Proxy
