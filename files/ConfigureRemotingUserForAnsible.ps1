#!powershell
#Requires -Version 3.0

# Support -Verbose option
#[CmdletBinding()]

Function Write-Log
{
    $Message = $args[0]
    Write-EventLog -LogName Application -Source $EventSource -EntryType Information -EventId 1 -Message $Message
}

Function Write-VerboseLog
{
    $Message = $args[0]
    Write-Verbose $Message
    Write-Log $Message
}

Function Write-HostLog
{
    $Message = $args[0]
    Write-Host $Message
    Write-Log $Message
}

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
if (-Not $myWindowsPrincipal.IsInRole($adminRole))
{
    Write-Host "ERROR: You need elevated Administrator privileges in order to run this script."
    Write-Host "       Start Windows PowerShell by using the Run as Administrator option."
    Exit 2
}

# Create new local Admin user for script purposes

$Computer = [ADSI]"WinNT://$Env:COMPUTERNAME,Computer"

$LocalAdmin = $Computer.Create("User", "jenkins")
$LocalAdmin.SetPassword("Jenkins1234$")
$LocalAdmin.SetInfo()
$LocalAdmin.FullName = "Local Jenkins Admin by Powershell"
$LocalAdmin.SetInfo()
$LocalAdmin.UserFlags = 64 + 65536 # ADS_UF_PASSWD_CANT_CHANGE + ADS_UF_DONT_EXPIRE_PASSWD
$LocalAdmin.SetInfo()

$group = [ADSI]("WinNT://"+$env:COMPUTERNAME+"/administrators,group")
$group.add("WinNT://jenkins,user")

#Write-VerboseLog "PS Remoting User has been successfully configured for Ansible."
