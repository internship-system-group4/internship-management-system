using System;
using System.IO;
using System.Web;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Services
{
    /// <summary>Keeps a company's task attachment (the file a supervisor attaches when
    /// assigning a task) on the web server when Firebase Storage has no bucket.
    /// Files live in App_Data/TaskAttachments/{companyId}/ and are only served through
    /// Pages/Account/TaskAttachment.ashx, which checks who is asking.</summary>
    public static class TaskAttachmentStorage
    {
        private const string HandlerPath = "~/Pages/Account/TaskAttachment.ashx";

        /// <summary>Saves the file and returns the link stored on the task.</summary>
        public static string SaveLocal(HttpPostedFile file, string companyId, out string storageName)
        {
            if (file == null || !ApplicationRepository.IsValidKey(companyId))
                throw new InvalidOperationException("Choose a PDF or Word file.");
            string extension = Path.GetExtension(Path.GetFileName(file.FileName)).ToLowerInvariant();
            storageName = Guid.NewGuid().ToString("N") + extension;
            string folder = HttpContext.Current.Server.MapPath("~/App_Data/TaskAttachments/" + companyId);
            Directory.CreateDirectory(folder);
            file.SaveAs(Path.Combine(folder, storageName));
            return LocalUrl(companyId, storageName);
        }

        public static string LocalUrl(string companyId, string storageName)
        {
            return VirtualPathUtility.ToAbsolute(HandlerPath) + "?company=" +
                HttpUtility.UrlEncode(companyId) + "&file=" + HttpUtility.UrlEncode(storageName);
        }

        /// <summary>True when the link is one this class made (a server-side attachment).</summary>
        public static bool IsLocalUrl(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            string prefix = VirtualPathUtility.ToAbsolute(HandlerPath) + "?";
            if (!value.StartsWith(prefix, StringComparison.OrdinalIgnoreCase)) return false;
            var query = HttpUtility.ParseQueryString(value.Substring(prefix.Length));
            string companyId = query["company"], storageName = query["file"];
            return ApplicationRepository.IsValidKey(companyId) && IsStorageName(storageName) &&
                string.Equals(value, LocalUrl(companyId, storageName), StringComparison.Ordinal);
        }

        public static bool IsStorageName(string storageName)
        {
            if (string.IsNullOrWhiteSpace(storageName) || storageName != Path.GetFileName(storageName))
                return false;
            Guid parsed;
            string ext = Path.GetExtension(storageName).ToLowerInvariant();
            return Guid.TryParseExact(Path.GetFileNameWithoutExtension(storageName), "N", out parsed) &&
                (ext == ".pdf" || ext == ".doc" || ext == ".docx");
        }

        public static string LocalPath(string companyId, string storageName)
        {
            if (!ApplicationRepository.IsValidKey(companyId) || !IsStorageName(storageName)) return null;
            return HttpContext.Current.Server.MapPath("~/App_Data/TaskAttachments/" + companyId + "/" + storageName);
        }

        /// <summary>Removes a file saved by SaveLocal when the task could not be saved.</summary>
        public static void DeleteLocal(string companyId, string storageName)
        {
            try
            {
                string path = LocalPath(companyId, storageName);
                if (path != null && File.Exists(path)) File.Delete(path);
            }
            catch (IOException) { }
            catch (UnauthorizedAccessException) { }
        }
    }
}
