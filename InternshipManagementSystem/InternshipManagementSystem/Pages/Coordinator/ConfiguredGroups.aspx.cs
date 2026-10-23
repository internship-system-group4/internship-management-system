using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class ConfiguredGroups : CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
            if (BindGroups() && Request.QueryString["saved"] == "1")
                ShowMessage("Group and assignments saved.", true);
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindGroups();
        }

        protected void btnClearSearch_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindGroups();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            LinkButton button = sender as LinkButton;
            if (button == null || !Regex.IsMatch(button.CommandArgument ?? "", @"^[A-Za-z0-9_-]+$"))
            {
                ShowMessage("Invalid group link.", false);
                return;
            }
            Response.Redirect(ResolveUrl("~/Pages/Coordinator/Groups.aspx?edit=" + Server.UrlEncode(button.CommandArgument)), false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private bool BindGroups()
        {
            try
            {
                List<StudentGroup> groups = new GroupRepository().GetAll();
                string search = (txtSearch.Text ?? "").Trim();
                if (search.Length > 0)
                    groups = groups.Where(group => Contains(group.Name, search)
                        || Contains(group.AcademicYear, search)
                        || Contains(group.Semester, search)
                        || Contains(group.AcademicSupervisorName, search)).ToList();
                groups.Sort((a, b) => string.Compare(a.Name, b.Name, StringComparison.OrdinalIgnoreCase));
                rptGroups.DataSource = groups;
                rptGroups.DataBind();
                lblNoGroups.Text = search.Length > 0 ? "No groups match your search." : "No groups have been created yet.";
                lblNoGroups.Visible = groups.Count == 0;
                return true;
            }
            catch (FirebaseException)
            {
                ShowMessage("Could not load configured groups. Please try again.", false);
                return false;
            }
        }

        private static bool Contains(string value, string search)
        {
            return value != null && value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        private void ShowMessage(string message, bool success)
        {
            lblMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblMessage.Visible = true;
        }
    }
}
