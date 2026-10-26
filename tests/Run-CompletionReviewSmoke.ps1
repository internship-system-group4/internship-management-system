param([int]$DatabasePort=0, [int]$WebPort=0)
$ErrorActionPreference = 'Stop'
function Get-FreeLoopbackPort {
    $listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
    $listener.Start()
    $port = $listener.LocalEndpoint.Port
    $listener.Stop()
    return $port
}
if ($DatabasePort -eq 0) { $DatabasePort = Get-FreeLoopbackPort }
if ($WebPort -eq 0) { $WebPort = Get-FreeLoopbackPort }

$repoRoot = Split-Path -Parent $PSScriptRoot
$appPath = Join-Path $repoRoot 'InternshipManagementSystem/InternshipManagementSystem'
$outputPath = Join-Path $PSScriptRoot 'bin/completion-review'
New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$frameworkPath = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319'
$assembly = Join-Path $appPath 'bin/InternshipManagementSystem.dll'
Copy-Item -LiteralPath $assembly -Destination $outputPath -Force
$testExe = Join-Path $outputPath 'CompletionReviewSmoke.exe'
& (Join-Path $frameworkPath 'csc.exe') /nologo /out:$testExe /r:$assembly /r:System.Web.dll /r:System.Web.Extensions.dll (Join-Path $PSScriptRoot 'CompletionReviewSmoke.cs')
if ($LASTEXITCODE -ne 0) { throw 'Completion smoke test compilation failed.' }
"<configuration><appSettings><add key='Firebase.DatabaseUrl' value='http://localhost:$DatabasePort'/><add key='Firebase.ApiKey' value='fixture'/><add key='Firebase.ReadCacheSeconds' value='0'/></appSettings></configuration>" | Set-Content -LiteralPath ($testExe + '.config') -Encoding utf8
& $testExe $appPath $outputPath $DatabasePort $WebPort
if ($LASTEXITCODE -ne 0) { throw 'Completion review smoke tests failed.' }
