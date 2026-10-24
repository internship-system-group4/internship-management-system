param()
$ErrorActionPreference = 'Stop'
$projectPath = Join-Path (Split-Path -Parent $PSScriptRoot) 'InternshipManagementSystem/InternshipManagementSystem'
$secretsPath = Join-Path $projectPath 'App_Secrets.config'
if (-not (Test-Path -LiteralPath $secretsPath)) { throw 'Add your local App_Secrets.config first; existing Firebase settings are preserved.' }
$senderAddress = (Read-Host 'Gmail sender address').Trim()
try { $parsedAddress = [Net.Mail.MailAddress]::new($senderAddress) } catch { throw 'Enter a valid Gmail address.' }
if ($parsedAddress.Address -ne $senderAddress) { throw 'Enter only the sender email address.' }
$applicationUrl = (Read-Host 'Application URL including any virtual directory (example https://localhost:44313/)').Trim()
$parsedUrl = $null
if (-not [Uri]::TryCreate($applicationUrl, [UriKind]::Absolute, [ref]$parsedUrl) -or $parsedUrl.Scheme -notin @('https','http') -or $parsedUrl.Query -or $parsedUrl.Fragment -or $parsedUrl.UserInfo) { throw 'Enter a valid application URL.' }
$appPassword = Read-Host 'Google App Password (input is hidden; do not use your normal password)' -AsSecureString
if ($appPassword.Length -eq 0) { throw 'An app password is required.' }
$passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($appPassword)
try {
    $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer).Replace(' ', '')
    [xml]$settings = Get-Content -LiteralPath $secretsPath
    $values = @{
        'Notifications.Enabled' = 'true'; 'Email.Enabled' = 'true';
        'Email.ApplicationUrl' = $applicationUrl; 'Email.FromAddress' = $senderAddress;
        'Email.FromName' = 'University Internship Management System';
        'Email.SmtpHost' = 'smtp.gmail.com'; 'Email.SmtpPort' = '587'; 'Email.EnableSsl' = 'true';
        'Email.SmtpUsername' = $senderAddress; 'Email.SmtpPassword' = $plainPassword
    }
    foreach ($key in $values.Keys) {
        $entry = $settings.appSettings.add | Where-Object { $_.key -eq $key } | Select-Object -First 1
        if (-not $entry) { $entry = $settings.CreateElement('add'); $entry.SetAttribute('key', $key); [void]$settings.appSettings.AppendChild($entry) }
        $entry.SetAttribute('value', $values[$key])
    }
    $settings.Save($secretsPath)
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    $plainPassword = $null
    $appPassword.Dispose()
}
Write-Host 'Gmail settings saved locally. Restart IIS Express. No test email was sent.'
