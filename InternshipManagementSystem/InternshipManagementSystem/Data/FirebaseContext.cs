using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Text;
using System.Web;
using System.Web.Configuration;

namespace InternshipManagementSystem.Data
{
    // Synchronous Firebase REST calls with one token refresh per request.
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
                    "in Web.config. See docs/05-firebase-setup.md.");
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
            return Send("GET", path, null);
        }

        public static string GetRecent(string path, int limit)
        {
            return Send("GET", path, null, "orderBy=%22CreatedAt%22&limitToLast=" + Math.Max(1, Math.Min(100, limit)));
        }

        /// <summary>Reads children of <paramref name="path"/> whose
        /// <paramref name="field"/> equals <paramref name="value"/>.
        /// Uses the field's .indexOn rule (docs/05-firebase-setup.md). If the rule
        /// is missing, reads the whole node and filters here so the page still loads.</summary>
        public static string GetWhere(string path, string field, string value)
        {
            string query = "orderBy=" + Uri.EscapeDataString("\"" + field + "\"")
                         + "&equalTo=" + Uri.EscapeDataString("\"" + value + "\"");
            try
            {
                return Send("GET", path, null, query);
            }
            catch (FirebaseException ex)
            {
                if (ex.Message.IndexOf("Index not defined", StringComparison.OrdinalIgnoreCase) < 0) throw;
                System.Diagnostics.Trace.TraceWarning(
                    "Firebase index missing: add \".indexOn\": \"" + field + "\" to /" + path.Trim('/') + ". Filtering locally.");
                return FilterChildren(Get(path), field, value);
            }
        }

        private static string FilterChildren(string json, string field, string value)
        {
            if (json == null) return null;
            Dictionary<string, object> all = Json.ToMap(json);
            Dictionary<string, object> matches = new Dictionary<string, object>();
            foreach (KeyValuePair<string, object> child in all)
            {
                IDictionary<string, object> record = child.Value as IDictionary<string, object>;
                object fieldValue;
                if (record != null && record.TryGetValue(field, out fieldValue)
                    && string.Equals(Convert.ToString(fieldValue), value, StringComparison.Ordinal))
                {
                    matches[child.Key] = child.Value;
                }
            }
            return matches.Count == 0 ? null : Json.Serialize(matches);
        }

        /// <summary>Reads only the newest <paramref name="count"/> children of a
        /// node whose keys are Push keys (they sort by creation time). Ordering
        /// by key needs no .indexOn rule.</summary>
        public static string GetLast(string path, int count)
        {
            string query = "orderBy=" + Uri.EscapeDataString("\"$key\"") + "&limitToLast=" + count;
            return Send("GET", path, null, query);
        }

        /// <summary>Replaces the node completely.</summary>
        public static string Put(string path, object value)
        {
            return Send("PUT", path, Json.Serialize(value));
        }

        /// <summary>Merges the given fields into the node, leaving the rest
        /// untouched. Prefer this over Put for partial updates so two people
        /// editing different fields do not overwrite each other.</summary>
        public static string Patch(string path, object value)
        {
            return Send("PATCH", path, Json.Serialize(value));
        }

        /// <summary>Appends a child under a generated key and returns that key.</summary>
        public static string Push(string path, object value)
        {
            string response = Send("POST", path, Json.Serialize(value));
            Dictionary<string, object> map = Json.ToMap(response);
            object name;
            return map.TryGetValue("name", out name) ? Convert.ToString(name) : null;
        }

        public static void Delete(string path)
        {
            Send("DELETE", path, null);
        }

        // Firebase rejects this write with 412 if another caller filled the node.
        public static bool PutIfEmpty(string path, object value)
        {
            return Send("PUT", path, Json.Serialize(value), onlyIfEmpty: true) != null;
        }

        public static string GetWithEtag(string path, out string etag) { return GetVersioned(path, out etag); }
        public static bool PutIfUnchanged(string path, object value, string etag) { return PutIfVersion(path, value, etag); }

        public static string GetVersioned(string path, out string etag)
        {
            string version = null;
            string json = Send("GET", path, null, captureETag: value => version = value);
            etag = version;
            return json;
        }

        public static bool PutIfVersion(string path, object value, string etag)
        {
            if (string.IsNullOrEmpty(etag)) throw new InvalidOperationException("Missing Firebase version; reload the review.");
            return Send("PUT", path, Json.Serialize(value), ifMatch: etag) != null;
        }

        private static string Send(string method, string path, string body, string query = null,
                                   bool onlyIfEmpty = false, bool retried = false,
                                   string ifMatch = null, Action<string> captureETag = null)
        {
            string url = BuildUrl(path, query);
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = method;
            request.ContentType = "application/json; charset=utf-8";
            request.Accept = "application/json";
            request.Timeout = 30000;
            request.KeepAlive = true;
            if (onlyIfEmpty) request.Headers["if-match"] = "null_etag";
            if (ifMatch != null) request.Headers["if-match"] = ifMatch;
            if (captureETag != null) request.Headers["X-Firebase-ETag"] = "true";

            try
            {
                if (!string.IsNullOrEmpty(body))
                {
                    byte[] payload = Encoding.UTF8.GetBytes(body);
                    request.ContentLength = payload.Length;
                    using (Stream stream = request.GetRequestStream())
                    {
                        stream.Write(payload, 0, payload.Length);
                    }
                }
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream(), Encoding.UTF8))
                {
                    if (captureETag != null) captureETag(response.Headers["ETag"]);
                    string text = reader.ReadToEnd();
                    return text == "null" ? null : text;
                }
            }
            catch (WebException ex)
            {
                HttpWebResponse response = ex.Response as HttpWebResponse;
                if ((onlyIfEmpty || ifMatch != null) && response != null && response.StatusCode == HttpStatusCode.PreconditionFailed)
                {
                    response.Dispose();
                    return null;
                }
                if (!retried && response != null &&
                    (response.StatusCode == HttpStatusCode.Unauthorized || response.StatusCode == HttpStatusCode.Forbidden))
                {
                    response.Dispose();
                    var session = HttpContext.Current == null ? null : HttpContext.Current.Session;
                    string refreshToken = session == null ? null : session[Common.Constants.SessionRefreshTokenKey] as string;
                    Services.AuthResult refreshed = Services.AuthService.RefreshIdToken(refreshToken);
                    if (!refreshed.Success || session == null) throw new FirebaseAuthExpiredException();
                    session[Common.Constants.SessionTokenKey] = refreshed.IdToken;
                    session[Common.Constants.SessionRefreshTokenKey] = refreshed.RefreshToken;
                    return Send(method, path, body, query, onlyIfEmpty, true, ifMatch, captureETag);
                }
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
