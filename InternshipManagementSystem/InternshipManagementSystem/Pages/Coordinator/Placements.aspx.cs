using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    /// <summary>The status pill colour for a placement on coordinator pages.</summary>
    public static class PlacementStatusStyle
    {
        public static string Css(PlacementStatus status)
        {
            switch (status)
            {
                case PlacementStatus.Active:
                case PlacementStatus.Completed: return "dir-status is-active";
                case PlacementStatus.AwaitingCompletion: return "dir-status is-warning";
                case PlacementStatus.Cancelled: return "dir-status is-inactive";
                case PlacementStatus.Confirmed: return "dir-status is-info";
                default: return "dir-status is-neutral";
            }
        }
    }

    public partial class Placements : Security.CoordinatorPage
    {
        protected List<PlacementOverview> Rows = new List<PlacementOverview>();
        protected string LoadError;
        protected int Total, Matched, CurrentPage, PageCount;
        protected string Query { get { return SearchQuery(Request.QueryString["q"]); } }
        private static string SearchQuery(string value) { value = (value ?? "").Trim(); return value.Substring(0, Math.Min(120, value.Length)); }
        protected string StatusFilter { get { return Request.QueryString["status"] ?? ""; } }
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                SearchText.Text = Query;
                if (StatusList.Items.FindByValue(StatusFilter) != null) StatusList.SelectedValue = StatusFilter;
            }
            try
            {
                var all = new CoordinatorMonitoringRepository().LoadPlacements(); Total = all.Count;
                var filtered = all.Where(r => Contains(r.StudentName, Query) || Contains(r.StudentNumber, Query)
                    || Contains(r.Placement.StudentId, Query) || Contains(r.Placement.CompanyName, Query));
                int status;
                if (int.TryParse(StatusFilter, out status) && Enum.IsDefined(typeof(PlacementStatus), status) && status != 0)
                    filtered = filtered.Where(r => (int)r.Placement.Status == status);
                var matches = filtered.ToList(); Matched = matches.Count;
                PageCount = Math.Max(1, (Matched + 9) / 10);
                int requested; if (!int.TryParse(Request.QueryString["page"], out requested)) requested = 1;
                CurrentPage = Math.Max(1, Math.Min(requested, PageCount));
                Rows = matches.Skip((CurrentPage - 1) * 10).Take(10).ToList();
            }
            catch (FirebaseException) { LoadError = L.T("Coordinator.Placements.WeCouldNotLoadPlacementsRefresh"); }
            catch (InvalidOperationException) { LoadError = L.T("Coordinator.Placements.FirebaseIsNotConfiguredContactThe"); }
        }
        /// <summary>A company or opportunity name, or "Not recorded" when it is blank.</summary>
        protected static string Show(string value) { return string.IsNullOrWhiteSpace(value) ? L.T("Coordinator.Placements.NoName") : value; }
        private static bool Contains(string value, string query) { return (value ?? "").IndexOf(query, StringComparison.OrdinalIgnoreCase) >= 0; }
        protected void Search_Click(object sender, EventArgs e)
        {
            Response.Redirect("Placements.aspx?q=" + Server.UrlEncode(SearchQuery(SearchText.Text)) + "&status=" + Server.UrlEncode(StatusList.SelectedValue));
        }
        protected string PageUrl(int number) { return "Placements.aspx?q=" + Server.UrlEncode(Query) + "&status=" + Server.UrlEncode(StatusFilter) + "&page=" + number; }
    }
}
