using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class Contact : System.Web.UI.Page
    {
        protected override void OnInit(EventArgs e)
        {
            ViewStateUserKey = Session.SessionID;
            base.OnInit(e);
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ViewState["SubmissionId"] = Guid.NewGuid().ToString("N");
                if (Session["PublicContactSent"] is bool && (bool)Session["PublicContactSent"])
                {
                    Session.Remove("PublicContactSent");
                    ShowNotice("Your message has been sent to the coordination team. Thank you for getting in touch.", true);
                }
            }
        }
        protected void btnSend_Click(object sender, EventArgs e)
        {
            if (!string.IsNullOrWhiteSpace(Website.Text)) return;
            string name = txtName.Text.Trim(), email = txtEmail.Text.Trim(),
                subject = txtSubject.Text.Trim(), message = txtMessage.Text.Trim();
            if (name.Length < 2 || name.Length > 100 || email.Length > 254 || !Common.Validators.IsEmail(email)
                || subject.Length < 5 || subject.Length > 150 || message.Length < 20 || message.Length > 4000)
            {
                ShowNotice("Check your details: name 2–100 characters, a valid email, subject 5–150 characters and message 20–4,000 characters.", false);
                return;
            }
            Guid id;
            if (!Guid.TryParse(Convert.ToString(ViewState["SubmissionId"]), out id))
            { ShowNotice("Your form session could not be verified. Refresh this page and try again.", false); return; }
            try
            {
                // A stable, server-owned key makes repeated posts of the same form idempotent.
                // Preserve main's coordinator inbox contract and the stable server-owned key.
                FirebaseContext.PutIfEmpty("ContactMessages/" + id.ToString("N"), new
                {
                    Name = name, Email = email, Subject = subject, Message = message,
                    Status = "New", SubmittedAt = Time.NowMs()
                });
                Session["PublicContactSent"] = true;
                Response.Redirect("Contact.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (FirebaseException)
            { ShowNotice("We could not confirm your message was saved. Your details are still here; please try again.", false); }
            catch (InvalidOperationException)
            { ShowNotice("The contact service is not configured yet. Please contact your university coordinator through your usual university channel.", false); }
        }
        private void ShowNotice(string message, bool success)
        {
            lblMessage.Text = Server.HtmlEncode(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
