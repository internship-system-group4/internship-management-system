// Run with tests/Run-GradesExportSmoke.ps1. Uses local fixtures, never live Firebase.
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Web;
using System.Xml.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

class GradesExportSmoke
{
    static readonly XNamespace S = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
    static readonly Dictionary<string, Dictionary<string, object>> fixtures = new Dictionary<string, Dictionary<string, object>>();
    static readonly List<string> reads = new List<string>();
    static bool failReads;
    static int checks;
    static void Check(bool pass, string message) { checks++; if (!pass) throw new Exception(message); }
    static Placement Placement(string id, string company, string supervisor, string academic)
    { return new Placement { Id = id, StudentId = id, StudentName = "Student " + id, CompanyId = company, CompanyName = "Example & Co", CompanySupervisorId = supervisor, AcademicSupervisorId = academic, Status = PlacementStatus.Active }; }
    static void Seed()
    {
        fixtures["users"] = new Dictionary<string, object> {
            { "company1", new CompanySupervisor { Id = "company1", FullName = "Company reviewer", CompanyId = "c1" } },
            { "academic1", new AcademicSupervisor { Id = "academic1", FullName = "Academic reviewer" } },
            { "coordinator1", new Coordinator { Id = "coordinator1", FullName = "Coordinator reviewer" } },
            { "s1", new Student { Id = "s1", FullName = "=SUM(1,2) طالب", StudentNumber = "00123" } },
            { "s2", new Student { Id = "s2", FullName = "Pending Student", StudentNumber = "00124" } },
            { "s3", new Student { Id = "s3", FullName = "Other Student", StudentNumber = "00125" } }
        };
        fixtures["placements"] = new Dictionary<string, object> { { "s1", Placement("s1", "c1", "company1", "academic1") }, { "s2", Placement("s2", "c1", "company1", "academic1") }, { "s3", Placement("s3", "c2", "company2", "academic2") } };
        fixtures["tasks"] = new Dictionary<string, object> { { "t1", new InternshipTask { Id = "t1", PlacementId = "s1", StudentId = "s1", Weight = 1 } }, { "t2", new InternshipTask { Id = "t2", PlacementId = "s2", StudentId = "s2", Weight = 1 } } };
        fixtures["submissions"] = new Dictionary<string, object> { { "sub1", new Submission { Id = "sub1", PlacementId = "s1", StudentId = "s1", TaskId = "t1", SubmittedAt = 10 } }, { "sub2", new Submission { Id = "sub2", PlacementId = "s2", StudentId = "s2", TaskId = "t2", SubmittedAt = 30 } } };
        fixtures["taskEvaluations"] = new Dictionary<string, object> { { "te1", new TaskEvaluation { Id = "te1", PlacementId = "s1", StudentId = "s1", TaskId = "t1", TotalScore = 8, MaxScore = 10, EvaluatedAt = 20 } }, { "te2", new TaskEvaluation { Id = "te2", PlacementId = "s2", StudentId = "s2", TaskId = "t2", TotalScore = 10, MaxScore = 10, EvaluatedAt = 20 } } };
        fixtures["companyFinalEvaluations"] = new Dictionary<string, object> { { "ce1", new FinalCompanyEvaluation { Id = "ce1", PlacementId = "s1", StudentId = "s1", CompanyId = "c1", SupervisorId = "company1", IsSubmitted = true, TotalScore = 9, MaxScore = 10 } } };
        fixtures["academicFinalEvaluations"] = new Dictionary<string, object> { { "ae1", new FinalAcademicEvaluation { Id = "ae1", PlacementId = "s1", StudentId = "s1", AcademicSupervisorId = "academic1", IsSubmitted = true, TotalScore = 7, MaxScore = 10 } } };
        fixtures["completions"] = new Dictionary<string, object> { { "done1", new CompletionRecord { Id = "done1", PlacementId = "s1", StudentId = "s1", Status = CompletionStatus.Approved, Result = "Pass", TaskScorePercent = 80, CompanyScorePercent = 90, AcademicScorePercent = 70, FinalScore = 82.5, ApprovedHours = 160 } } };
        fixtures["trainingHours"] = new Dictionary<string, object>();
    }

    static void UnitChecks(string output)
    {
        Person viewer = (Person)fixtures["users"]["company1"];
        Placement placement = (Placement)fixtures["placements"]["s1"];
        Check(GradeResultsService.CanView(viewer, placement), "Assigned company supervisor denied");
        Check(!GradeResultsService.CanView(viewer, (Placement)fixtures["placements"]["s3"]), "Cross-company access allowed");
        Check(!GradeResultsService.CanView(new CompanySupervisor { Id = "peer", CompanyId = "c1" }, placement), "Another company's supervisor can access confidential grades");
        Check(!GradeResultsService.CanView((Person)fixtures["users"]["s1"], placement), "Student can export confidential grades");
        Check(!GradeResultsService.CanView(new AcademicSupervisor { Id = "other" }, placement), "Unassigned academic supervisor allowed");
        var task = new InternshipTask { Id = "unit-task", PlacementId = "s1", StudentId = "s1", Weight = 1 };
        var evaluation = new TaskEvaluation { TaskId = "unit-task", PlacementId = "s1", StudentId = "s1", EvaluatedAt = 20, TotalScore = 0, MaxScore = 10 };
        var submission = new Submission { TaskId = "unit-task", PlacementId = "s1", StudentId = "s1", SubmittedAt = 10 };
        var companyEvaluation = new FinalCompanyEvaluation { PlacementId = "s1", StudentId = "s1", CompanyId = "c1", SupervisorId = "company1", IsSubmitted = true, TotalScore = 0, MaxScore = 10 };
        Func<GradeResultRow> makeRow = () => GradeResultsService.CreateRow(viewer, placement, (Student)fixtures["users"]["s1"],
            new List<InternshipTask> { task }, new List<TaskEvaluation> { evaluation }, new List<Submission> { submission },
            companyEvaluation, null, null, new List<TrainingHoursEntry>());
        Check(makeRow().TaskPercent == 0 && makeRow().CompanyPercent == 0, "Valid zero scores were treated as missing");
        evaluation.RevisionRequested = true;
        Check(!makeRow().TaskPercent.HasValue, "Revision request retained a grade");
        evaluation.RevisionRequested = false;
        submission.SubmittedAt = 30;
        Check(!makeRow().TaskPercent.HasValue, "A newer submission retained an outdated grade");
        submission.SubmittedAt = 10;
        evaluation.TotalScore = double.NaN;
        Check(!makeRow().TaskPercent.HasValue, "Invalid numeric task grade was exported");
        companyEvaluation.IsSubmitted = false;
        Check(!makeRow().CompanyPercent.HasValue, "Draft company grade was exported");
        companyEvaluation.IsSubmitted = true;
        companyEvaluation.SupervisorId = "peer";
        Check(!makeRow().CompanyPercent.HasValue, "Another author's confidential company grade was exported");
        Check(makeRow().Result == "Pending" && !makeRow().FinalPercent.HasValue, "Unapproved final result was inferred");
        var row = new GradeResultRow { StudentName = "=SUM(1,2) طالب 😀\u0001", StudentNumber = "00123", CompanyName = "A&B <Company>", TaskPercent = 0, CompanyPercent = 90, AcademicPercent = 70, FinalPercent = 82.5, Result = "Pass", ReviewStatus = "Approved" };
        foreach (string role in new[] { "company1", "academic1", "coordinator1" })
        {
            byte[] bytes = ExcelExportService.CreateGradesWorkbook((Person)fixtures["users"][role], new[] { row }, DateTime.UtcNow);
            File.WriteAllBytes(Path.Combine(output, role + ".xlsx"), bytes);
            using (ZipArchive zip = new ZipArchive(new MemoryStream(bytes)))
            {
                Check(zip.Entries.Count == 7, "Workbook package has missing parts");
                foreach (ZipArchiveEntry entry in zip.Entries) using (Stream stream = entry.Open()) XDocument.Load(stream);
                XDocument sheet = ReadXml(zip, "xl/worksheets/sheet1.xml");
                string text = sheet.ToString();
                Check(!sheet.Descendants(S + "f").Any(), "Formula-like text became a formula");
                Check(text.Contains("00123") && text.Contains("طالب") && text.Contains("😀"), "Student numbers or Unicode were damaged");
                Check(!text.Contains("\u0001"), "Invalid XML control character survived");
                Check(sheet.Descendants(S + "v").Any(v => v.Value == "0.825"), "Numeric percentage missing");
                Check(sheet.Descendants(S + "v").Any(v => v.Value == "0"), "A real zero grade was lost");
                Check(text.Contains("Academic grade") == (role != "company1"), "Academic grade exposed to company");
                Check(sheet.Descendants(S + "pane").Any() && sheet.Descendants(S + "autoFilter").Any(), "Frozen header or filters missing");
            }
        }
    }

    static XDocument ReadXml(ZipArchive zip, string path)
    { using (Stream stream = zip.GetEntry(path).Open()) return XDocument.Load(stream); }

    static void ServeFixture(TcpListener listener)
    {
        while (true)
        {
            TcpClient client;
            try { client = listener.AcceptTcpClient(); } catch (SocketException) { return; }
            using (client)
            using (NetworkStream stream = client.GetStream())
            {
            StreamReader reader = new StreamReader(stream, Encoding.ASCII, false, 1024, true);
            string request = reader.ReadLine();
            if (request == null) continue;
            while (!string.IsNullOrEmpty(reader.ReadLine())) { }
            Uri url = new Uri("http://localhost:19081" + request.Split(' ')[1]);
            var query = HttpUtility.ParseQueryString(url.Query);
            string path = url.AbsolutePath.Trim('/');
            string result = "null";
            lock (reads) reads.Add(path + "?" + query["auth"]);
            bool failed = failReads && !path.StartsWith("users/");
            if (failed) result = "{\"error\":\"Fixture read failure\"}";
            else
            {
                string[] parts = path.Replace(".json", "").Split('/');
                Dictionary<string, object> collection;
                if (fixtures.TryGetValue(parts[0], out collection))
                {
                    if (parts.Length > 1) { object value; if (collection.TryGetValue(parts[1], out value)) result = Json.Serialize(value); }
                    else
                    {
                        string order = (query["orderBy"] ?? "").Trim('"');
                        string equal = (query["equalTo"] ?? "").Trim('"');
                        var selected = collection.Where(pair => order.Length == 0 ||
                            Convert.ToString(pair.Value.GetType().GetProperty(order).GetValue(pair.Value, null), CultureInfo.InvariantCulture) == equal)
                            .ToDictionary(pair => pair.Key, pair => pair.Value);
                        result = Json.Serialize(selected);
                    }
                }
            }
            byte[] payload = Encoding.UTF8.GetBytes(result);
            byte[] header = Encoding.ASCII.GetBytes("HTTP/1.1 " + (failed ? "500 Server Error" : "200 OK") + "\r\nContent-Type: application/json\r\nConnection: close\r\nContent-Length: " + payload.Length + "\r\n\r\n");
            stream.Write(header, 0, header.Length);
            stream.Write(payload, 0, payload.Length);
            }
        }
    }

    static HttpWebResponse Request(string root, CookieContainer cookies, string path, string post = null)
    {
        HttpWebRequest request = (HttpWebRequest)WebRequest.Create(root + path);
        request.CookieContainer = cookies;
        request.AllowAutoRedirect = false;
        request.Timeout = 60000;
        if (post != null)
        {
            request.Method = "POST";
            request.ContentType = "application/x-www-form-urlencoded";
            byte[] bytes = Encoding.UTF8.GetBytes(post);
            using (Stream stream = request.GetRequestStream()) stream.Write(bytes, 0, bytes.Length);
        }
        try { return (HttpWebResponse)request.GetResponse(); }
        catch (WebException ex)
        {
            using (var reader = new StreamReader(ex.Response.GetResponseStream()))
                throw new Exception("HTTP failed: " + reader.ReadToEnd());
        }
    }
    static string Body(HttpWebResponse response)
    { using (response) using (StreamReader reader = new StreamReader(response.GetResponseStream())) return reader.ReadToEnd(); }
    static string Form(string html, string action, string result, string search)
    {
        List<string> fields = new List<string>();
        foreach (Match input in Regex.Matches(html, "<input[^>]+type=\"hidden\"[^>]*>"))
        {
            string name = Regex.Match(input.Value, "name=\"([^\"]+)\"").Groups[1].Value;
            string value = HttpUtility.HtmlDecode(Regex.Match(input.Value, "value=\"([^\"]*)\"").Groups[1].Value);
            fields.Add(HttpUtility.UrlEncode(name) + "=" + HttpUtility.UrlEncode(value));
        }
        fields.Add("ctl00%24MainContent%24" + action + "=click");
        fields.Add("ctl00%24MainContent%24ddlResult=" + HttpUtility.UrlEncode(result));
        fields.Add("ctl00%24MainContent%24txtSearch=" + HttpUtility.UrlEncode(search));
        return string.Join("&", fields);
    }

    static void HttpChecks(string root)
    {
        using (HttpWebResponse anonymous = Request(root, new CookieContainer(), "/Pages/Reports/Grades.aspx"))
            Check(anonymous.StatusCode == HttpStatusCode.Redirect && anonymous.Headers["Location"].Contains("Login.aspx"), "Anonymous export access was not denied");
        foreach (string role in new[] { "company1", "academic1", "coordinator1", "s1" })
        {
            CookieContainer cookies = new CookieContainer();
            Body(Request(root, cookies, "/FixtureLogin.aspx?id=" + role));
            if (role == "s1")
            {
                using (HttpWebResponse denied = Request(root, cookies, "/Pages/Reports/Grades.aspx"))
                    Check(denied.StatusCode == HttpStatusCode.Redirect && denied.Headers["Location"].Contains("AccessDenied"), "Student was not denied");
                continue;
            }
            lock (reads) reads.Clear();
            string html = Body(Request(root, cookies, "/Pages/Reports/Grades.aspx"));
            Check(html.Contains("Export to Excel (.xlsx)"), "Export button missing");
            Check(html.Contains(role == "coordinator1" ? "3 students" : "2 students"), "Placement scope is wrong");
            Check(html.Contains("Other Student") == (role == "coordinator1"), "Unassigned student exposed");
            Check(html.Contains("Academic grade") == (role != "company1"), "Academic table column exposed");
            if (role == "company1") lock (reads) Check(!reads.Any(r => r.StartsWith("academicFinalEvaluations")), "Company request fetched academic evaluations");
            using (HttpWebResponse download = Request(root, cookies, "/Pages/Reports/Grades.aspx", Form(html, "btnExport", "Pass", "00123")))
            {
                Check(download.ContentType.Contains("spreadsheetml.sheet"), "Wrong Excel MIME type");
                Check(download.Headers["Content-Disposition"].Contains(".xlsx"), "Missing workbook attachment filename");
                Check(download.Headers["Cache-Control"].Contains("no-store"), "Confidential workbook can be cached");
                MemoryStream bytes = new MemoryStream(); download.GetResponseStream().CopyTo(bytes);
                byte[] payload = bytes.ToArray();
                Check(payload[payload.Length - 22] == 0x50 && payload[payload.Length - 21] == 0x4b, "Page HTML was appended to the workbook");
                using (ZipArchive zip = new ZipArchive(new MemoryStream(payload)))
                {
                    XDocument sheet = ReadXml(zip, "xl/worksheets/sheet1.xml");
                    Check(sheet.Descendants(S + "row").Count() == 2, "Excel did not honor the filters");
                    Check(sheet.ToString().Contains("00123") && !sheet.ToString().Contains("Pending Student"), "Filtered student export is wrong");
                }
            }
            string filtered = Body(Request(root, cookies, "/Pages/Reports/Grades.aspx", Form(html, "btnApply", "Pending", "")));
            Check(filtered.Contains("Pending Student") && !filtered.Contains("=SUM(1,2)"), "Pending filter is wrong");
            Check(filtered.Contains("0 / 1"), "Outdated submission grade was counted as current");
            string empty = Body(Request(root, cookies, "/Pages/Reports/Grades.aspx", Form(html, "btnApply", "Fail", "")));
            Check(empty.Contains("No results to display") && empty.Contains("disabled=\"disabled\""), "Empty export was not disabled");
            failReads = true;
            string failed = Body(Request(root, cookies, "/Pages/Reports/Grades.aspx"));
            failReads = false;
            Check(failed.Contains("Grades could not be loaded"), "Data failure was not handled");
            ((Person)fixtures["users"][role]).IsActive = false;
            using (HttpWebResponse denied = Request(root, cookies, "/Pages/Reports/Grades.aspx", Form(html, "btnExport", "", "")))
                Check(denied.StatusCode == HttpStatusCode.Redirect, "Deactivated user downloaded cached data");
            ((Person)fixtures["users"][role]).IsActive = true;
        }
    }

    static int Main(string[] args)
    {
        Process iis = null;
        TcpListener listener = new TcpListener(IPAddress.Loopback, 19081);
        try
        {
            Seed();
            string app = Path.GetFullPath(args[0]);
            string output = Path.GetFullPath(args[1]);
            Directory.CreateDirectory(output);
            UnitChecks(output);
            listener.Start();
            new Thread(() => ServeFixture(listener)) { IsBackground = true }.Start();
            // A disposable web root keeps fixture login and settings out of the real application.
            string host = Path.Combine(output, "web");
            Directory.CreateDirectory(host);
            foreach (string folder in new[] { "Layout", "Pages", "Assets", "bin" })
                foreach (string file in Directory.GetFiles(Path.Combine(app, folder), "*", SearchOption.AllDirectories))
                {
                    string relative = file.Substring(app.Length + 1);
                    string target = Path.Combine(host, relative);
                    Directory.CreateDirectory(Path.GetDirectoryName(target));
                    File.Copy(file, target, true);
                }
            File.WriteAllText(Path.Combine(host, "Web.config"), "<configuration><appSettings><add key='Firebase.DatabaseUrl' value='http://localhost:19081'/><add key='Firebase.ApiKey' value='fixture'/></appSettings><system.web><compilation debug='true' targetFramework='4.7.2'/><httpRuntime targetFramework='4.7.2'/><customErrors mode='Off'/></system.web></configuration>");
            File.WriteAllText(Path.Combine(host, "FixtureLogin.aspx"), "<%@ Page Language=\"C#\" %><%@ Import Namespace=\"InternshipManagementSystem.Data\" %><%@ Import Namespace=\"InternshipManagementSystem.Security\" %><script runat=\"server\">protected void Page_Load(object sender, EventArgs e) { SessionHelper.SignIn(new UserRepository().GetPerson(Request.QueryString[\"id\"]), Request.QueryString[\"id\"]); Response.Write(\"Fixture session ready\"); }</script>");
            iis = Process.Start(new ProcessStartInfo {
                FileName = @"C:\Program Files\IIS Express\iisexpress.exe", Arguments = "/path:\"" + host + "\" /port:19082 /systray:false",
                UseShellExecute = false, CreateNoWindow = true, RedirectStandardOutput = true, RedirectStandardError = true
            });
            StringBuilder iisLog = new StringBuilder();
            iis.OutputDataReceived += (sender, e) => { lock (iisLog) iisLog.AppendLine(e.Data); };
            iis.ErrorDataReceived += (sender, e) => { lock (iisLog) iisLog.AppendLine(e.Data); };
            iis.BeginOutputReadLine(); iis.BeginErrorReadLine();
            bool ready = false;
            for (int attempt = 0; attempt < 30 && !ready; attempt++)
            {
                try { Body(Request("http://localhost:19082", new CookieContainer(), "/FixtureLogin.aspx?id=coordinator1")); ready = true; }
                catch { if (iis.HasExited) throw new Exception("IIS Express exited: " + iis.ExitCode + " " + iisLog); Thread.Sleep(500); }
            }
            Check(ready, "IIS fixture did not start");
            HttpChecks("http://localhost:19082");
            Console.WriteLine("PASS: " + checks + " checks. Workbooks: " + output);
            if (args.Contains("--serve"))
            {
                Console.WriteLine("Preview: http://localhost:19082/FixtureLogin.aspx?id=coordinator1 then /Pages/Reports/Grades.aspx");
                while (true) Thread.Sleep(1000);
            }
            return 0;
        }
        catch (Exception ex) { Console.Error.WriteLine(ex); return 1; }
        finally { listener.Stop(); if (iis != null && !iis.HasExited) { iis.Kill(); iis.WaitForExit(); } }
    }
}
