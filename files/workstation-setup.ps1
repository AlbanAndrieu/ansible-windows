#!powershell
function Install-NeededFor {
param([string]$packageName = '')
  if ($packageName -eq '') {return $false}

  $yes = '6'
  $no = '7'
  $msgBoxTimeout='-1'

  $answer = $msgBoxTimeout
  try {
    $timeout = 10
    $question = "Do you need to install $($packageName)? Defaults to 'Yes' after $timeout seconds"
    $msgBox = New-Object -ComObject WScript.Shell
    $answer = $msgBox.Popup($question, $timeout, "Install $packageName", 0x4)
  }
  catch {
  }

  if ($answer -eq $yes -or $answer -eq $msgBoxTimeout) {
    write-host 'returning true'
    return $true
  }
  return $false
}

#install chocolatey
if (Install-NeededFor 'chocolatey') {
  iex ((new-object net.webclient).DownloadString('http://bit.ly/psChocInstall'))
}

# install nuget
cinst nuget.commandline

cinst .\workstation-packages.config

# install ruby.devkit, and ruby if they are missing
#if (Install-NeededFor 'ruby / ruby devkit') {
#  cinst ruby2.devkit
#  #cinstm ruby #devkit install will automatically install ruby
#}

#perform ruby updates and get gems
#gem update --system
#gem install rake
#gem install bundler
