$VsConfigFile = "C:\Program Files (x86)\Microsoft Visual Studio 14.0\Common7\IDE\devenv.exe.config"
$proxy = ""

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

function Get-VsConfigWithProxy
{
    return @"
        <system.net>
            <settings>
                <ipv6 enabled="true"/>
            </settings>
            <defaultProxy useDefaultCredentials="true" enabled="true">
                <proxy bypassonlocal="true" proxyaddress="${script:proxy}" />
            </defaultProxy>
        </system.net>
"@
}

function Set-Proxy($proxy)
{
    $script:proxy = $proxy
    [Environment]::SetEnvironmentVariable("no_proxy", "localhost,127.0.0.1,manager.petnetsolutions.net", "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "User")
    [Environment]::SetEnvironmentVariable("no_proxy", "localhost,127.0.0.1,manager.petnetsolutions.net", "Process")
    [Environment]::SetEnvironmentVariable("http_proxy", $proxy, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $proxy, "Process")
    $http_proxy = $proxy
    $https_proxy = $proxy
    choco config set proxy $proxy
    $VsConfigWithProxy = Get-VsConfigWithProxy
    $VsConfigNoProxy = Get-VsConfigNoProxy
    Replace-Chunk-In-File $VsConfigFile $VsConfigNoProxy $VsConfigWithProxy
}

function Clear-Proxy
{
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "User")
    [Environment]::SetEnvironmentVariable("http_proxy", $null, "Process")
    [Environment]::SetEnvironmentVariable("https_proxy", $null, "Process")
    $http_proxy = $null
    $https_proxy = $null
    choco config unset proxy
    $VsConfigWithProxy = Get-VsConfigWithProxy
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
