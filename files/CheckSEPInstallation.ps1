#!powershell

#script to report on SEP state of servers
#REQUIRED PARAMETERS
$machineListFile = "" #provide full path to your json file containing a simple array of machines to check

$userName = "" #supply user name which has admin credentials on the vms
$userPwd ="" #supply password for user


#NO MORE PARAMETERS REQUIRED

$pwdSecure = ConvertTo-SecureString -String $userPwd -AsPlainText -Force
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $userName,$pwdSecure

#load up machine list
$allNodes = Get-Content $machineListFile | out-string | ConvertFrom-Json


function Get-SepServerIP
{

     param(
        [string]$serverName,
        [System.Management.Automation.PSCredential]$credential
    )



    Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock { Get-ItemProperty -Path "HKLM:SOFTWARE\WOW6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\public-opstate" -Name LastServerIP | Select-Object -ExpandProperty LastServerIP}

}
function Check-SEPServicesUp
{

     param(
        [string]$serverName,
        [System.Management.Automation.PSCredential]$credential
    )

    $sepMS = Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock {Get-Service | where-object -property Name -match SepMasterService}
    $sepWSc = Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock {Get-Service | where-object -property Name -match WscSvc}
    if ($sepMS.Status -match "Running" -and $sepWSc.Status -match "Running")
    {
        $true
    }
    else
    {
        Write-Host "status of SepMasterService is $sepMS.Status"
        Write-Host "Status of SEP WSC is $sepWSc.Status"
        $false
    }
}

function Get-SepDefinitionsDate
{

     param(
        [string]$serverName,
        [System.Management.Automation.PSCredential]$credential
    )

    Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock { Get-ItemProperty -Path "HKLM:SOFTWARE\WOW6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion\public-opstate" -Name LatestVirusDefsDate | Select-Object -ExpandProperty LatestVirusDefsDate}

}

function Get-SEPVersion
{

     param(
        [string]$serverName,
        [System.Management.Automation.PSCredential]$credential
    )

    Invoke-Command -ComputerName $serverName -Credential $credential -ScriptBlock { Get-ItemProperty -Path "HKLM:SOFTWARE\WOW6432Node\Symantec\Symantec Endpoint Protection\CurrentVersion" -Name PRODUCTVERSION | Select-Object -ExpandProperty PRODUCTVERSION}
 }



foreach ($node in $allNodes)
{

   $version =  Get-SEPVersion -serverName $node -credential $credential
   $defdate =  Get-SepDefinitionsDate -serverName $node -credential $credential
    $ipa = Get-SepServerIP -serverName $node -credential $credential
    $checkSepServices = Check-SEPServicesUp -serverName $node -credential $credential
   if ($checkSepServices -and $version -match "14\.2\.5" -and ($defdate -match "2020-03-30" -or $defdate -match "2020-03-31") -and ($ipa -match "52.170.17.211" -or $ipa -match "10.199.5." ))
   {
        Write-host "$node - SEP agent validated - SEP version $version  Definitions date $defdate  SEP services are running  SEP manager ip is $ipa"
    }
    else
    {
        if (!($checkSepServices))
        {
            Write-Host "$node SEP services not running"
        }
        if ($version -notmatch "14\.2\.5")
        {
           Write-host "$node - SEP agent is $version"
        }
        if (!($defdate -match "2020-03-30" -or $defdate -match "2020-03-31"))
        {
            Write-host "$node - definitions date is $defdate"
        }
        if (!($ipa -match "52.170.17.211" -or $ipa -match "10.199.5."))
        {
            Write-host "$node - ip of sepm is not known or incorrect it is : $ipa"
        }
    }

}
