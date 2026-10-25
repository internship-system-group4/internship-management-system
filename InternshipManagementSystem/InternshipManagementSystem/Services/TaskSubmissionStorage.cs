using System;
using System.IO;
using System.Web;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Services
{
    /// <summary>Private local fallback for task attachments when Firebase Storage has no bucket.</summary>
    public static class TaskSubmissionStorage
    {
        private const string HandlerPath = "~/Pages/Student/SubmissionFile.ashx";

        public static string SaveLocal(HttpPostedFile file, string studentId, string taskId)
        {
            if (file == null || !StorageService.IsAllowed(file.FileName, file.ContentLength) ||
                !ApplicationRepository.IsValidKey(studentId) || !ApplicationRepository.IsValidKey(taskId))
                throw new InvalidOperationException("Choose a supported attachment smaller than 10 MB.");
            string extension = Path.GetExtension(Path.GetFileName(file.FileName)).ToLowerInvariant();
            string storageName = Guid.NewGuid().ToString("N") + extension;
            string folder = HttpContext.Current.Server.MapPath(
                "~/App_Data/TaskSubmissions/" + studentId + "/" + taskId);
            Directory.CreateDirectory(folder);
            file.SaveAs(Path.Combine(folder, storageName));
            return LocalUrl(taskId, storageName);
        }

        public static string LocalUrl(string taskId, string storageName)
        {
            return VirtualPathUtility.ToAbsolute(HandlerPath) + "?task=" +
                HttpUtility.UrlEncode(taskId) + "&file=" + HttpUtility.UrlEncode(storageName);
        }

        public static bool IsSafeUrl(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return false;
            Uri uri;
            if (Uri.TryCreate(value, UriKind.Absolute, out uri))
                return uri.Scheme == Uri.UriSchemeHttps &&
                    uri.Host.Equals("firebasestorage.googleapis.com", StringComparison.OrdinalIgnoreCase);
            string prefix = VirtualPathUtility.ToAbsolute(HandlerPath) + "?";
            if (!value.StartsWith(prefix, StringComparison.OrdinalIgnoreCase) || value.IndexOf('#') >= 0)
                return false;
            var query = HttpUtility.ParseQueryString(value.Substring(prefix.Length));
            string taskId = query["task"], storageName = query["file"];
            return ApplicationRepository.IsValidKey(taskId) && IsStorageName(storageName) &&
                string.Equals(value, LocalUrl(taskId, storageName), StringComparison.Ordinal);
        }

        public static bool IsStorageName(string storageName)
        {
            if (string.IsNullOrWhiteSpace(storageName) || storageName != Path.GetFileName(storageName))
                return false;
            Guid parsed;
            string ext = Path.GetExtension(storageName).ToLowerInvariant();
            return Guid.TryParseExact(Path.GetFileNameWithoutExtension(storageName), "N", out parsed) &&
                (ext == ".pdf" || ext == ".doc" || ext == ".docx" || ext == ".zip" ||
                 ext == ".png" || ext == ".jpg" || ext == ".jpeg");
        }

        public static string LocalPath(string studentId, string taskId, string storageName)
        {
            if (!ApplicationRepository.IsValidKey(studentId) ||
                !ApplicationRepository.IsValidKey(taskId) || !IsStorageName(storageName))
                return null;
            return HttpContext.Current.Server.MapPath(
                "~/App_Data/TaskSubmissions/" + studentId + "/" + taskId + "/" + storageName);
        }
    }
}
