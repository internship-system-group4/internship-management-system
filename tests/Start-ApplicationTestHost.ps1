param([int]$Port = 57982)
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path $PSScriptRoot -Parent
$source = Join-Path $repoRoot 'InternshipManagementSystem/InternshipManagementSystem'
$testRoot = Join-Path ([IO.Path]::GetTempPath()) ('uims-o01-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory $testRoot | Out-Null
# Fixture authentication exists only in this disposable copy, never the real app.
Get-ChildItem $source -Exclude App_Secrets.config,obj,.taste-skill | Copy-Item -Destination $testRoot -Recurse
@'
<appSettings>
  <add key="Firebase.DatabaseUrl" value="http://127.0.0.1:4900/firebase" />
  <add key="Firebase.ApiKey" value="local-test-only" />
</appSettings>
'@ | Set-Content (Join-Path $testRoot 'App_Secrets.config')
@'
<%@ Page Language="C#" %>
<%@ Import Namespace="InternshipManagementSystem.Data" %>
<%@ Import Namespace="InternshipManagementSystem.Security" %>
<script runat="server">
protected void Page_Load(object sender, EventArgs e) {
    var user = new UserRepository().GetPerson(Request.QueryString["user"] ?? "student-one");
    SessionHelper.SignIn(user, "local-fixture-token");
    if (user == null) { Response.StatusCode = 404; Response.Write("Unknown test user"); return; }
    string destination = user.Role == InternshipManagementSystem.Common.UserRole.Student
        ? "~/Pages/Student/Apply.aspx?opportunityId=internship-one"
        : user.Role == InternshipManagementSystem.Common.UserRole.CompanySupervisor
            ? "~/Pages/Company/Applications.aspx" : user.DashboardUrl;
    Response.Redirect(ResolveUrl(destination));
}
</script>
'@ | Set-Content (Join-Path $testRoot '__fixture.aspx')
$iis = Start-Process 'C:/Program Files (x86)/IIS Express/iisexpress.exe' -ArgumentList @("/path:$testRoot", "/port:$Port") -PassThru -WindowStyle Hidden -RedirectStandardOutput (Join-Path $testRoot 'iis.log') -RedirectStandardError (Join-Path $testRoot 'iis.err')
[pscustomobject]@{ TestRoot=$testRoot; ProcessId=$iis.Id; Url="http://localhost:$Port" } | ConvertTo-Json
