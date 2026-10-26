// =============================================================================
//  UIMS - Group 4
//  Read-only access to a student's CV, portfolio and profile extras, so other
//  roles (for example a company reviewing an application) can see them.
//  The student pages (Profile.aspx, StudentCVPortfolio.aspx) still own writes.
// =============================================================================

using System;
using System.IO;
using System.Web;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Services
{
    public static class StudentDocumentService
    {
        // Same shape as the "studentCvPortfolios/{studentId}" node.
        public class Documents
        {
            public string CvUrl { get; set; }
            public string PortfolioUrl { get; set; }
            public string CvFileName { get; set; }
            public string CvStorageName { get; set; }
            public string PortfolioFileName { get; set; }
            public string PortfolioStorageName { get; set; }
        }

        // Same shape as the "studentProfileExtras/{studentId}" node.
        public class ProfileExtras
        {
            public int Age { get; set; }
            public string TechnicalSkills { get; set; }
            public string SoftSkills { get; set; }
            public string LinkedInUrl { get; set; }
        }

        public static Documents LoadDocuments(string studentId)
        {
            // Firebase may not let a company read the student's CV record, so the
            // copy kept next to the uploaded files on this server fills any gaps.
            Documents online = LoadNode<Documents>("studentCvPortfolios/", studentId) ?? new Documents();
            Documents local = LoadLocalIndex(studentId);
            if (string.IsNullOrEmpty(online.CvStorageName) && local != null)
            {
                online.CvStorageName = local.CvStorageName;
                online.CvFileName = local.CvFileName;
            }
            if (string.IsNullOrEmpty(online.PortfolioStorageName) && local != null)
            {
                online.PortfolioStorageName = local.PortfolioStorageName;
                online.PortfolioFileName = local.PortfolioFileName;
            }
            if (string.IsNullOrEmpty(online.CvUrl) && local != null) online.CvUrl = local.CvUrl;
            if (string.IsNullOrEmpty(online.PortfolioUrl) && local != null) online.PortfolioUrl = local.PortfolioUrl;

            // Uploads made before the local copy existed: use the newest PDF as the CV.
            if (local == null && string.IsNullOrEmpty(online.CvStorageName) && string.IsNullOrEmpty(online.PortfolioStorageName))
                online.CvStorageName = NewestPdf(studentId);
            return online;
        }

        private const string LocalIndexName = "documents.json";

        /// <summary>Called by StudentCVPortfolio.aspx after every save: keeps the CV and
        /// portfolio details next to the files, readable by any role on this server.</summary>
        public static void SaveLocalIndex(string studentId, object documents)
        {
            if (!ApplicationRepository.IsValidKey(studentId) || documents == null) return;
            try
            {
                string folder = HttpContext.Current.Server.MapPath("~/App_Data/StudentDocuments/" + studentId);
                Directory.CreateDirectory(folder);
                File.WriteAllText(Path.Combine(folder, LocalIndexName), Json.Serialize(documents));
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("StudentDocumentService index: " + ex.Message);
            }
        }

        private static Documents LoadLocalIndex(string studentId)
        {
            if (!ApplicationRepository.IsValidKey(studentId)) return null;
            try
            {
                string path = Path.Combine(
                    HttpContext.Current.Server.MapPath("~/App_Data/StudentDocuments/" + studentId), LocalIndexName);
                return File.Exists(path) ? Json.Deserialize<Documents>(File.ReadAllText(path)) : null;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("StudentDocumentService index: " + ex.Message);
                return null;
            }
        }

        private static string NewestPdf(string studentId)
        {
            if (!ApplicationRepository.IsValidKey(studentId)) return null;
            string folder = HttpContext.Current.Server.MapPath("~/App_Data/StudentDocuments/" + studentId);
            if (!Directory.Exists(folder)) return null;
            FileInfo newest = null;
            foreach (FileInfo file in new DirectoryInfo(folder).GetFiles("*.pdf"))
                if (IsSafePdfName(file.Name) && (newest == null || file.LastWriteTimeUtc > newest.LastWriteTimeUtc))
                    newest = file;
            return newest == null ? null : newest.Name;
        }

        public static ProfileExtras LoadExtras(string studentId)
        {
            return LoadNode<ProfileExtras>("studentProfileExtras/", studentId) ?? new ProfileExtras();
        }

        /// <summary>Full path of an uploaded PDF, or null when it is missing or unsafe.</summary>
        public static string UploadedFilePath(string studentId, string storageName)
        {
            if (!ApplicationRepository.IsValidKey(studentId) || !IsSafePdfName(storageName)) return null;
            string path = Path.Combine(
                HttpContext.Current.Server.MapPath("~/App_Data/StudentDocuments/" + studentId), storageName);
            return File.Exists(path) ? path : null;
        }

        /// <summary>True for an HTTPS link to another website (Google Drive, GitHub...).
        /// Links back to this portal (like the student's own download page) are
        /// not usable by other roles, so they return false.</summary>
        public static bool IsExternalLink(string url)
        {
            if (!ApplicationRepository.IsSafeDocumentUrl(url)) return false;
            Uri uri = new Uri(url);
            HttpRequest request = HttpContext.Current.Request;
            return !uri.Host.Equals(request.Url.Host, StringComparison.OrdinalIgnoreCase);
        }

        /// <summary>Link a company opens to see its trainee's CV (the PDF uploaded on the
        /// CV &amp; Portfolio page, or a CV/portfolio link), or "" when nothing was shared.
        /// The link goes through Company/ApplicantDocument.aspx, which checks the company.</summary>
        public static string TraineeCvUrl(Models.Placement placement, Models.Student student)
        {
            if (placement == null || !ApplicationRepository.IsValidKey(placement.Id)) return "";
            Documents docs = LoadDocuments(placement.StudentId);
            bool hasDocument =
                UploadedFilePath(placement.StudentId, docs.CvStorageName) != null ||
                IsExternalLink(docs.CvUrl) ||
                (student != null && IsExternalLink(student.CvUrl)) ||
                UploadedFilePath(placement.StudentId, docs.PortfolioStorageName) != null ||
                IsExternalLink(docs.PortfolioUrl) ||
                (student != null && IsExternalLink(student.PortfolioUrl));
            return hasDocument
                ? VirtualPathUtility.ToAbsolute("~/Pages/Company/ApplicantDocument.aspx") + "?trainee=" + HttpUtility.UrlEncode(placement.Id)
                : "";
        }

        private static T LoadNode<T>(string folder, string studentId) where T : class
        {
            if (!ApplicationRepository.IsValidKey(studentId)) return null;
            try
            {
                string json = FirebaseContext.Get(folder + studentId);
                if (string.IsNullOrWhiteSpace(json) || json.Trim() == "null") return null;
                return Json.Deserialize<T>(json);
            }
            catch (Exception ex)
            {
                // Optional data: the page still works without it.
                System.Diagnostics.Trace.TraceWarning("StudentDocumentService: " + ex.Message);
                return null;
            }
        }

        private static bool IsSafePdfName(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            if (!value.EndsWith(".pdf", StringComparison.OrdinalIgnoreCase)) return false;
            Guid id;
            return Guid.TryParseExact(Path.GetFileNameWithoutExtension(value), "N", out id);
        }
    }
}
