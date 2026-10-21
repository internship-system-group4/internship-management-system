// =============================================================================
//  Contact Messages
//  Owner : Sara Dolat
//  Cards : D02, D03
//
//  Inbox of Contact Us messages with sender, subject, body and date, plus a mark-as-reviewed action.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================


using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml.Linq;



namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class CoordinatorContactMessages : Page
    {
        // Firebase database URL from Web.config
        private string FirebaseUrl
        {
            get
            {
                return (ConfigurationManager.AppSettings["FirebaseDatabaseUrl"] ?? "")
                    .TrimEnd('/');
            }
        }

        // Firebase token saved after login
        private string FirebaseAuthToken
        {
            get
            {
                return Convert.ToString(Session["FirebaseIdToken"]);
            }
        }

        // Represents a contact message
        private class ContactMessage
        {
            public string Id { get; set; }
            public string Name { get; set; }
            public string Email { get; set; }
            public string Subject { get; set; }
            public string Message { get; set; }
            public string Status { get; set; }
            public long SubmittedAt { get; set; }

            public string FormattedDate
            {
                get { return FormatDate(SubmittedAt); }
            }
        }

        // Check access and load messages
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["UserId"] == null ||
                !string.Equals(
                    Convert.ToString(Session["Role"]),
                    "Coordinator",
                    StringComparison.OrdinalIgnoreCase))
            {
                Response.Redirect("~/Login.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            if (!IsPostBack)
            {
                RegisterAsyncTask(new PageAsyncTask(LoadMessagesAsync));
            }
        }

        // Build Firebase REST URL
        private string MessageUrl(string id = null)
        {
            if (string.IsNullOrWhiteSpace(FirebaseUrl))
                throw new InvalidOperationException(
                    "FirebaseDatabaseUrl is missing.");

            string path = "/ContactMessages" +
                (id == null ? "" : "/" + Uri.EscapeDataString(id)) +
                ".json";

            string token = FirebaseAuthToken;

            if (string.IsNullOrWhiteSpace(token))
                throw new InvalidOperationException(
                    "Firebase authentication token is missing.");

            return FirebaseUrl + path +
                "?auth=" + Uri.EscapeDataString(token);
        }

        // Get all messages from Firebase
        private async Task<List<ContactMessage>> GetMessagesAsync()
        {
            using (var client = new HttpClient())
            using (var response = await client.GetAsync(MessageUrl()))
            {
                response.EnsureSuccessStatusCode();

                string json = await response.Content.ReadAsStringAsync();

                var root = JToken.Parse(json);
                var results = new List<ContactMessage>();
                var obj = root as JObject;

                if (obj == null)
                    return results;

                foreach (var item in obj.Properties())
                {
                    var m = item.Value as JObject;

                    if (m == null)
                        continue;

                    results.Add(new ContactMessage
                    {
                        Id = item.Name,
                        Name = (string)m["Name"] ?? "Unknown",
                        Email = (string)m["Email"] ?? "",
                        Subject = (string)m["Subject"] ?? "",
                        Message = (string)m["Message"] ?? "",
                        Status = string.Equals(
                            (string)m["Status"],
                            "Reviewed",
                            StringComparison.OrdinalIgnoreCase)
                            ? "Reviewed" : "New",
                        SubmittedAt = ParseTimestamp(m["SubmittedAt"])
                    });
                }

                // Newest messages first
                return results
                    .OrderByDescending(x => x.SubmittedAt)
                    .ToList();
            }
        }

        // Convert Firebase timestamp
        private static long ParseTimestamp(JToken value)
        {
            if (value == null)
                return 0;

            long number;

            if (long.TryParse(value.ToString(), out number))
                return number;

            DateTimeOffset date;

            if (DateTimeOffset.TryParse(
                value.ToString(),
                CultureInfo.InvariantCulture,
                DateTimeStyles.AssumeUniversal,
                out date))
            {
                return date.ToUnixTimeMilliseconds();
            }

            return 0;
        }

        // Format date for display
        private static string FormatDate(long value)
        {
            try
            {
                return value > 0
                    ? DateTimeOffset.FromUnixTimeMilliseconds(value)
                        .ToOffset(TimeSpan.FromHours(3))
                        .ToString(
                            "MMM dd, yyyy hh:mm tt",
                            CultureInfo.InvariantCulture)
                    : "Unknown";
            }
            catch
            {
                return "Unknown";
            }
        }

        // Shorten the message in the table
        protected string Shorten(string value, int max)
        {
            value = (value ?? "")
                .Replace("\r", " ")
                .Replace("\n", " ");

            return value.Length <= max
                ? value
                : value.Substring(0, max).TrimEnd() + "...";
        }

        // Load summary cards and filtered table
        private async Task LoadMessagesAsync()
        {
            try
            {
                lblError.Visible = false;

                var all = await GetMessagesAsync();

                // Summary cards
                litTotal.Text = all.Count.ToString();

                litNew.Text = all.Count(
                    x => x.Status == "New").ToString();

                litReviewed.Text = all.Count(
                    x => x.Status == "Reviewed").ToString();

                string search = (txtSearch.Text ?? "").Trim();
                string status = ddlStatus.SelectedValue;

                // Search by name, email, subject, or message
                var filtered = all.Where(x =>
                    (status == "All" || x.Status == status) &&
                    (search.Length == 0 ||
                        new[]
                        {
                            x.Name,
                            x.Email,
                            x.Subject,
                            x.Message
                        }.Any(s =>
                            (s ?? "").IndexOf(
                                search,
                                StringComparison.OrdinalIgnoreCase) >= 0)))
                    .ToList();

                gvMessages.DataSource = filtered;
                gvMessages.DataBind();
            }
            catch (Exception)
            {
                lblError.Text =
                    "Unable to load messages. Check Firebase URL, " +
                    "authentication and database rules.";

                lblError.Visible = true;
            }
        }

        // Search button
        protected void btnSearch_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;

            RegisterAsyncTask(
                new PageAsyncTask(LoadMessagesAsync));
        }

        // Open message details
        protected void gvMessages_RowCommand(
            object sender,
            GridViewCommandEventArgs e)
        {
            if (e.CommandName != "Details")
                return;

            string id = Convert.ToString(e.CommandArgument);

            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                try
                {
                    var item = (await GetMessagesAsync())
                        .FirstOrDefault(x => x.Id == id);

                    if (item == null)
                    {
                        pnlDetails.Visible = false;
                        return;
                    }

                    ViewState["SelectedMessageId"] = item.Id;

                    // HTML encoding protects displayed text
                    litFrom.Text = HttpUtility.HtmlEncode(item.Name);
                    litEmail.Text = HttpUtility.HtmlEncode(item.Email);
                    litSubject.Text = HttpUtility.HtmlEncode(item.Subject);
                    litSubmitted.Text = HttpUtility.HtmlEncode(
                        item.FormattedDate);

                    litStatus.Text =
                        "<span class='status-badge " +
                        (item.Status == "Reviewed" ? "reviewed" : "new") +
                        "'>" + item.Status + "</span>";

                    litFullMessage.Text =
                        HttpUtility.HtmlEncode(item.Message)
                            .Replace("\r\n", "\n")
                            .Replace("\n", "<br />");

                    btnMarkReviewed.Visible =
                        item.Status != "Reviewed";

                    // Open email application
                    lnkReply.NavigateUrl =
                        "mailto:" + Uri.EscapeDataString(item.Email) +
                        "?subject=" +
                        Uri.EscapeDataString("Re: " + item.Subject);

                    pnlDetails.Visible = true;
                }
                catch (Exception)
                {
                    lblError.Text = "Unable to open message details.";
                    lblError.Visible = true;
                }
            }));
        }

        // Close message details
        protected void btnClose_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            ViewState.Remove("SelectedMessageId");
        }

        // Update message status in Firebase
        protected void btnMarkReviewed_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(new PageAsyncTask(async () =>
            {
                try
                {
                    string id = Convert.ToString(
                        ViewState["SelectedMessageId"]);

                    if (string.IsNullOrWhiteSpace(id))
                        return;

                    // PATCH updates only the Status field
                    using (var client = new HttpClient())
                    using (var content = new StringContent(
                        "{\"Status\":\"Reviewed\"}",
                        Encoding.UTF8,
                        "application/json"))
                    using (var request = new HttpRequestMessage(
                        new HttpMethod("PATCH"),
                        MessageUrl(id))
                    { Content = content })
                    using (var response = await client.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                    }

                    pnlDetails.Visible = false;
                    ViewState.Remove("SelectedMessageId");

                    // Refresh cards and table
                    await LoadMessagesAsync();
                }
                catch (Exception)
                {
                    lblError.Text =
                        "Could not update the message status.";
                    lblError.Visible = true;
                }
            }));
        }

        // Logout
        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();

            Response.Redirect("~/Login.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }
    }
}

