
Get-ChildItem $Env:DOCKER_ENTRYPOINT_DIR -ErrorAction Ignore | % { Write-Host $_.FullName; & $_.FullName }
if ($env:DOCKER_ENV_HIDEVARS) { $env:DOCKER_ENV_HIDEVARS.Split() | % { Remove-Item -Force env:$_ -ErrorAction Ignore } }

Write-Host ($Args -Join " ")
Invoke-Expression ($Args -Join " ")
