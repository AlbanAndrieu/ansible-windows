#!powershell

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

$tempfolders = @( "C:\temp\*")
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "C:\Windows\Temp\*")
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "C:\Windows\Prefetch\*")
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "C:\Documents and Settings\*\Local Settings\temp\*")
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @(  "C:\Users\*\Appdata\Local\Temp\*")
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "D:\Jenkins-Slave\workspace\*" )
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "E:\Jenkins-Slave\workspace\*" )
Remove-Item $tempfolders -force -recurse -verbose

$tempfolders = @( "E:\Jenkins-Slave-Other\workspace\*" )
Remove-Item $tempfolders -force -recurse -verbose
