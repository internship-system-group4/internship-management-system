
using System;
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
            if (!IsPostBack)
            {
                lblMessage.Visible = false;
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

            string name = (txtName.Text ?? "").Trim();
            string email = (txtEmail.Text ?? "").Trim();
            string subject = (txtSubject.Text ?? "").Trim();
            string message = (txtMessage.Text ?? "").Trim();

            // Validate name
            if (name.Length < 2 || name.Length > 100)
            {
                ShowMessage(
                    "Please enter a valid full name (2–100 characters).",
                    true);
                return;
            }

            // Validate email
            if (email.Length == 0 ||
                email.Length > 254 ||
                !Regex.IsMatch(
                    email,
                    @"^[^@\s]+@[^@\s]+\.[^@\s]+$"))
            {
                ShowMessage(
                    "Please enter a valid email address.",
                    true);
                return;
            }

            // Validate subject
            if (subject.Length < 3 || subject.Length > 150)
            {
                ShowMessage(
                    "Please enter a subject (3–150 characters).",
                    true);
                return;
            }

            // Validate message
            if (message.Length < 10 || message.Length > 5000)
            {
                ShowMessage(
                    "Please enter a message (10–5000 characters).",
                    true);
                return;
            }

            try
            {
                if (string.IsNullOrWhiteSpace(FirebaseUrl))
                {
                    ShowMessage(
                        "Firebase Database URL is not configured.",
                        true);
                    return;
                }

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
                using (var client = new HttpClient())
                using (var content = new StringContent(
                    json,
                    Encoding.UTF8,
                    "application/json"))
                using (var response = await client.PostAsync(
                    FirebaseUrl + "/ContactMessages.json",
                    content))
                {
                    if (!response.IsSuccessStatusCode)
                    {
                        ShowMessage(
                            "Unable to save your message to Firebase. " +
                            "Please check the database permissions.",
                            true);
                        return;
                    }
                }

                ShowMessage(
                    "Your message has been sent successfully!",
                    false);

                // Clear fields after successful submission
                txtName.Text = "";
                txtEmail.Text = "";
                txtSubject.Text = "";
                txtMessage.Text = "";
            }
            catch (Exception)
            {
                ShowMessage(
                    "Unable to send your message. Please try again.",
                    true);
            }
        }

        private void ShowMessage(string text, bool isError)
        {
            lblMessage.Text = HttpUtility.HtmlEncode(text);

            lblMessage.CssClass = isError
                ? "contact-alert contact-alert-error"
                : "contact-alert contact-alert-success";

            lblMessage.Visible = true;
        }
    }
}
