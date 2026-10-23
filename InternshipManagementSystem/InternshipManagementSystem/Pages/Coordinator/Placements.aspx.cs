using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    public partial class Placements : InternshipManagementSystem.Security.CoordinatorPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack) BindPlacements();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            BindPlacements();
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            txtSearch.Text = "";
            BindPlacements();
        }

        private void BindPlacements()
        {
            string search = (txtSearch.Text ?? "").Trim();
            try
            {
                List<PlacementRow> rows = new CoordinatorMonitoringRepository().LoadPlacements()
                    .Where(r => r.Placement.Status != PlacementStatus.Cancelled)
                    .Select(r => new { Overview = r, Placement = r.Placement })
                    .Where(r => search.Length == 0 || Contains(r.Overview.StudentName, search) ||
                                Contains(r.Placement.CompanyName, search) || Contains(r.Placement.OpportunityTitle, search))
                    .OrderBy(r => r.Overview.StudentName).Select(r => new PlacementRow
                    {
                        Student = string.IsNullOrWhiteSpace(r.Overview.StudentName) ? "Unnamed student" : r.Overview.StudentName,
                        Company = string.IsNullOrWhiteSpace(r.Placement.CompanyName) ? "Company not recorded" : r.Placement.CompanyName,
                        Opportunity = string.IsNullOrWhiteSpace(r.Placement.OpportunityTitle) ? "Internship" : r.Placement.OpportunityTitle,
                        Status = r.Placement.Status.ToString(),
                        Hours = r.Overview.ApprovedHours + " / " + r.Overview.RequiredHours,
                        DetailsUrl = ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" +
                            Server.UrlEncode(r.Placement.StudentId))
                    }).ToList();
                rptPlacements.DataSource = rows;
                rptPlacements.DataBind();
                pnlEmpty.Visible = rows.Count == 0;
                litEmpty.Text = search.Length == 0 ? "No confirmed internships yet." :
                    "No placements match your search.";
            }
            catch (FirebaseException)
            {
                pnlEmpty.Visible = true;
                litEmpty.Text = "Could not load placements. Please try again.";
            }
        }

        private static bool Contains(string value, string search)
        {
            return !string.IsNullOrEmpty(value) &&
                   value.IndexOf(search, StringComparison.OrdinalIgnoreCase) >= 0;
        }

        public sealed class PlacementRow
        {
            public string Student { get; set; }
            public string Company { get; set; }
            public string Opportunity { get; set; }
            public string Status { get; set; }
            public string Hours { get; set; }
            public string DetailsUrl { get; set; }
        }
    }
}
