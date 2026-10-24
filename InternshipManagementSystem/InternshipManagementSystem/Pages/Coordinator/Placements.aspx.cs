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
                List<PlacementRow> rows = new PlacementRepository().GetAll()
                    .Where(p => p != null && p.Status != PlacementStatus.Cancelled &&
                                !string.IsNullOrEmpty(p.StudentId))
                    .Where(p => search.Length == 0 || Contains(p.StudentName, search) ||
                                Contains(p.CompanyName, search) || Contains(p.OpportunityTitle, search))
                    .OrderBy(p => p.StudentName).Select(p => new PlacementRow
                    {
                        Student = string.IsNullOrWhiteSpace(p.StudentName) ? L.T("Coordinator.Placements.UnnamedStudent") : p.StudentName,
                        Company = string.IsNullOrWhiteSpace(p.CompanyName) ? L.T("Coordinator.Placements.CompanyNotRecorded") : p.CompanyName,
                        Opportunity = string.IsNullOrWhiteSpace(p.OpportunityTitle) ? "Internship" : p.OpportunityTitle,
                        Status = p.Status.ToString(),
                        Hours = p.ApprovedHours + " / " + p.RequiredHours,
                        DetailsUrl = ResolveUrl("~/Pages/Coordinator/PlacementDetails.aspx?id=" +
                            Server.UrlEncode(p.StudentId))
                    }).ToList();
                rptPlacements.DataSource = rows;
                rptPlacements.DataBind();
                pnlEmpty.Visible = rows.Count == 0;
                litEmpty.Text = search.Length == 0 ? L.T("Coordinator.Placements.NoConfirmedInternshipsYet") :
                    L.T("Coordinator.Placements.NoPlacementsMatchYourSearch");
            }
            catch (FirebaseException)
            {
                pnlEmpty.Visible = true;
                litEmpty.Text = L.T("Coordinator.Placements.CouldNotLoadPlacementsPleaseTry");
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
