using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.Reports
{
    public partial class Grades : InternshipManagementSystem.Security.SecurePage
    {
        protected override UserRole[] AllowedRoles
        { get { return new[] { UserRole.CompanySupervisor, UserRole.AcademicSupervisor, UserRole.Coordinator }; } }
        protected bool ShowAcademic { get { return CurrentUser.Role != UserRole.CompanySupervisor; } }
        private bool downloading;

        protected override void OnPreInit(EventArgs e)
        {
            base.OnPreInit(e);
            MasterPageFile = CurrentUser.Role == UserRole.CompanySupervisor ? "~/Layout/Company.master" :
                CurrentUser.Role == UserRole.AcademicSupervisor ? "~/Layout/Academic.master" : "~/Layout/Coordinator.master";
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            litScope.Text = CurrentUser.Role == UserRole.Coordinator ? "All confirmed internships" : "Your assigned internships";
            if (!IsPostBack) BindResults();
        }

        protected void btnApply_Click(object sender, EventArgs e) { BindResults(); }
        protected void btnReset_Click(object sender, EventArgs e)
        { txtSearch.Text = ""; ddlResult.SelectedIndex = 0; BindResults(); }

        private List<GradeResultRow> ReadSelection()
        {
            string search = (txtSearch.Text ?? "").Trim();
            return GradeResultsService.Load(CurrentUser).Where(row =>
                (string.IsNullOrEmpty(ddlResult.SelectedValue) || row.Result == ddlResult.SelectedValue) &&
                (search.Length == 0 || Contains(row.StudentName, search) || Contains(row.StudentNumber, search) ||
                 Contains(row.CompanyName, search))).ToList();
        }

        private void BindResults()
        {
            try
            {
                List<GradeResultRow> rows = ReadSelection();
                rptGrades.DataSource = rows;
                rptGrades.DataBind();
                pnlTable.Visible = rows.Count > 0;
                pnlEmpty.Visible = rows.Count == 0;
                btnExport.Enabled = rows.Count > 0;
                litCount.Text = rows.Count.ToString(CultureInfo.InvariantCulture) + (rows.Count == 1 ? " student" : " students");
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { ShowLoadError(); }
        }

        protected void btnExport_Click(object sender, EventArgs e)
        {
            try
            {
                // Re-read access and records for every download; never trust a cached preview.
                List<GradeResultRow> rows = ReadSelection();
                if (rows.Count == 0) { BindResults(); return; }
                DateTime now = DateTime.UtcNow;
                byte[] bytes = GradesExcelExportService.CreateGradesWorkbook(CurrentUser, rows, now);
                Response.Clear();
                Response.ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
                Response.AddHeader("Content-Disposition", "attachment; filename=internship-grades-" +
                    CurrentUser.Role.ToString().ToLowerInvariant() + "-" + now.ToString("yyyyMMdd-HHmmss", CultureInfo.InvariantCulture) + ".xlsx");
                Response.AddHeader("Content-Length", bytes.Length.ToString(CultureInfo.InvariantCulture));
                Response.AddHeader("X-Content-Type-Options", "nosniff");
                Response.Cache.SetCacheability(HttpCacheability.NoCache);
                Response.Cache.SetNoStore();
                Response.BinaryWrite(bytes);
                downloading = true;
                Context.ApplicationInstance.CompleteRequest();
            }
            catch (FirebaseAuthExpiredException) { throw; }
            catch (FirebaseException) { ShowLoadError(); }
        }

        protected override void Render(System.Web.UI.HtmlTextWriter writer)
        {
            // CompleteRequest does not stop Web Forms from appending page HTML to a workbook.
            if (!downloading) base.Render(writer);
        }

        private void ShowLoadError()
        {
            lblMessage.Text = "Grades could not be loaded. Please try again shortly.";
            lblMessage.CssClass = "alert alert-danger d-block";
            lblMessage.Visible = true;
            btnExport.Enabled = false;
            pnlTable.Visible = false;
            pnlEmpty.Visible = false;
            litCount.Text = "Unavailable";
        }
        private static bool Contains(string value, string search)
        { return (value ?? "").IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0; }
    }
}
