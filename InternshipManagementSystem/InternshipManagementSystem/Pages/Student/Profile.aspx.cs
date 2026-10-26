// =============================================================================
//  My Profile
//  Owner : Sara Rajoub
//  Cards : R06, R07
//
//  Show academic data read-only and let the student edit permitted personal fields plus a CV or portfolio link. University, college, major and required hours are coordinator-controlled and must stay locked.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================

using System;
using System.IO;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class Profile : StudentPage
    {
        protected string Notice = "";
        protected bool NoticeIsError = false;

        protected string StudentName = "";
        protected string StudentEmail = "";
        protected string StudentPhone = "";
        protected string StudentNumber = "";
        protected string StudentUniversity = "";
        protected string StudentCollege = "";
        protected string StudentMajor = "";
        protected string RequiredHoursText = "";
        protected string ApprovedHoursText = "";

        protected string AgeText = "";
        protected string TechnicalSkills = "";
        protected string SoftSkills = "";
        protected string LinkedInUrl = "";
        protected string CvUrl = "";
        protected string PortfolioUrl = "";

        protected string Initials = "ST";
        protected string PhotoUrl = "";
        protected bool HasPhoto = false;
        protected bool HasCvFile = false;
        protected bool HasPortfolioFile = false;

        protected string CvDownloadUrl =
            "StudentCVPortfolio.aspx?download=cv";

        protected string PortfolioDownloadUrl =
            "StudentCVPortfolio.aspx?download=portfolio";

        private const int MaxPhotoSize = 2 * 1024 * 1024;

        protected Student student;

        // True right after a successful save; the page shows an animated "Saved" toast.
        protected bool JustSaved = false;
        protected int HoursPercent = 0;
        private ExtraProfile extra = new ExtraProfile();
        private CvPortfolioData documents = new CvPortfolioData();

        // Extra personal fields not present in the shared Student model.
        public class ExtraProfile
        {
            public int Age { get; set; }
            public string TechnicalSkills { get; set; }
            public string SoftSkills { get; set; }
            public string LinkedInUrl { get; set; }
            public string PhotoStorageName { get; set; }
            public long UpdatedAt { get; set; }
        }

        // Same data structure used by StudentCVPortfolio.aspx.cs.
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
            get { return CurrentStudent == null ? "" : CurrentStudent.Id; }
        }

        private string ExtraPath
        {
            get { return "studentProfileExtras/" + StudentId; }
        }

        private string DocumentsPath
        {
            get { return "studentCvPortfolios/" + StudentId; }
        }

        private string StorageFolder
        {
            get
            {
                return Server.MapPath(
                    "~/App_Data/StudentDocuments/" + StudentId);
            }
        }

        protected override void OnInit(EventArgs e)
        {
            base.OnInit(e);

            // Required for uploading files through the master-page form.
            if (Page.Form != null)
                Page.Form.Enctype = "multipart/form-data";

            if (Session != null)
                ViewStateUserKey = Session.SessionID;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!ValidKey(StudentId))
            {
                ShowError(L.T("Student.Profile.StudentAccountIsUnavailable"));
                return;
            }

            try
            {
                student = new UserRepository().GetStudent(StudentId);

                if (student == null)
                {
                    ShowError(L.T("Student.Profile.StudentProfileCouldNotBeFound"));
                    return;
                }

                LoadExtra();
                LoadDocuments();

                if (Request.QueryString["photo"] == "1")
                {
                    SendPhoto();
                    return;
                }

                if (IsPostBack &&
                    Request.Form["spAction"] == "save" &&
                    SaveProfile())
                {
                    // Reload the page with a normal GET: it shows the saved
                    // values and a refresh does not send the form again.
                    Response.Redirect(
                        ResolveUrl("~/Pages/Student/Profile.aspx?saved=1"), false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }

                if (!IsPostBack && Request.QueryString["saved"] == "1")
                {
                    JustSaved = true;
                }

                DisplayProfile();
            }
            
                catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError(
                    "Student Profile Error: " + ex.ToString());

                ShowError(
                    L.F("Student.Profile.ProfileError", ex.Message));

                if (student != null)
                    DisplayProfile();
            }
        }

        private static bool ValidKey(string value)
        {
            return !string.IsNullOrWhiteSpace(value) &&
                   value.IndexOfAny(
                       new char[] { '.', '#', '$', '[', ']', '/' }
                   ) < 0;
        }

        private void LoadExtra()
        {
            string json = FirebaseContext.Get(ExtraPath);

            extra = string.IsNullOrWhiteSpace(json)
                ? new ExtraProfile()
                : Json.Deserialize<ExtraProfile>(json);

            if (extra == null)
                extra = new ExtraProfile();
        }

        private void LoadDocuments()
        {
            string json = FirebaseContext.Get(DocumentsPath);

            documents = string.IsNullOrWhiteSpace(json)
                ? new CvPortfolioData()
                : Json.Deserialize<CvPortfolioData>(json);

            if (documents == null)
                documents = new CvPortfolioData();
        }

        private void DisplayProfile()
        {
            StudentName = student.FullName ?? "";
            StudentEmail = student.Email ?? "";
            StudentPhone = student.PhoneNumber ?? "";

            StudentNumber = student.StudentNumber ?? "";
            StudentUniversity = student.University ?? "";
            StudentCollege = student.College ?? "";
            StudentMajor = student.Major ?? "";

            RequiredHoursText = student.RequiredHours.ToString();
            ApprovedHoursText = student.ApprovedHours.ToString();
            HoursPercent = student.RequiredHours > 0
                ? (int)Math.Min(100, Math.Round(student.ApprovedHours * 100.0 / student.RequiredHours))
                : 0;

            AgeText = extra.Age > 0
                ? extra.Age.ToString()
                : "";

            TechnicalSkills = extra.TechnicalSkills ?? "";
            SoftSkills = extra.SoftSkills ?? "";
            LinkedInUrl = extra.LinkedInUrl ?? "";

            CvUrl = documents.CvUrl ?? student.CvUrl ?? "";
            PortfolioUrl =
                documents.PortfolioUrl ?? student.PortfolioUrl ?? "";

            string name = StudentName.Trim();

            if (!string.IsNullOrEmpty(name))
            {
                string[] parts = name.Split(
                    new char[] { ' ' },
                    StringSplitOptions.RemoveEmptyEntries);

                Initials = parts[0].Substring(0, 1).ToUpper();

                if (parts.Length > 1)
                {
                    Initials += parts[parts.Length - 1]
                        .Substring(0, 1).ToUpper();
                }
            }

            HasPhoto = IsSafePhotoName(extra.PhotoStorageName) &&
                       File.Exists(Path.Combine(
                           StorageFolder, extra.PhotoStorageName));

            if (HasPhoto)
            {
                PhotoUrl = ResolveUrl(
                    "~/Pages/Student/Profile.aspx?photo=1&v=" +
                    extra.UpdatedAt);
            }

            HasCvFile =
                IsSafePdfName(documents.CvStorageName);

            HasPortfolioFile =
                IsSafePdfName(documents.PortfolioStorageName);
        }

        protected string FormValue(string name, string savedValue)
        {
            // Keep typed values visible when validation fails.
            if (IsPostBack &&
                Request.Form["spAction"] == "save" &&
                NoticeIsError)
            {
                return Request.Form[name] ?? "";
            }

            return savedValue ?? "";
        }

        /// <summary>Validates the Edit Profile form and saves it.
        /// Returns true only when everything was saved.</summary>
        private bool SaveProfile()
        {
            string fullName = (Request.Form["spName"] ?? "").Trim();
            string phone = (Request.Form["spPhone"] ?? "").Trim();
            string ageText = (Request.Form["spAge"] ?? "").Trim();
            string technical = (Request.Form["spTechnical"] ?? "").Trim();
            string soft = (Request.Form["spSoft"] ?? "").Trim();
            string linkedIn = (Request.Form["spLinkedIn"] ?? "").Trim();
            int age = 0;

            if (fullName.Length < 2 || fullName.Length > 120)
            {
                ShowError(L.T("Student.Profile.FullNameMustBeBetween2"));
                return false;
            }

            if (phone.Length > 25 || technical.Length > 1500 || soft.Length > 1500)
            {
                ShowError(L.T("Student.Profile.OneOrMoreFieldsExceedThe"));
                return false;
            }

            if (!string.IsNullOrEmpty(ageText) &&
                (!int.TryParse(ageText, out age) || age < 16 || age > 100))
            {
                ShowError(L.T("Student.Profile.PleaseEnterAValidAgeBetween"));
                return false;
            }

            if (!ValidUrl(linkedIn))
            {
                ShowError(L.T("Student.Profile.PleaseEnterValidHTTPOrHTTPS"));
                return false;
            }

            if (!string.IsNullOrWhiteSpace(linkedIn))
            {
                Uri linkedInUri = new Uri(linkedIn);
                if (!linkedInUri.Host.Equals("linkedin.com", StringComparison.OrdinalIgnoreCase) &&
                    !linkedInUri.Host.EndsWith(".linkedin.com", StringComparison.OrdinalIgnoreCase))
                {
                    ShowError(L.T("Student.Profile.PleaseEnterAValidLinkedInProfile"));
                    return false;
                }
            }

            HttpPostedFile photo = Request.Files["spPhoto"];
            if (!ValidatePhoto(photo))
                return false;

            string photoName = "";

            try
            {
                if (HasUpload(photo))
                {
                    Directory.CreateDirectory(StorageFolder);
                    photoName = Guid.NewGuid().ToString("N") +
                                Path.GetExtension(photo.FileName).ToLowerInvariant();
                    photo.SaveAs(Path.Combine(StorageFolder, photoName));
                }

                long now = Time.NowMs();

                // Personal extras: PATCH only changes these fields and keeps
                // everything else in the node. (The old read-then-replace save
                // could fail with "updated elsewhere" after name and phone were
                // already saved, so the profile ended up half updated.)
                var extraFields = new System.Collections.Generic.Dictionary<string, object>
                {
                    { "Age", age },
                    { "TechnicalSkills", technical },
                    { "SoftSkills", soft },
                    { "LinkedInUrl", linkedIn },
                    { "UpdatedAt", now }
                };
                if (!string.IsNullOrEmpty(photoName))
                    extraFields["PhotoStorageName"] = photoName;

                FirebaseContext.Patch(ExtraPath, extraFields);

                // Account fields the student may change. Academic fields and the
                // CV / portfolio links are not touched here (the links are managed
                // on StudentCVPortfolio.aspx; this form used to blank them out).
                FirebaseContext.Patch(
                    Constants.Paths.Users + "/" + StudentId,
                    new { FullName = fullName, PhoneNumber = phone });

                // Refresh the session copy so the sidebar shows the new name and photo.
                student.FullName = fullName;
                student.PhoneNumber = phone;
                if (!string.IsNullOrEmpty(photoName))
                    student.ProfileImageUrl = "~/Pages/Student/Profile.aspx?photo=1&v=" + now;
                SessionHelper.Refresh(student);

                return true;
            }
            catch
            {
                // Remove the newly uploaded photo if the save failed.
                // Existing files are never deleted here.
                if (!string.IsNullOrEmpty(photoName))
                    DeleteFile(photoName);
                throw;
            }
        }

        private static bool HasUpload(HttpPostedFile file)
        {
            return file != null && file.ContentLength > 0;
        }

        private bool ValidatePhoto(HttpPostedFile file)
        {
            if (!HasUpload(file))
                return true;

            if (file.ContentLength > MaxPhotoSize)
            {
                ShowError(L.T("Student.Profile.ProfilePhotoMustBe2MB"));
                return false;
            }

            string extension =
                Path.GetExtension(file.FileName).ToLowerInvariant();

            if (extension != ".jpg" &&
                extension != ".jpeg" &&
                extension != ".png")
            {
                ShowError(L.T("Student.Profile.ProfilePhotoMustBeJPGOr"));
                return false;
            }

            byte[] header = new byte[8];
            int count = file.InputStream.Read(
                header, 0, header.Length);

            file.InputStream.Position = 0;

            bool isPng =
                count == 8 &&
                header[0] == 137 &&
                header[1] == 80 &&
                header[2] == 78 &&
                header[3] == 71 &&
                header[4] == 13 &&
                header[5] == 10 &&
                header[6] == 26 &&
                header[7] == 10;

            bool isJpeg =
                count >= 3 &&
                header[0] == 255 &&
                header[1] == 216 &&
                header[2] == 255;

            bool valid =
                extension == ".png" ? isPng : isJpeg;

            if (!valid)
            {
                ShowError(L.T("Student.Profile.TheSelectedPhotoIsNotA"));
                return false;
            }

            return true;
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

        private static bool IsSafePdfName(string value)
        {
            if (string.IsNullOrWhiteSpace(value) ||
                !value.EndsWith(
                    ".pdf",
                    StringComparison.OrdinalIgnoreCase))
                return false;

            Guid id;

            return Guid.TryParseExact(
                Path.GetFileNameWithoutExtension(value),
                "N",
                out id);
        }

        private static bool IsSafePhotoName(string value)
        {
            if (string.IsNullOrWhiteSpace(value))
                return false;

            string extension =
                Path.GetExtension(value).ToLowerInvariant();

            if (extension != ".png" &&
                extension != ".jpg" &&
                extension != ".jpeg")
                return false;

            Guid id;

            return Guid.TryParseExact(
                Path.GetFileNameWithoutExtension(value),
                "N",
                out id);
        }

        private void SendPhoto()
        {
            if (!IsSafePhotoName(extra.PhotoStorageName))
            {
                Response.StatusCode = 404;
                return;
            }

            string path = Path.Combine(
                StorageFolder, extra.PhotoStorageName);

            if (!File.Exists(path))
            {
                Response.StatusCode = 404;
                return;
            }

            string extension =
                Path.GetExtension(path).ToLowerInvariant();

            Response.Clear();

            Response.ContentType =
                extension == ".png"
                    ? "image/png"
                    : "image/jpeg";

            Response.AddHeader(
                "Content-Disposition",
                "inline; filename=\"profile-photo" +
                extension + "\"");

            Response.AddHeader(
                "X-Content-Type-Options", "nosniff");

            Response.TransmitFile(path);
            Response.Flush();

            Context.ApplicationInstance.CompleteRequest();
        }

        private void DeleteFile(string storageName)
        {
            if (string.IsNullOrWhiteSpace(storageName))
                return;

            string path = Path.Combine(
                StorageFolder,
                Path.GetFileName(storageName));

            if (File.Exists(path))
                File.Delete(path);
        }

        private void ShowError(string message)
        {
            Notice = message;
            NoticeIsError = true;
        }
    }
}
