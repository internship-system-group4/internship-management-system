using System;
using System.Collections.Generic;
using System.IO;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Web.Configuration;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Services
{
    public sealed class ZoomMeetingResult
    {
        public string MeetingId { get; set; }
        public string JoinUrl { get; set; }
    }

    public static class ZoomMeetingService
    {
        private static string Setting(string key)
        {
            return (WebConfigurationManager.AppSettings[key] ?? "").Trim();
        }

        public static bool IsConfigured
        {
            get
            {
                return Setting("Zoom.AccountId").Length > 0
                    && Setting("Zoom.ClientId").Length > 0
                    && Setting("Zoom.ClientSecret").Length > 0
                    && Setting("Zoom.HostEmail").Length > 0;
            }
        }

        public static ZoomMeetingResult Create(string title, string agenda, DateTime startUtc, int durationMinutes)
        {
            if (!IsConfigured) throw new InvalidOperationException("Zoom meeting creation is not configured. Ask the administrator to add the Zoom credentials and host email.");

            string credentials = Convert.ToBase64String(Encoding.UTF8.GetBytes(
                Setting("Zoom.ClientId") + ":" + Setting("Zoom.ClientSecret")));
            string tokenUrl = "https://zoom.us/oauth/token?grant_type=account_credentials&account_id="
                + Uri.EscapeDataString(Setting("Zoom.AccountId"));
            Dictionary<string, object> token = Request(tokenUrl, "POST", "Basic " + credentials, null);
            string accessToken = Value(token, "access_token");
            if (string.IsNullOrEmpty(accessToken)) throw new InvalidOperationException("Zoom did not return an access token.");

            var body = new Dictionary<string, object>
            {
                { "topic", title },
                { "agenda", agenda ?? "" },
                { "type", 2 },
                { "start_time", startUtc.ToString("yyyy-MM-ddTHH:mm:ssZ") },
                { "timezone", "UTC" },
                { "duration", durationMinutes },
                { "password", NewPasscode() },
                { "settings", new Dictionary<string, object>
                    { { "waiting_room", false }, { "join_before_host", true } } }
            };
            string url = "https://api.zoom.us/v2/users/" + Uri.EscapeDataString(Setting("Zoom.HostEmail")) + "/meetings";
            Dictionary<string, object> meeting = Request(url, "POST", "Bearer " + accessToken, Json.Serialize(body));
            string joinUrl = Value(meeting, "join_url");
            Uri parsed;
            if (!Uri.TryCreate(joinUrl, UriKind.Absolute, out parsed) || parsed.Scheme != Uri.UriSchemeHttps
                || !(parsed.Host.Equals("zoom.us", StringComparison.OrdinalIgnoreCase)
                     || parsed.Host.EndsWith(".zoom.us", StringComparison.OrdinalIgnoreCase)))
                throw new InvalidOperationException("Zoom did not return a valid join link.");
            return new ZoomMeetingResult { MeetingId = Value(meeting, "id"), JoinUrl = joinUrl };
        }

        private static string Value(Dictionary<string, object> map, string key)
        {
            object value;
            return map != null && map.TryGetValue(key, out value) && value != null ? Convert.ToString(value) : null;
        }

        private static string NewPasscode()
        {
            byte[] bytes = new byte[10];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create()) random.GetBytes(bytes);
            StringBuilder result = new StringBuilder(10);
            foreach (byte value in bytes) result.Append((char)('0' + value % 10));
            return result.ToString();
        }

        private static Dictionary<string, object> Request(string url, string method, string authorization, string json)
        {
            HttpWebRequest request = (HttpWebRequest)WebRequest.Create(url);
            request.Method = method;
            request.Timeout = 15000;
            request.Headers[HttpRequestHeader.Authorization] = authorization;
            if (json != null)
            {
                byte[] bytes = Encoding.UTF8.GetBytes(json);
                request.ContentType = "application/json";
                request.ContentLength = bytes.Length;
                using (Stream stream = request.GetRequestStream()) stream.Write(bytes, 0, bytes.Length);
            }
            try
            {
                using (HttpWebResponse response = (HttpWebResponse)request.GetResponse())
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                    return Json.ToMap(reader.ReadToEnd());
            }
            catch (WebException ex)
            {
                System.Diagnostics.Trace.TraceError("Zoom API request failed: {0}", ex);
                throw new InvalidOperationException("Zoom could not create the meeting. Check the app credentials, meeting scope, and host account, then try again.", ex);
            }
        }
    }
}
