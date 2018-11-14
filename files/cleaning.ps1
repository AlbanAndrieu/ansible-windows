#!powershell

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)

# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator

# Check to see if we are currently running "as Administrator"
#if (-Not $myWindowsPrincipal.IsInRole($adminRole))
#{
#    Write-Host "ERROR: You $myWindowsID need elevated $adminRole privileges in order to run this script."
#    Write-Host "       Start Windows PowerShell by using the Run as Administrator option."
#    Exit 2
#}

# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
{
   # We are running "as Administrator" - so change the title to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue";
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator

   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";


    ###Find if current path is a mapped network drive path (device type = 4)
    if ((gwmi Win32_LogicalDisk -filter "DeviceID = '$((Get-Location).Drive.Name):'").DriveType -eq 4) {
        ###Find UNC path of current drive letter
        $unc = (gwmi Win32_LogicalDisk -filter "DeviceID = '$((Get-Location).Drive.Name):'").ProviderName
        ###Replace drive letter with UNC drive path (ex: Mapped drive Z:\Testing\Dir changes to \\Server\Share\Testing\Dir)
        $ScriptPath = $((Get-Location).Path) -replace "^$((Get-Location).Drive.name):", $unc
        $ScriptPath += "\$($script:myInvocation.MyCommand.Name)"
    } else {
        $ScriptPath = $myInvocation.MyCommand.Definition;
    }

   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $ScriptPath;

   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";

   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);

   # Exit from the current, unelevated, process
   exit
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

# Enable output streams 3-6
$WarningPreference = 'Continue'
$VerbosePreference = 'Continue'
$DebugPreference = 'Continue'
$InformationPreference = 'Continue'

$limit = (Get-Date).AddDays(-7)
$path = "C:\\Jenkins-Slave\\workspace"

function Remove-PathToLongDirectory 
{
    # To prevent below error with very long paths created by Jenkins:
    #
    # Remove-Item : The specified path, file name, or both are too long. The fully 
    # qualified file name must be less than 260 characters, and the directory name 
    # must be less than 248 characters.
    Param(
        [string]$directory
    )

    # create a temporary (empty) directory
    $parent = [System.IO.Path]::GetTempPath()
    [string] $name = [System.Guid]::NewGuid()
    $tempDirectory = New-Item -ItemType Directory -Path (Join-Path $parent $name)

    robocopy /MIR $tempDirectory.FullName $directory | out-null
    Remove-Item $directory -Force -Recurse |
    Remove-Item $tempDirectory -Force -Recurse 
}


$directoriesToRemove = (Get-ChildItem -Path $path |
    Where-Object {
        $_.PSIsContainer -and $_.CreationTime -lt $limit       
    }
)

ForEach ($directory in $directoriesToRemove) {
    Echo "will remove directory: $directory"
    Remove-PathToLongDirectory "$path\\$directory" 
}

# $tempfolders = @( "D:\Jenkins-Slave\workspace\*" )
# Remove-Item $tempfolders -force -recurse -verbose
# 
# $tempfolders = @( "E:\Jenkins-Slave\workspace\*" )
# Remove-Item $tempfolders -force -recurse -verbose

Write-Host -NoNewLine "Press any key to continue...";
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown");
