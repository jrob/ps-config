$VsConfigFile = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe.config"

function Get-VsConfigNoProxy
{
    return @"
        <system.net>
            <settings>
                <ipv6 enabled="true"/>
            </settings>
        </system.net>
"@
}

function Get-VsConfigWithProxy($proxy)
{
    return @"
        <system.net>
            <settings>
                <ipv6 enabled="true"/>
            </settings>
            <defaultProxy useDefaultCredentials="true" enabled="true">
                <proxy bypassonlocal="true" proxyaddress="$proxy" />
            </defaultProxy>
        </system.net>
"@
}

function Set-NoProxy($noProxy)
{
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "User")
    [Environment]::SetEnvironmentVariable("no_proxy", $noProxy, "Process")
}

function Set-Proxy($proxy)
{
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Process")
    $http_proxy = $proxy
    $https_proxy = $proxy
    choco config set proxy $proxy
    $VsConfigWithProxy = Get-VsConfigWithProxy $proxy
    $VsConfigNoProxy = Get-VsConfigNoProxy
    Replace-Chunk-In-File $VsConfigFile $VsConfigNoProxy $VsConfigWithProxy
}

function Clear-Proxy
{
    $oldProxy = $env:https_proxy
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "Process")
    $http_proxy = $null
    $https_proxy = $null
    choco config unset proxy
    $VsConfigWithProxy = Get-VsConfigWithProxy $oldProxy
    $VsConfigNoProxy = Get-VsConfigNoProxy
    Replace-Chunk-In-File  $VsConfigFile $VsConfigWithProxy $VsConfigNoProxy
}

function Replace-Chunk-In-File($filename, $before, $after)
{
    $fileContent =  Get-Content $filename -Raw
    $newFileContent = $fileContent -replace $before, $after
    Set-Content -Path $filename -Value $newFileContent
}

export-modulemember -function Set-Proxy
export-modulemember -function Clear-Proxy
