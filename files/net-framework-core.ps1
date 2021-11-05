#!powershell

# See https://blogs.sap.com/2020/06/25/how-to-install-the-.net-framework-3.5-on-windows-server-2016-and-later/

Get-WindowsFeature -Name "NET-Framework-Core"
Install-WindowsFeature -Name "NET-Framework-Core" -Source "D:\Sources\SxS"

exit
