
#http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows8-RT-KB2799888-x64.msu

if ($PSVersionTable.psversion.Major -ge 4)
{
    write-host "Powershell 4 Installed already you don't need this"
    Exit-PSSession
}

$powershellpath = "C:\powershell"

function download-file
{
    param ([string]$path, [string]$local)
    $client = new-object system.net.WebClient
    $client.Headers.Add("user-agent", "PowerShell")
    $client.downloadfile($path, $local)
}

if (!(test-path $powershellpath))
{
    New-Item -ItemType directory -Path $powershellpath
}

if (($PSVersionTable.CLRVersion.Major) -lt 4)
{
    $DownloadUrl = "http://download.microsoft.com/download/B/A/4/BA4A7E71-2906-4B2D-A0E1-80CF16844F5F/dotNetFx45_Full_setup.exe"
    $FileName = $DownLoadUrl.Split('/')[-1]
    download-file $downloadurl "$powershellpath\$filename"
    ."$powershellpath\$filename"
}

#You may need to reboot after the .NET 4.5 install if so just run the script again.

if ([System.IntPtr]::Size -eq 4)
{
    $DownloadUrl = "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x86-MultiPkg.msu"
}
Else
{
    $DownloadUrl = "http://download.microsoft.com/download/3/D/6/3D61D262-8549-4769-A660-230B67E15B25/Windows6.1-KB2819745-x64-MultiPkg.msu"
}

$FileName = $DownLoadUrl.Split('/')[-1]
download-file $downloadurl "$powershellpath\$filename"

."$powershellpath\$filename"
