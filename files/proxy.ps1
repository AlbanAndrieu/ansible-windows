#!powershell

# See https://daveshap.github.io/DavidShapiroBlog/powershell/kb/2021/03/12/install-powershell-modules.html

$proxy = 'http://10.21.185.171:3128'  # update this
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
[system.net.webrequest]::defaultwebproxy = new-object system.net.webproxy($proxy)
[system.net.webrequest]::defaultwebproxy.credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
[system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true

Install-PackageProvider -Name nuget -Scope AllUsers -Confirm:$false -Force -MinimumVersion 2.8.5.201
Register-PSRepository -Default -verbose
Install-Module -Name PowerShellGet -Scope AllUsers -Confirm:$false -Force -AllowClobber -MinimumVersion 2.2.4 -SkipPublisherCheck

Get-PackageProvider -ListAvailable

exit
