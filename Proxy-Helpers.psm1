function Set-NoProxy($noProxy)
{
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Machine")
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Process")
}

function Set-Proxy($proxy)
{
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Machine")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Machine")
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Process")
    $http_proxy = $proxy
    $https_proxy = $proxy
}

function Clear-Proxy
{
    $oldProxy = $env:https_proxy
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "Machine")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "Machine")
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "Process")
    $http_proxy = $null
    $https_proxy = $null
}

export-modulemember -function Set-Proxy
export-modulemember -function Clear-Proxy
