// =============================================================================
//  UIMS - Group 4   |   Owner: Sara Rajoub / Fatima  (Trello card R07 + F04)
//  File uploads: CVs and task submissions (cards R07, F04).
// =============================================================================

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// TODO(cards R07 and F04): both the CV upload and the task submission
    /// upload need somewhere to put a file. Agree on ONE of these as a team
    /// before either page is built, because the stored value ends up in
    /// Student.CvUrl and Submission.FileUrl and both pages must read the same
    /// kind of value.
    ///
    /// Option A - link only (zero work)
    ///   Ask for a Google Drive or GitHub link instead of a file. The
    ///   requirements allow "links or files", so this is a legitimate reading
    ///   of the spec and it removes the whole problem. Recommended if time
    ///   gets tight: it costs nothing and demos fine.
    ///
    /// Option B - Firebase Storage over REST
    ///   POST the bytes to
    ///   https://firebasestorage.googleapis.com/v0/b/{bucket}/o?name={path}
    ///   with the user's ID token as a Bearer header, then store the returned
    ///   download URL. Same pattern as Data/FirebaseContext.cs, no SDK needed.
    ///
    /// Option C - App_Data on the web server
    ///   Simplest to code, but the files live only on whichever machine runs
    ///   the demo, so they vanish for the markers. Avoid.
    /// </summary>
    public static class StorageService
    {
        public static string Bucket
        {
            get { return System.Web.Configuration.WebConfigurationManager.AppSettings["Firebase.StorageBucket"]; }
        }

        public static bool IsConfigured
        {
            get { return !string.IsNullOrEmpty(Bucket); }
        }

        /// <summary>Uploads a posted file and returns its download URL.</summary>
        public static string Upload(System.Web.HttpPostedFile file, string folder)
        {
            if (file == null || file.ContentLength == 0) return null;

            throw new System.NotImplementedException(
                "Pick option A, B or C in the comment above this class, then implement or delete this method.");
        }

        /// <summary>Guard for uploads. Keep this even on option A, for links.</summary>
        public static bool IsAllowed(string fileName, int lengthBytes)
        {
            if (string.IsNullOrEmpty(fileName)) return false;
            if (lengthBytes <= 0 || lengthBytes > 10 * 1024 * 1024) return false;   // 10 MB

            string extension = System.IO.Path.GetExtension(fileName).ToLowerInvariant();
            switch (extension)
            {
                case ".pdf":
                case ".doc":
                case ".docx":
                case ".png":
                case ".jpg":
                case ".jpeg":
                case ".zip":
                    return true;
                default:
                    return false;
            }
        }
    }
}
