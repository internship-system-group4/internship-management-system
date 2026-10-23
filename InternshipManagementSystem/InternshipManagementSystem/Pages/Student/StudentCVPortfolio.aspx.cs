
using System;
using System.IO;
using System.Linq;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class StudentCVPortfolio : StudentPage
    {
        protected CvPortfolioData Saved =
            new CvPortfolioData();

        protected string Notice = "";
        protected bool NoticeIsError = false;

        private const int MaxFileBytes = 5 * 1024 * 1024;

        public class CvPortfolioData
        {
            public string CvUrl { get; set; }
            public string PortfolioUrl { get; set; }
            public string CvFileName { get; set; }
            public string CvStorageName { get; set; }
            public string PortfolioFileName { get; set; }
            public string PortfolioStorageName { get; set; }
            public long UpdatedAt { get; set; }
        }

        private string StudentId
        {
            get
            {
                return CurrentStudent == null
                    ? ""
                    : CurrentStudent.Id;
            }
        }

        private string DataPath
        {
            get
            {
                return "studentCvPortfolios/" + StudentId;
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            if (Session != null)
                ViewStateUserKey = Session.SessionID;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (CurrentStudent == null ||
                !ValidFirebaseKey(StudentId))
            {
                ShowError(L.T("Student.StudentCVPortfolio.StudentAccountIsUnavailable"));
                return;
            }

            try
            {
                LoadSaved();

                if (Request.QueryString["download"] != null)
                {
                    DownloadFile(Request.QueryString["download"]);
                    return;
                }

                if (!IsPostBack)
                    return;

                string action = Request.Form["cvAction"];

                if (action == "save")
                    SaveChanges();
                else if (action == "removeCv")
                    RemoveFile(true);
                else if (action == "removePortfolio")
                    RemoveFile(false);

                LoadSaved();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Student CV Portfolio: " + ex);

                ShowError(
                    L.T("Student.StudentCVPortfolio.UnableToLoadOrSaveYour"));
            }
        }

        private static bool ValidFirebaseKey(string value)
        {
            return !string.IsNullOrWhiteSpace(value) &&
                value.IndexOfAny(
                    new char[] { '.', '#', '$', '[', ']', '/' }
                ) < 0;
        }

        private void LoadSaved()
        {
            string etag;

            string json = FirebaseContext.GetWithEtag(
                DataPath, out etag);

            Saved = string.IsNullOrWhiteSpace(json) ||
                    json.Trim() == "null"
                ? new CvPortfolioData()
                : Json.Deserialize<CvPortfolioData>(json);

            if (Saved == null)
                Saved = new CvPortfolioData();
        }

        private bool UpdateData(Action<CvPortfolioData> change)
        {
            string etag;

            string json = FirebaseContext.GetWithEtag(
                DataPath, out etag);

            CvPortfolioData current =
                string.IsNullOrWhiteSpace(json) ||
                json.Trim() == "null"
                    ? new CvPortfolioData()
                    : Json.Deserialize<CvPortfolioData>(json);

            if (current == null)
                current = new CvPortfolioData();

            change(current);

            current.UpdatedAt =
                DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();

            bool updated = FirebaseContext.PutIfUnchanged(
                DataPath, current, etag);

            if (!updated)
            {
                ShowError(
                    L.T("Student.StudentCVPortfolio.YourInformationChangedRefreshAndTry"));
            }

            return updated;
        }

        private static bool ValidUrl(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return true;

            Uri uri;

            return value.Length <= 500 &&
                Uri.TryCreate(
                    value, UriKind.Absolute, out uri) &&
                (uri.Scheme == Uri.UriSchemeHttps ||
                 uri.Scheme == Uri.UriSchemeHttp) &&
                !string.IsNullOrWhiteSpace(uri.Host);
        }

        private string StorageFolder
        {
            get
            {
                return Server.MapPath(
                    "~/App_Data/StudentDocuments/" + StudentId);
            }
        }

        private bool TrySavePdf(
            HttpPostedFile file,
            out string originalName,
            out string storageName)
        {
            originalName = "";
            storageName = "";

            if (file == null || file.ContentLength <= 0)
                return true;

            if (file.ContentLength > MaxFileBytes)
            {
                ShowError(L.T("Student.StudentCVPortfolio.PDFFilesMustBe5MB"));
                return false;
            }

            originalName = Path.GetFileName(file.FileName);

            if (!string.Equals(
                Path.GetExtension(originalName),
                ".pdf",
                StringComparison.OrdinalIgnoreCase))
            {
                ShowError(L.T("Student.StudentCVPortfolio.OnlyPDFFilesAreSupported"));
                return false;
            }

            // Check the PDF file signature.
            byte[] header = new byte[5];
            int count = file.InputStream.Read(
                header, 0, header.Length);

            file.InputStream.Position = 0;

            if (count != 5 ||
                System.Text.Encoding.ASCII.GetString(header)
                    != "%PDF-")
            {
                ShowError(L.T("Student.StudentCVPortfolio.TheSelectedFileIsNotA"));
                return false;
            }

            Directory.CreateDirectory(StorageFolder);

            storageName = Guid.NewGuid().ToString("N") + ".pdf";

            string fullPath = Path.Combine(
                StorageFolder, storageName);

            file.SaveAs(fullPath);

            return true;
        }

        private void SaveChanges()
        {
            string cvUrl =
                (Request.Form["cvUrl"] ?? "").Trim();

            string portfolioUrl =
                (Request.Form["portfolioUrl"] ?? "").Trim();

            if (!ValidUrl(cvUrl) ||
                !ValidUrl(portfolioUrl))
            {
                ShowError(
                    L.T("Student.StudentCVPortfolio.EnterValidHTTPOrHTTPSLinks"));
                return;
            }

            HttpPostedFile cvFile =
                Request.Files["cvFile"];

            HttpPostedFile portfolioFile =
                Request.Files["portfolioFile"];

            string cvName;
            string cvStorage;
            string portfolioName;
            string portfolioStorage;

            if (!TrySavePdf(
                cvFile, out cvName, out cvStorage))
                return;

            if (!TrySavePdf(
                portfolioFile,
                out portfolioName,
                out portfolioStorage))
            {
                DeletePhysicalFile(cvStorage);
                return;
            }

            bool saved = UpdateData(data =>
            {
                data.CvUrl = cvUrl;
                data.PortfolioUrl = portfolioUrl;

                if (!string.IsNullOrEmpty(cvStorage))
                {
                    data.CvFileName = cvName;
                    data.CvStorageName = cvStorage;
                }

                if (!string.IsNullOrEmpty(portfolioStorage))
                {
                    data.PortfolioFileName = portfolioName;
                    data.PortfolioStorageName =
                        portfolioStorage;
                }
            });

            if (!saved)
            {
                DeletePhysicalFile(cvStorage);
                DeletePhysicalFile(portfolioStorage);
                return;
            }

            Notice = "CV and portfolio saved successfully.";
            NoticeIsError = false;
        }

        private void RemoveFile(bool isCv)
        {
            string oldStorage = isCv
                ? Saved.CvStorageName
                : Saved.PortfolioStorageName;

            bool updated = UpdateData(data =>
            {
                if (isCv)
                {
                    data.CvFileName = null;
                    data.CvStorageName = null;
                }
                else
                {
                    data.PortfolioFileName = null;
                    data.PortfolioStorageName = null;
                }
            });

            if (updated)
            {
                // Only remove the physical file after
                // Firebase confirms the update.
                DeletePhysicalFile(oldStorage);

                Notice = L.T("Student.StudentCVPortfolio.FileRemovedSuccessfully");
                NoticeIsError = false;
            }
        }

        private void DeletePhysicalFile(string storageName)
        {
            if (string.IsNullOrWhiteSpace(storageName))
                return;

            if (!IsSafeStorageName(storageName))
                return;

            string path = Path.Combine(
                StorageFolder, storageName);

            if (File.Exists(path))
                File.Delete(path);
        }

        private static bool IsSafeStorageName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return false;

            if (!value.EndsWith(
                ".pdf", StringComparison.OrdinalIgnoreCase))
                return false;

            string name = Path.GetFileNameWithoutExtension(value);
            Guid id;

            return Guid.TryParseExact(name, "N", out id);
        }

        private void DownloadFile(string type)
        {
            string storageName;
            string displayName;

            if (type == "cv")
            {
                storageName = Saved.CvStorageName;
                displayName = Saved.CvFileName;
            }
            else if (type == "portfolio")
            {
                storageName = Saved.PortfolioStorageName;
                displayName = Saved.PortfolioFileName;
            }
            else
            {
                Response.StatusCode = 400;
                return;
            }

            if (!IsSafeStorageName(storageName))
            {
                Response.StatusCode = 404;
                return;
            }

            string path = Path.Combine(
                StorageFolder, storageName);

            if (!File.Exists(path))
            {
                Response.StatusCode = 404;
                return;
            }

            Response.Clear();
            Response.ContentType = "application/pdf";

            string safeName =
                type == "cv" ? "Student-CV.pdf" :
                "Student-Portfolio.pdf";

            Response.AddHeader(
                "Content-Disposition",
                "attachment; filename=\"" + safeName + "\"");

            Response.TransmitFile(path);
            Response.Flush();

            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowError(string message)
        {
            Notice = message;
            NoticeIsError = true;
        }
    }
}
