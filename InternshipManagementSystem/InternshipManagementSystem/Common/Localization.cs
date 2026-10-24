// =============================================================================
//  UIMS - Group 4
//  Arabic / English interface language.
//
//  - The language lives in the first-party cookie "uims-lang" (only "en" or "ar"
//    are accepted; anything else means English). Global.asax applies it at the
//    start of every request, before any page renders.
//  - English uses en-US (the server's existing culture, so English output is
//    unchanged). Arabic uses ar-JO: Gregorian calendar, "." decimals and Latin
//    digits, so parsing, calculations and data sent to scripts are unaffected.
//  - Text comes from App_GlobalResources/<Area>.resx (English) and
//    <Area>.ar.resx (Arabic). Keys are "<Area>.<Key>", e.g. "Shared.Nav.Home".
//    A missing Arabic entry falls back to English and is recorded as a gap.
//  - Stored values (status codes, roles, Firebase fields) are never translated;
//    only their displayed labels are.
//  See docs/34-localization.md.
// =============================================================================
using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Resources;
using System.Threading;
using System.Web;
using System.Web.Compilation;

namespace InternshipManagementSystem.Common
{
    public static class L
    {
        public const string CookieName = "uims-lang";
        public const string SwitchParameter = "ui-lang";
        private static readonly CultureInfo English = CultureInfo.GetCultureInfo("en-US");
        private static readonly CultureInfo Arabic = CultureInfo.GetCultureInfo("ar-JO");
        private const string MissingKey = "UIMS.MissingText";

        public static bool IsArabic { get { return Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName == "ar"; } }
        public static string Lang { get { return IsArabic ? "ar" : "en"; } }
        public static string Dir { get { return IsArabic ? "rtl" : "ltr"; } }

        /// <summary>Accepts only the supported codes; everything else is English.</summary>
        public static string Normalize(string value)
        {
            return string.Equals(value, "ar", StringComparison.OrdinalIgnoreCase) ? "ar" : "en";
        }

        /// <summary>Sets the request's display culture from the cookie. Called by Global.asax.</summary>
        public static void Apply(HttpContext context)
        {
            HttpCookie cookie = context == null ? null : context.Request.Cookies[CookieName];
            CultureInfo culture = Normalize(cookie == null ? null : cookie.Value) == "ar" ? Arabic : English;
            Thread.CurrentThread.CurrentUICulture = culture;
            Thread.CurrentThread.CurrentCulture = culture;
        }

        /// <summary>Stores the choice: first-party, one year, Lax, HttpOnly (the server reads it; scripts never need to).</summary>
        public static void Save(HttpContext context, string lang)
        {
            var cookie = new HttpCookie(CookieName, Normalize(lang))
            {
                Path = "/", HttpOnly = true, Expires = DateTime.UtcNow.AddYears(1), Secure = context.Request.IsSecureConnection
            };
            cookie.SameSite = SameSiteMode.Lax;
            context.Response.Cookies.Set(cookie);
        }

        /// <summary>Translated text for "Area.Key". Missing Arabic falls back to English; a missing key shows the key.</summary>
        public static string T(string id)
        {
            if (string.IsNullOrEmpty(id)) return "";
            int dot = id.IndexOf('.');
            if (dot <= 0) return id;
            string area = id.Substring(0, dot), key = id.Substring(dot + 1);
            string value = Lookup(area, key, Thread.CurrentThread.CurrentUICulture, out bool exact);
            if (value != null && exact) return value;
            Record(id, value == null ? "missing" : "fallback");
            return value ?? id;
        }

        /// <summary>The English text for "Area.Key", whatever language the current
        /// user reads. Used for text that is saved, such as a notification's fallback.</summary>
        public static string InEnglish(string id)
        {
            if (string.IsNullOrEmpty(id)) return "";
            int dot = id.IndexOf('.');
            if (dot <= 0) return id;
            string value = Lookup(id.Substring(0, dot), id.Substring(dot + 1), CultureInfo.InvariantCulture, out bool exact);
            return value ?? id;
        }

        /// <summary>True when "Area.Key" exists in the resource files.</summary>
        public static bool Has(string id)
        {
            if (string.IsNullOrEmpty(id)) return false;
            int dot = id.IndexOf('.');
            if (dot <= 0) return false;
            return Lookup(id.Substring(0, dot), id.Substring(dot + 1), CultureInfo.InvariantCulture, out bool exact) != null;
        }

        /// <summary>Formatted text: L.F("Portal.HoursOf", approved, required). Uses the display culture.</summary>
        public static string F(string id, params object[] args)
        {
            return string.Format(CultureInfo.CurrentCulture, T(id), args);
        }

        /// <summary>Text for HTML attributes and markup (encoded).</summary>
        public static IHtmlString H(string id) { return new HtmlString(HttpUtility.HtmlEncode(T(id))); }

        private static string Lookup(string area, string key, CultureInfo culture, out bool exact)
        {
            exact = false;
            object value = null;
            try { value = HttpContext.GetGlobalResourceObject(area, key, culture); } catch (MissingManifestResourceException) { }
            if (value == null) return null;
            // GetGlobalResourceObject already falls back to English; tell the two apart for coverage reporting.
            if (culture.TwoLetterISOLanguageName == "ar")
            {
                ResourceManager manager = Manager(area);
                ResourceSet arabic = manager == null ? null : manager.GetResourceSet(CultureInfo.GetCultureInfo("ar"), true, false);
                exact = arabic != null && arabic.GetString(key) != null;
            }
            else exact = true;
            return value as string;
        }

        private static readonly Dictionary<string, ResourceManager> managers = new Dictionary<string, ResourceManager>();
        private static ResourceManager Manager(string area)
        {
            lock (managers)
            {
                ResourceManager manager;
                if (managers.TryGetValue(area, out manager)) return manager;
                Type type = BuildManager.GetType("Resources." + area, false);
                var property = type == null ? null : type.GetProperty("ResourceManager", System.Reflection.BindingFlags.Static | System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic);
                manager = property == null ? null : property.GetValue(null, null) as ResourceManager;
                managers[area] = manager;
                return manager;
            }
        }

        private static void Record(string id, string kind)
        {
            HttpContext context = HttpContext.Current;
            if (context == null) return;
            var list = context.Items[MissingKey] as List<string>;
            if (list == null) context.Items[MissingKey] = list = new List<string>();
            if (!list.Contains(kind + ":" + id)) list.Add(kind + ":" + id);
            // Trace output is slow while Visual Studio's debugger listens, and the
            // same gaps repeat on every page, so each one is written only once.
            bool first;
            lock (traced) first = traced.Add(kind + ":" + id);
            if (first) System.Diagnostics.Trace.TraceWarning("UIMS localization " + kind + ": " + id);
        }

        private static readonly HashSet<string> traced = new HashSet<string>(StringComparer.Ordinal);

        /// <summary>Keys that fell back or were missing on this request (rendered as a data attribute for tests).</summary>
        public static string Gaps
        {
            get
            {
                var list = HttpContext.Current == null ? null : HttpContext.Current.Items[MissingKey] as List<string>;
                return list == null ? "" : string.Join(" ", list);
            }
        }

        /// <summary>Script text: every "Js.*" entry of the Shared area, as a JSON object for window.UIMS_I18N.</summary>
        public static IHtmlString ScriptDictionary()
        {
            var result = new SortedDictionary<string, string>(StringComparer.Ordinal);
            ResourceManager manager = Manager("Shared");
            ResourceSet neutral = manager == null ? null : manager.GetResourceSet(CultureInfo.InvariantCulture, true, true);
            if (neutral != null)
                foreach (DictionaryEntry entry in neutral)
                {
                    string key = entry.Key as string;
                    if (key != null && key.StartsWith("Js.", StringComparison.Ordinal)) result[key.Substring(3)] = T("Shared." + key);
                }
            string json = new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(result);
            // Safe inside a <script> element.
            json = json.Replace("<", "\\u003c").Replace(">", "\\u003e").Replace("&", "\\u0026");
            return new HtmlString(json);
        }

        /// <summary>The current page in the other language: same path and query, plus ui-lang (handled as a GET).</summary>
        public static string SwitchUrl(string lang)
        {
            HttpRequest request = HttpContext.Current.Request;
            string path;
            var query = OriginalQuery(request, out path);
            query.Remove(SwitchParameter);
            query[SwitchParameter] = Normalize(lang);
            return path + "?" + query.ToString();
        }

        /// <summary>Handles ?ui-lang= on a GET: saves the choice and redirects to the same URL without it.</summary>
        public static bool HandleSwitch(HttpContext context)
        {
            HttpRequest request = context.Request;
            string path;
            var query = OriginalQuery(request, out path);
            string requested = query[SwitchParameter];
            if (requested == null || !string.Equals(request.HttpMethod, "GET", StringComparison.OrdinalIgnoreCase)) return false;
            Save(context, requested);
            query.Remove(SwitchParameter);
            string rest = query.ToString();
            context.Response.Redirect(path + (rest.Length > 0 ? "?" + rest : ""), false);
            context.ApplicationInstance.CompleteRequest();
            return true;
        }

        // IIS ExecuteURL rewrites Path and QueryString to the error handler, while
        // RawUrl retains the browser's original request. Keep one language controller
        // for both normal pages and internally executed error documents.
        private static System.Collections.Specialized.NameValueCollection OriginalQuery(HttpRequest request, out string path)
        {
            string raw = request.RawUrl ?? request.Path;
            int marker = raw.IndexOf('?');
            path = marker < 0 ? raw : raw.Substring(0, marker);
            string decoded = HttpUtility.UrlDecode(path);
            if (!decoded.StartsWith("/", StringComparison.Ordinal) || decoded.StartsWith("//", StringComparison.Ordinal) ||
                decoded.IndexOf('\\') >= 0 || decoded.IndexOf('\r') >= 0 || decoded.IndexOf('\n') >= 0)
            {
                path = VirtualPathUtility.ToAbsolute("~/Default.aspx");
                return HttpUtility.ParseQueryString("");
            }
            return HttpUtility.ParseQueryString(marker < 0 ? "" : raw.Substring(marker + 1));
        }

        // ------------------------------------------------------------------ display labels for stored values
        /// <summary>Display label for a stored value (status, role, ...): key "Shared.Value.<group>.<value>"; unknown values show as stored.</summary>
        public static string Value(string group, object stored)
        {
            string raw = stored == null ? "" : stored.ToString();
            if (raw.Length == 0) return raw;
            // Resource keys hold letters and digits only: "On-site" is looked up as Value.TrainingMode.Onsite.
            string key = "Value." + group + "." + System.Text.RegularExpressions.Regex.Replace(raw, "[^A-Za-z0-9_]", "");
            string id = "Shared." + key;
            string text = Lookup("Shared", key, Thread.CurrentThread.CurrentUICulture, out bool exact);
            if (text == null) return raw;
            if (!exact) Record(id, "fallback");
            return text;
        }

        public static string Role(UserRole role) { return T("Shared.Role." + role); }

        /// <summary>Page title by route: "Shared.Title.Pages.Public.About" (the page directive's Title is the English source).</summary>
        public static string PageTitle(System.Web.UI.Page page)
        {
            string path = (page.AppRelativeVirtualPath ?? "").TrimStart('~', '/');
            if (path.EndsWith(".aspx", StringComparison.OrdinalIgnoreCase)) path = path.Substring(0, path.Length - 5);
            string key = "Title." + path.Replace('/', '.');
            string value = Lookup("Shared", key, Thread.CurrentThread.CurrentUICulture, out bool exact);
            if (value == null) { if (!string.IsNullOrEmpty(page.Title)) Record("Shared." + key, "missing"); return page.Title; }
            if (!exact) Record("Shared." + key, "fallback");
            return value;
        }
    }
}
