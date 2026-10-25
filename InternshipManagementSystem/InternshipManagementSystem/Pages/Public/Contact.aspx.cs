
using System;
using System.Collections.Generic;
using InternshipManagementSystem.Common;
using System.Configuration;
using System.Net.Http;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;
using System.Web;
using System.Web.UI;
using Newtonsoft.Json;

namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class Contact : System.Web.UI.Page
    {
        // One-time flag set after Firebase confirms the save; the redirected GET shows "Message sent" once.
        private const string SentFlag = "UIMS.Contact.Sent";
        private const string CompletedRequests = "UIMS.Contact.CompletedRequests";

        protected override void OnInit(EventArgs e)
        {
            // Persist the anonymous session before binding the form's view-state MAC.
            // A read-only session may otherwise have no cookie on the first GET.
            if (Session["UIMS.Contact.SessionStarted"] == null) Session["UIMS.Contact.SessionStarted"] = true;
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }

        // Limits shared with the markup (minlength/maxlength) and the client checks in public-forms.js.
        private const int NameMin = 2, NameMax = 100;
        private const int EmailMax = 254;
        private const int SubjectMin = 5, SubjectMax = 150;
        private const int MessageMin = 20, MessageMax = 4000;

        protected bool SentConfirmed;
        protected string NameError = "", EmailError = "", SubjectError = "", MessageError = "";

        private string FirebaseUrl
        {
            get
            {
                return (
                    ConfigurationManager.AppSettings["Firebase.DatabaseUrl"] ?? ""
                ).TrimEnd('/');
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            txtMessage.Attributes["placeholder"] = L.T("Public.Contact.MessagePlaceholder");

            if (!IsPostBack)
            {
                ViewState["ContactRequestId"] = Guid.NewGuid().ToString("N");
                lblMessage.Visible = false;

                if (Session[SentFlag] != null)
                {
                    Session.Remove(SentFlag);
                    SentConfirmed = true;
                }
            }
        }

        protected void btnSend_Click(object sender, EventArgs e)
        {
            RegisterAsyncTask(
                new PageAsyncTask(SaveMessageAsync)
            );
        }

        private async Task SaveMessageAsync()
        {
            lblMessage.Visible = false;
            string requestId = ViewState["ContactRequestId"] as string;
            var completed = Session[CompletedRequests] as HashSet<string> ?? new HashSet<string>();
            if (!string.IsNullOrEmpty(requestId) && completed.Contains(requestId))
            {
                ConfirmSent();
                return;
            }

            string name = (txtName.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim();
            string subject = (txtSubject.Text ?? "").Trim();
            string message = (txtMessage.Text ?? "").Trim();

            // Check every field so each error appears beside its own field.
            if (name.Length == 0)
                NameError = L.T("Public.Contact.EnterYourFullName");
            else if (name.Length < NameMin || name.Length > NameMax)
                NameError = L.T("Public.Contact.YourNameNeeds2To100");

            if (email.Length == 0)
                EmailError = L.T("Public.Contact.EnterYourEmailAddress");
            else if (email.Length > EmailMax ||
                !Regex.IsMatch(
                    email,
                    @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
                EmailError = L.T("Public.Contact.EnterAnEmailAddressLikeName");

            if (subject.Length == 0)
                SubjectError = L.T("Public.Contact.EnterASubjectForYourMessage");
            else if (subject.Length < SubjectMin || subject.Length > SubjectMax)
                SubjectError = L.T("Public.Contact.YourSubjectNeeds5To150");

            if (message.Length == 0)
                MessageError = L.T("Public.Contact.EnterYourMessage");
            else if (message.Length < MessageMin || message.Length > MessageMax)
                MessageError = L.T("Public.Contact.YourMessageNeeds20To4");

            MarkInvalid(txtName, NameError);
            MarkInvalid(txtEmail, EmailError);
            MarkInvalid(txtSubject, SubjectError);
            MarkInvalid(txtMessage, MessageError);

            if (NameError.Length + EmailError.Length + SubjectError.Length + MessageError.Length > 0)
            {
                ShowMessage(
                    L.T("Public.Contact.SomeDetailsNeedAttentionCheckThe"));
                return;
            }

            try
            {
                if (string.IsNullOrWhiteSpace(FirebaseUrl))
                    throw new InvalidOperationException(
                        "Firebase.DatabaseUrl is not configured.");

                // Message data saved to Firebase
                var contactMessage = new
                {
                    Name = name,
                    Email = email,
                    Subject = subject,
                    Message = message,
                    Status = "New",
                    SubmittedAt =
                        DateTimeOffset.UtcNow.ToUnixTimeMilliseconds()
                };

                string json =
                    JsonConvert.SerializeObject(contactMessage);

                // Send directly to Firebase without user authentication.
                // Firebase generates a unique key for the new message.
                using (var client = new HttpClient { Timeout = TimeSpan.FromSeconds(15) })
                using (var content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"))
                using (var response = await client.PostAsync(
                    FirebaseUrl + "/ContactMessages.json",
                    content))
                {
                    if (!response.IsSuccessStatusCode)
                        throw new HttpRequestException(
                            "Firebase rejected the contact message: " +
                            (int)response.StatusCode);
                }
            }
            catch (Exception ex)
            {
                // The visitor keeps everything they typed; the technical reason goes to the trace log only.
                Trace.Warn("Contact", "Message not saved", ex);
                ShowMessage(
                    L.T("Public.Contact.YourMessageCouldNotBeSent"));
                return;
            }

            // Saved. Post/redirect/get: a refresh cannot send it twice, and the form starts empty. The query only
            // gives the confirmation its own URL, so "Send another message" is a real page load; the one-time
            // session flag, not the query, decides whether "Message sent" appears.
            if (!string.IsNullOrEmpty(requestId))
            {
                completed.Add(requestId);
                Session[CompletedRequests] = completed;
            }
            ConfirmSent();
        }

        private void ConfirmSent()
        {
            Session[SentFlag] = true;
            Response.Redirect(
                ResolveUrl("~/Pages/Public/Contact.aspx") + "?sent=1#contact-form",
                false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static void MarkInvalid(System.Web.UI.WebControls.TextBox box, string error)
        {
            if (error.Length > 0)
                box.Attributes["aria-invalid"] = "true";
            else
                box.Attributes.Remove("aria-invalid");
        }

        private void ShowMessage(string text)
        {
            lblMessage.Text = HttpUtility.HtmlEncode(text);
            lblMessage.CssClass = "contact-alert contact-alert-error";
            lblMessage.Visible = true;
        }
    }
}
