# https://keithga.wordpress.com/2013/09/24/microsoft-account-automation-in-windows-8/
# keithga

[CmdletBinding(SupportsShouldProcess=$true)]
param(
       [Parameter(Mandatory=$true,Position=0)]
       [string] $UserName = ".",
       [Parameter(Mandatory=$true,Position=1)]
       [string] $MicrosoftAccount,
       [Parameter(Mandatory=$false,Position=2)]
       [string] $PSCommand = "PSExec.exe"
)

Write-Verbose "Test for administrative privelages"

if (!([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ))
{
    throw "Not Running in the Administrative Context"
}

Write-Verbose "Run under the local System Context"

If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).Identities.User.Value -ne "S-1-5-18")
{
    Write-Verbose "Find the PSExec.exe command"
    if ( (get-command $PSCommand -ErrorAction SilentlyContinue) -eq $null )
    {
        WRite-host "Missing PSExec.exe command. Force local download..."
        Start-BitsTransfer -Source "http://live.sysinternals.com/psexec.exe" -Destination "$env:SystemRoot\System32\PSExec.exe" -DisplayName "PSExec" -TransferType Download
    }

    Write-Verbose "NotRunnin in the System Context - run PSExec.exe"
    & psexec.exe /AcceptEula -e -i -s Powershell.exe  -noprofile -executionpolicy bypass $MyInvocation.Line
    exit
}

Write-Verbose "Find the Local User Account $UserName"

$objUser = New-Object System.Security.Principal.NTAccount($UserName)
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$c = New-Object 'byte[]' $strsid.BinaryLength
$strSID.GEtBinaryForm($c,0)

Write-Verbose "Enumerate through all local Accounts in SAM registry and find the SID: $($StrSID.Value)"

$FoundUser = $NULL
foreach ($user in get-childitem "HKLM:\Sam\Sam\Domains\Account\Users")
{ 
    if ( $User.GetValue("V").length -gt 0 )
    {
        $v = $User.GetValue("V")
        foreach ( $i in ($v.length-$c.Length)..0) 
        {
            if ((compare-object $c $v[$i..($i-1+$c.length)] -sync 0).length -eq 0)
            {
                $FoundUSer = $User
                break
            }
        }
    }
}

if ($FoundUser -is [object])
{

    write-Host "Found USer: $($FoundUSer.PSPAth) now write $MicrosoftAccount"

    if ( $FoundUSer.GetValue("InternetUserName") -is [byte[]] )
    {
        write-warning "UserName already entered: $($user.GetValue('InternetUserName'))"
    }
    else
    {
        Set-ItemProperty $FoundUser.PSPath "ForcePasswordReset"   ([byte[]](0,0,0,0))
        Set-ItemProperty $FoundUser.PSPath "InternetUserName"     ([System.Text.Encoding]::UniCode.GetBytes($MicrosoftAccount))
        Set-ItemProperty $FoundUser.PSPath "InternetProviderGUID" ([GUID]("d7f9888f-e3fc-49b0-9ea6-a85b5f392a4f")).TOByteArray()
    }
}
