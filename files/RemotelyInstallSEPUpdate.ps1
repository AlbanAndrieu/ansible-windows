#Script to update a windows vm from 14.2 RU1 to 14.2 RU2
#ATTENTION  :  The server will be automaticall rebooted


#REQUIRED PARAMETERS

$machineListFile = "" #provide full path to your json file containing a simple array of machines to update

#Location for the sep install executable to download locally
$sepClientRemoteLocation = "\\parpswbuild01\dropbox\Europe_Server_setup_14.2.RU2.MP1_64bit.exe" #you might want to change this but this server is secured

$chosenUnpackPath = "D:\uniqueEmptyLocation"  #this is full path to a folder on the remote machine that will be used to copy over and run the. If it does not exist it will be created
#Set up credentials to allow remote access to servers
$userName = "" #supply user name
$userPwd ="" #supply password

#NO MORE PARAMETERS ARE REQUIRED

$pwdSecure = ConvertTo-SecureString -String $userPwd -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName,$pwdSecure

#load up machine list
$allNodes = Get-Content $machineListFile | out-string | ConvertFrom-Json


function CopyAndInstall-SEPAgent
{
    param
    (
        [string]$serverName,
        [System.Management.Automation.PSCredential]$credential,
        [string]$unpackPath
    )

    $remoteDir = Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock {param ($p1) if(!(Test-Path $p1)){ mkdir $p1} else{Get-Item $p1}} -ArgumentList $unpackPath
    $remoteDirName = $remoteDir.FullName
    $session = New-PSSession -ComputerName $serverName -Credential $credential
    Copy-Item -Path $sepClientRemoteLocation -Destination $remoteDirName -ToSession $session
     $commandBlock = {
        param ($p1)
        cmd /c "$p1"
        }
    $pathToLocalInstall = $remoteDirName | Join-Path -ChildPath ($sepClientRemoteLocation -replace ".*\\|/","")
    $installCommand = Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock $commandBlock -ArgumentList $pathToLocalInstall
	#server reboot - comment out if you do not want to reboot, but usually a reboot will be required
    Restart-Computer -ComputerName $serverName -Credential $credential -Force
}

foreach ($node in $allNodes)
{
    CopyAndInstall-SEPAgent -serverName $node -credential $credential -unpackPath $chosenUnpackPath
}
