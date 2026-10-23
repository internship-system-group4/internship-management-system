$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Parent $PSScriptRoot
$appPath = Join-Path $repoRoot 'InternshipManagementSystem/InternshipManagementSystem'
$testOutput = Join-Path $PSScriptRoot 'bin/email-notifications'
New-Item -ItemType Directory -Path $testOutput -Force | Out-Null
$testExe = Join-Path $testOutput 'EmailNotificationsSmoke.exe'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET/Framework64/v4.0.30319/csc.exe'
$sources = @((Join-Path $PSScriptRoot 'EmailNotificationsSmoke.cs'))
$sources += Get-ChildItem (Join-Path $appPath 'Common'), (Join-Path $appPath 'Models') -Filter '*.cs' | Select-Object -ExpandProperty FullName
foreach ($name in @('Json', 'RepositoryBase', 'NotifyingRepositoryBase', 'UserRepository', 'PlacementRepository', 'TaskRepository', 'SubmissionRepository', 'EvaluationRepository', 'CompletionRepository', 'HoursRepository', 'ApplicationRepository', 'MeetingRepository')) {
    $sources += Join-Path $appPath "Data/$name.cs"
}
$sources += Join-Path $appPath 'Services/EmailNotificationService.cs'
$sources += Join-Path $appPath 'Security/SessionHelper.cs'
$sources += Join-Path $appPath 'Services/CompletionReviewService.cs'
$sources += Join-Path $appPath 'Services/GradingService.cs'
& $compiler /nologo /define:TRACE /out:$testExe /r:System.Web.dll /r:System.Web.Extensions.dll /r:System.Configuration.dll $sources
if ($LASTEXITCODE -ne 0) { throw 'Notification smoke test compilation failed.' }
# Select a free loopback port. The fixture never connects to real SMTP or Firebase.
$portProbe = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, 0)
$portProbe.Start()
$smtpPort = $portProbe.LocalEndpoint.Port
$portProbe.Stop()
foreach ($enabled in @('true', 'false')) {
    $config = @"
<configuration><appSettings>
<add key="Email.Enabled" value="$enabled"/>
<add key="Email.ApplicationUrl" value="https://example.test/uims/"/>
<add key="Email.FromAddress" value="uims@example.test"/>
<add key="Email.FromName" value="UIMS"/>
<add key="Email.SmtpHost" value="127.0.0.1"/>
<add key="Email.SmtpPort" value="$smtpPort"/>
<add key="Email.EnableSsl" value="false"/>
</appSettings></configuration>
"@
    [IO.File]::WriteAllText("$testExe.config", $config)
    & $testExe $smtpPort
    if ($LASTEXITCODE -ne 0) { throw "Notification smoke tests failed (enabled=$enabled)." }
}
