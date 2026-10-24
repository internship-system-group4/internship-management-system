// =============================================================================
//  Demo student (development tool)
//  Owner : Ahmad
//
//  Creates a fictional student whose internship is ready for the final
//  completion review, so the approval, the stamp, the report and the
//  certificate can be shown in one go. Coordinator only, and only when the
//  application runs on this machine (Request.IsLocal); anywhere else the page
//  answers 404. See Services/DemoStudentService.cs for what it writes.
// =============================================================================
using System;
using System.Collections.Generic;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class DemoStudent : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected List<DemoStudentInfo> Demos = new List<DemoStudentInfo>();
        protected string Message;
        protected bool MessageIsError;
        protected string CreatedId;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Request.IsLocal)
            {
                Response.StatusCode = 404;
                Response.TrySkipIisCustomErrors = true;
                Response.End();
                return;
            }
            if (!IsPostBack)
            {
                txtName.Text = "Lina Khaled";
                txtEmail.Text = "demo.student@example.com";
                string done = Request.QueryString["done"];
                string id = Request.QueryString["id"];
                if (done == "created" && ApplicationRepository.IsValidKey(id)) { Message = L.T("Coordinator.Demo.Created"); CreatedId = id; }
                if (done == "reset") Message = L.T("Coordinator.Demo.WasReset");
            }
            LoadDemos();
            btnCreate.OnClientClick = "return confirm('" + System.Web.HttpUtility.JavaScriptStringEncode(L.T("Coordinator.Demo.ConfirmCreate")) + "');";
        }

        private void LoadDemos()
        {
            try
            {
                Demos = DemoStudentService.List();
                // Bind once; on a postback the rows come back from view state so
                // the Reset button's event is validated against the same rows.
                if (!IsPostBack)
                {
                    rptDemos.DataSource = Demos;
                    rptDemos.DataBind();
                }
            }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Demo student list failed: " + ex.Message);
                ShowError(L.T("Coordinator.Demo.ErrorLoad"));
            }
        }

        protected void Create_Click(object sender, EventArgs e)
        {
            if (txtPassword.Text != txtConfirm.Text) { ShowError(L.T("Coordinator.Demo.ErrorMatch")); return; }
            string id;
            try
            {
                id = DemoStudentService.Create(txtName.Text, txtEmail.Text, txtPassword.Text, CurrentCoordinator);
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); return; }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Demo student creation failed: " + ex.Message);
                ShowError(L.T("Coordinator.Demo.ErrorAccount"));
                return;
            }
            Response.Redirect("DemoStudent.aspx?done=created&id=" + Server.UrlEncode(id), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void Demos_Command(object sender, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "reset") return;
            try
            {
                DemoStudentService.Reset(Convert.ToString(e.CommandArgument), CurrentCoordinator);
            }
            catch (InvalidOperationException ex) { ShowError(ex.Message); return; }
            catch (FirebaseException ex)
            {
                System.Diagnostics.Trace.TraceError("Demo reset failed: " + ex.Message);
                ShowError(L.T("Coordinator.Demo.ErrorLoad"));
                return;
            }
            Response.Redirect("DemoStudent.aspx?done=reset", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        protected void Demos_ItemDataBound(object sender, RepeaterItemEventArgs e)
        {
            Button reset = e.Item.FindControl("btnReset") as Button;
            if (reset != null)
                reset.OnClientClick = "return confirm('" + System.Web.HttpUtility.JavaScriptStringEncode(L.T("Coordinator.Demo.ConfirmReset")) + "');";
        }

        private void ShowError(string message)
        {
            Message = message;
            MessageIsError = true;
        }

        protected static string StatusLabel(CompletionStatus status)
        {
            switch (status)
            {
                case CompletionStatus.Approved: return L.T("Coordinator.Review.StatusApproved");
                case CompletionStatus.Rejected: return L.T("Coordinator.Demo.StatusDecided");
                default: return L.T("Coordinator.Review.StatusReady");
            }
        }

        protected static string StatusCss(CompletionStatus status)
        {
            switch (status)
            {
                case CompletionStatus.Approved: return "rv-badge is-done";
                case CompletionStatus.Rejected: return "rv-badge is-attention";
                default: return "rv-badge is-active";
            }
        }
    }
}
