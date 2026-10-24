param([switch]$Serve)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$appPath = Join-Path $repoRoot 'InternshipManagementSystem/InternshipManagementSystem'
$testOutput = Join-Path $PSScriptRoot 'bin/grades-export'
New-Item -ItemType Directory -Path $testOutput -Force | Out-Null
$frameworkPath = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
$assembly = Join-Path $appPath 'bin/InternshipManagementSystem.dll'
Copy-Item -LiteralPath $assembly -Destination $testOutput -Force
$testExe = Join-Path $testOutput 'GradesExportSmoke.exe'
& (Join-Path $frameworkPath 'csc.exe') /nologo /out:$testExe /r:$assembly /r:System.Web.dll /r:System.Web.Extensions.dll /r:System.Xml.Linq.dll /r:System.IO.Compression.dll (Join-Path $PSScriptRoot 'GradesExportSmoke.cs')
if ($LASTEXITCODE -ne 0) { throw 'Smoke test compilation failed.' }
$testArgs = @($appPath, $testOutput)
if ($Serve) { $testArgs += '--serve' }
& $testExe @testArgs
if ($LASTEXITCODE -ne 0) { throw 'Grades export smoke tests failed.' }
