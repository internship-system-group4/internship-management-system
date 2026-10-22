param([int]$Port=57990,[int]$SimulationPort=4910)
$ErrorActionPreference='Stop'
# The existing host copies into a unique temporary directory and configures RTDB locally.
$hostInfo = & (Join-Path $PSScriptRoot 'Start-ApplicationTestHost.ps1') -Port $Port -SimulationPort $SimulationPort | ConvertFrom-Json
$sourcePath = Join-Path $hostInfo.TestRoot 'Services/AuthService.cs'
$sourceText = [IO.File]::ReadAllText($sourcePath)
# Only the disposable copy's hard-coded Auth base is changed, preserving real HTTP calls.
$sourceText = $sourceText.Replace('https://identitytoolkit.googleapis.com/v1/accounts:', "http://127.0.0.1:$SimulationPort/auth/v1/accounts:")
[IO.File]::WriteAllText($sourcePath,$sourceText)
$projectPath=Join-Path $hostInfo.TestRoot 'InternshipManagementSystem.csproj'
$packageRoot=Join-Path (Split-Path $PSScriptRoot -Parent) 'InternshipManagementSystem/packages/'
$projectText=[IO.File]::ReadAllText($projectPath).Replace('..\packages\',$packageRoot.Replace('/','\'))
[IO.File]::WriteAllText($projectPath,$projectText)
$builder='C:/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Current/Bin/MSBuild.exe'
& $builder $projectPath /t:Rebuild /p:Configuration=Debug /verbosity:quiet /nologo | Out-Null
if($LASTEXITCODE -ne 0){throw 'Disposable login test host did not compile.'}
$hostInfo | ConvertTo-Json
