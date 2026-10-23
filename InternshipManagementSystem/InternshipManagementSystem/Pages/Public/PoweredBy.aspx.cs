// =============================================================================
//  Meet the Team (Powered by)
//
//  Credits the people who designed and developed UIMS. The roster lives in one
//  file, App_Data/development-team.json (not web-served). Add a person only
//  after they approve each field for public display; the page shows an honest
//  empty state until then. Development credit is not university endorsement.
//
//  The page is a 3D lecture hall (Assets/js/powered-by.js + powered-by-hall.js).
//  The roster below is rendered as real HTML: it feeds the in-hall profile panel
//  and is the visible fallback when JavaScript, WebGL or the scene fails.
//
//  Namespace note: these page namespaces end in "Area" on purpose. See About.aspx.cs.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class PoweredBy : System.Web.UI.Page
    {
        public class TeamRoster
        {
            public string Note { get; set; }
            public List<TeamMember> Members { get; set; }
        }

        public class TeamMember
        {
            public string Key { get; set; }
            public string Seat { get; set; }
            public string Name { get; set; }
            public string Role { get; set; }
            public string Bio { get; set; }
            public string Photo { get; set; }
            public string GitHub { get; set; }
            public string LinkedIn { get; set; }
            public string Portfolio { get; set; }
            public string Email { get; set; }
        }

        protected List<TeamMember> Members { get; private set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            Members = LoadRoster();
        }

        private List<TeamMember> LoadRoster()
        {
            try
            {
                string path = Server.MapPath("~/App_Data/development-team.json");
                if (!File.Exists(path)) return new List<TeamMember>();
                var roster = Json.Deserialize<TeamRoster>(File.ReadAllText(path));
                var members = (roster?.Members ?? new List<TeamMember>())
                    .Where(m => m != null && !string.IsNullOrWhiteSpace(m.Name) && !string.IsNullOrWhiteSpace(m.Role))
                    .ToList();
                // Every member needs a stable, unique key; a missing or malformed one is derived from the name.
                var used = new HashSet<string>(StringComparer.Ordinal);
                foreach (var member in members)
                {
                    string key = ValidKey(member.Key) ?? Slug(member.Name);
                    string candidate = key; int n = 2;
                    while (!used.Add(candidate)) candidate = key + "-" + n++;
                    member.Key = candidate;
                    member.Seat = ValidSeat(member.Seat);
                }
                return members;
            }
            catch (ArgumentException) { return new List<TeamMember>(); }   // malformed JSON
            catch (InvalidOperationException) { return new List<TeamMember>(); }
        }

        private static string ValidKey(string key)
        {
            string value = (key ?? "").Trim();
            return System.Text.RegularExpressions.Regex.IsMatch(value, "^[a-z0-9]+(-[a-z0-9]+)*$") && value.Length <= 40 ? value : null;
        }

        private static string Slug(string name)
        {
            string slug = System.Text.RegularExpressions.Regex.Replace(name.ToLowerInvariant(), "[^a-z0-9]+", "-").Trim('-');
            return slug.Length > 0 ? (slug.Length > 40 ? slug.Substring(0, 40).Trim('-') : slug) : "member";
        }

        // Seat ids look like C4-5 (block, row 1-7, seat from the left). The scene checks the seat exists.
        private static string ValidSeat(string seat)
        {
            string value = (seat ?? "").Trim().ToUpperInvariant();
            return System.Text.RegularExpressions.Regex.IsMatch(value, "^[LCR][1-7]-[1-9][0-9]?$") ? value : null;
        }

        // Only https profile links are rendered; anything else is omitted.
        protected static string SafeLink(string url)
        {
            Uri uri;
            return Uri.TryCreate((url ?? "").Trim(), UriKind.Absolute, out uri) && uri.Scheme == Uri.UriSchemeHttps
                ? uri.AbsoluteUri : null;
        }

        // A single plain address only; anything else (lists, headers, line breaks) is omitted.
        protected static string SafeEmail(string email)
        {
            string value = (email ?? "").Trim();
            if (value.Length == 0 || value.IndexOfAny(new[] { ',', ';', '?', '\r', '\n', ' ' }) >= 0) return null;
            try { return new System.Net.Mail.MailAddress(value).Address == value ? value : null; }
            catch (FormatException) { return null; }
        }

        // Photos must be supplied files under ~/Assets/images/team/; otherwise initials are shown.
        protected string PhotoUrl(TeamMember member)
        {
            string photo = (member.Photo ?? "").Trim();
            if (!photo.StartsWith("~/Assets/images/team/", StringComparison.OrdinalIgnoreCase) || photo.Contains("..")) return null;
            if (!File.Exists(Server.MapPath(photo))) return null;
            // Prefer the 240px copy made by tools/New-TeamPhotoThumbnails.ps1; the original stays the source.
            string small = "~/Assets/images/team/small/" + Path.GetFileNameWithoutExtension(photo) + ".jpg";
            if (File.Exists(Server.MapPath(small))) photo = small;
            // Supplied file names may contain spaces, so the path is percent-encoded.
            return System.Web.HttpUtility.UrlPathEncode(ResolveUrl(photo));
        }

        // The scene only needs keys, seats and labels; profile details stay in the HTML roster.
        // Escaped so the JSON can sit inside a <script type="application/json"> block.
        protected string TeamJson()
        {
            var data = Members.Select(m => new { key = m.Key, seat = m.Seat, name = m.Name, role = m.Role });
            return new System.Web.Script.Serialization.JavaScriptSerializer().Serialize(data)
                .Replace("<", "\\u003c").Replace(">", "\\u003e").Replace("&", "\\u0026");
        }

        protected static string Initials(string name)
        {
            var words = name.Split((char[])null, StringSplitOptions.RemoveEmptyEntries);
            string first = StringInfo.GetNextTextElement(words[0]);
            string last = words.Length > 1 ? StringInfo.GetNextTextElement(words[words.Length - 1]) : "";
            return (first + last).ToUpper(CultureInfo.CurrentCulture);
        }
    }
}
