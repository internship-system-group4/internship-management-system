// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  Every HTTP call to Firebase goes through here.
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Configuration;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// Thin synchronous client for the Firebase Realtime Database REST API.
    ///
    /// Deliberately synchronous: mixing async/await into Web Forms page events
    /// without RegisterAsyncTask deadlocks the request, and that bug is very
    /// hard to diagnose under demo pressure. These calls block, which is fine
    /// for the data volumes in this project.
    ///
    /// Configure the two settings in Web.config (or in App_Secrets.config,
    /// which is git-ignored):
    ///   Firebase.DatabaseUrl   https://your-project-default-rtdb.firebaseio.com
    ///   Firebase.ApiKey        the Web API key from Firebase project settings
    /// </summary>
    public static class FirebaseContext
    {
        public static string DatabaseUrl
        {
            get
            {
                string value = WebConfigurationManager.AppSettings["Firebase.DatabaseUrl"];
                return string.IsNullOrWhiteSpace(value) ? null : value.TrimEnd('/');
            }
        }

        public static string ApiKey
        {
            get { return WebConfigurationManager.AppSettings["Firebase.ApiKey"]; }
        }

        public static bool IsConfigured
        {
            get { return !string.IsNullOrEmpty(DatabaseUrl) && !string.IsNullOrEmpty(ApiKey); }
        }

        /// <summary>The signed-in user's Firebase ID token, when there is one.
        /// Sent as ?auth= so database rules can identify the caller.</summary>
        private static string CurrentToken()
        {
            if (HttpContext.Current == null || HttpContext.Current.Session == null) return null;
            return HttpContext.Current.Session[Common.Constants.SessionTokenKey] as string;
        }

        private static string BuildUrl(string path, string query)
        {
            if (!IsConfigured)
            {
                throw new InvalidOperationException(
                    "Firebase is not configured. Set Firebase.DatabaseUrl and Firebase.ApiKey " +
                    "in Web.config or App_Secrets.config. See docs/05-firebase-setup.md.");
            }

            StringBuilder url = new StringBuilder();
            url.Append(DatabaseUrl).Append('/').Append(path.Trim('/')).Append(".json");

            List<string> parts = new List<string>();
            if (!string.IsNullOrEmpty(query)) parts.Add(query);

            string token = CurrentToken();
            if (!string.IsNullOrEmpty(token)) parts.Add("auth=" + Uri.EscapeDataString(token));

            if (parts.Count > 0) url.Append('?').Append(string.Join("&", parts.ToArray()));
            return url.ToString();
        }

        /// <summary>Reads a node. Returns null when the node does not exist.</summary>
        public static string Get(string path)
        {
            return Send("GET", BuildUrl(path, null), null);
        }

        /// <summary>Reads children of <paramref name="path"/> whose
        /// <paramref name="field"/> equals <paramref name="value"/>.
        /// Requires an .indexOn rule for that field - see
        /// docs/05-firebase-setup.md, or the call returns an index warning.</summary>
        public static string GetWhere(string path, string field, string value)
        {
            string query = "orderBy=" + Uri.EscapeDataString("\"" + field + "\"")
                         + "&equalTo=" + Uri.EscapeDataString("\"" + value + "\"");
            return Send("GET", BuildUrl(path, query), null);
        }

        /// <summary>Replaces the node completely.</summary>
        public static string Put(string path, object value)
        {
            return Send("PUT", BuildUrl(path, null), Json.Serialize(value));
        }

        /// <summary>Merges the given fields into the node, leaving the rest
        /// untouched. Prefer this over Put for partial updates so two people
        /// editing different fields do not overwrite each other.</summary>
        public static string Patch(string path, object value)
        {
            return Send("PATCH", BuildUrl(path, null), Json.Serialize(value));
        }

        /// <summary>Appends a child under a generated key and returns that key.</summary>
        public static string Push(string path, object value)
        {
            string response = Send("POST", BuildUrl(path, null), Json.Serialize(value));
            Dictionary<string, object> map = Json.ToMap(response);
            object name;
            return map.TryGetValue("name", out name) ? Convert.ToString(name) : null;
        }

        public static void Delete(string path)
        {
            Send("DELETE", BuildUrl(path, null), null);
        }

        // ----------------------------------------------------------------
        private static string Send(string method, string url, string body)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = method;
            request.ContentType = "application/json; charset=utf-8";
            request.Accept = "application/json";
            request.Timeout = 30000;
            request.KeepAlive = true;

            if (!string.IsNullOrEmpty(body))
            {
                byte[] payload = Encoding.UTF8.GetBytes(body);
                request.ContentLength = payload.Length;
                using (Stream stream = request.GetRequestStream())
                {
                    stream.Write(payload, 0, payload.Length);
                }
            }

            try
            {
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    string text = reader.ReadToEnd();
                    return text == "null" ? null : text;
                }
            }
            catch (WebException ex)
            {
                throw new FirebaseException(method + " " + Scrub(url) + " failed: " + ReadError(ex), ex);
            }
        }

        private static string ReadError(WebException ex)
        {
            if (ex.Response == null) return ex.Message;
            using (StreamReader reader = new StreamReader(ex.Response.GetResponseStream(), Encoding.UTF8))
            {
                string body = reader.ReadToEnd();
                return string.IsNullOrWhiteSpace(body) ? ex.Message : body;
            }
        }

        /// <summary>Keeps the auth token out of error messages and logs.</summary>
        private static string Scrub(string url)
        {
            int index = url.IndexOf("auth=", StringComparison.OrdinalIgnoreCase);
            return index < 0 ? url : url.Substring(0, index) + "auth=***";
        }
    }

    public class FirebaseException : Exception
    {
        public FirebaseException(string message, Exception inner) : base(message, inner) { }
    }
}
