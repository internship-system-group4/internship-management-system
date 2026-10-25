<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Placements.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Placements" Title="Placements & Progress" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="students-page dir-page">
    <header class="dir-head">
        <div>
            <div class="dir-crumb"><%: L.T("Coordinator.Placements.Crumb") %></div>
            <h2><%: L.T("Coordinator.Placements.PlacementsProgress") %></h2>
            <p><%: L.T("Coordinator.Placements.FindAStudentSConfirmedInternship") %></p>
        </div>
    </header>

    <% if (LoadError != null) { %>
    <div class="alert alert-danger d-flex flex-wrap align-items-center gap-2" role="alert"><%: LoadError %> <a class="dir-btn" href="Placements.aspx"><%: L.T("Coordinator.Placements.Retry") %></a></div>
    <% } else { %>
    <section class="dir-card" aria-labelledby="placementsHeading">
        <div class="dir-toolbar">
            <div class="dir-title"><h3 id="placementsHeading"><%: L.T("Coordinator.Placements.StudentPlacements") %> <span class="dir-count"><%: Matched == Total ? Total.ToString() : Matched + " / " + Total %></span></h3><p><%: L.T("Coordinator.Placements.HoursAreCalculatedFromApprovedTraining") %></p></div>
            <asp:Panel ID="pnlSearch" runat="server" CssClass="dir-filters" DefaultButton="SearchButton">
                <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.Placements.SearchPlacements") %></span><span data-ui-icon="search" aria-hidden="true"></span><asp:TextBox ID="SearchText" runat="server" MaxLength="120" CssClass="form-control" TextMode="Search" placeholder="<%$ Resources:Coordinator, Placements.StudentNameNumberUIDOrCompany %>" /></label>
                <label><span class="visually-hidden"><%: L.T("Coordinator.Placements.PlacementStatus") %></span><asp:DropDownList ID="StatusList" runat="server" CssClass="form-select"><asp:ListItem Value="" Text="<%$ Resources:Coordinator, Placements.AllStatuses %>" /><asp:ListItem Value="1" Text="<%$ Resources:Shared, Value.PlacementStatus.Confirmed %>" /><asp:ListItem Value="2" Text="<%$ Resources:Shared, Value.PlacementStatus.Active %>" /><asp:ListItem Value="3" Text="<%$ Resources:Shared, Value.PlacementStatus.AwaitingCompletion %>" /><asp:ListItem Value="4" Text="<%$ Resources:Shared, Value.PlacementStatus.Completed %>" /><asp:ListItem Value="5" Text="<%$ Resources:Shared, Value.PlacementStatus.Cancelled %>" /></asp:DropDownList></label>
                <asp:LinkButton ID="SearchButton" runat="server" OnClick="Search_Click" CssClass="btn btn-brand"><span data-ui-icon="search" aria-hidden="true"></span> <%: L.T("Coordinator.Placements.Search") %></asp:LinkButton>
                <% if (Query.Length > 0 || StatusFilter.Length > 0) { %><a class="dir-btn" href="Placements.aspx"><span data-ui-icon="close" aria-hidden="true"></span> <%: L.T("Coordinator.Placements.ClearFilters") %></a><% } %>
            </asp:Panel>
        </div>

        <% if (Rows.Count == 0) { %>
        <p class="dir-empty"><span data-ui-icon="briefcase" aria-hidden="true"></span><%: Total == 0 ? L.T("Coordinator.Placements.NoPlacementsYet") : L.T("Coordinator.Placements.NoPlacementsMatch") %></p>
        <% } else { %>
        <div class="table-responsive">
            <table class="dir-table">
                <caption class="visually-hidden"><%: L.T("Coordinator.Placements.ConfirmedStudentPlacementsAndApprovedHour") %></caption>
                <thead><tr><th scope="col"><%: L.T("Coordinator.Placements.Student") %></th><th scope="col"><%: L.T("Coordinator.Placements.Major") %></th><th scope="col"><%: L.T("Coordinator.Placements.CompanyOpportunity") %></th><th scope="col"><%: L.T("Coordinator.Placements.Status") %></th><th scope="col"><%: L.T("Coordinator.Placements.ApprovedHours") %></th><th scope="col" class="dir-actions-col"><%: L.T("Coordinator.Placements.Action") %></th></tr></thead>
                <tbody>
                <% for (int i = 0; i < Rows.Count; i++) { var row = Rows[i]; %>
                    <tr data-student-id="<%: row.Placement.StudentId %>" style="--dir-i:<%: i %>">
                        <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%: StudentDirectoryRow.MakeInitials(row.StudentName) %></span><div><strong><%: row.StudentName %></strong></div></div></td>
                        <td><%: row.Major %></td>
                        <td><strong><%: Show(row.Placement.CompanyName) %></strong><small><%: Show(row.Placement.OpportunityTitle) %></small></td>
                        <td><span class="<%: PlacementStatusStyle.Css(row.Placement.Status) %>"><%: row.StatusText %></span></td>
                        <td><div class="dir-hours"><div class="dir-progress" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="<%: row.HoursPercent %>" aria-label="<%: L.F("Coordinator.Placements.ApprovedHoursFor", row.StudentName) %>"><span style="--dir-p:<%: row.HoursPercent %>%"></span></div><small class="dir-num"><%: row.HoursText %></small></div></td>
                        <td><div class="dir-actions">
                            <a class="dir-btn dir-btn-primary" href="PlacementDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>"><span data-ui-icon="chart" aria-hidden="true"></span> <%: L.T("Coordinator.Placements.ViewProgress") %><span class="visually-hidden">: <%: row.StudentName %></span></a>
                            <% if (!string.IsNullOrEmpty(row.Placement.StudentId)) { %><a class="dir-btn" href="Students.aspx?id=<%: Server.UrlEncode(row.Placement.StudentId) %>"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %><span class="visually-hidden">: <%: row.StudentName %></span></a><% } %>
                        </div></td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <div class="dir-foot">
            <span><%: L.T("Coordinator.Placements.Page") %> <%: CurrentPage %> <%: L.T("Coordinator.Placements.Of") %> <%: PageCount %> <%: L.T("Coordinator.Placements.Showing") %> <span class="dir-num"><%: Math.Min(Matched, (CurrentPage - 1) * 10 + 1) %>&ndash;<%: Math.Min(Matched, CurrentPage * 10) %></span> <%: L.T("Coordinator.Placements.Of") %> <%: Matched %></span>
            <% if (PageCount > 1) { %>
            <nav aria-label="<%: L.T("Coordinator.Placements.PlacementsPagination") %>">
                <% if (CurrentPage > 1) { %><a class="dir-btn" href="<%: PageUrl(CurrentPage - 1) %>"><span data-ui-icon="back" aria-hidden="true"></span> <%: L.T("Coordinator.Placements.Previous") %></a><% } %>
                <span class="dir-page-no" aria-current="page"><%: CurrentPage %></span>
                <% if (CurrentPage < PageCount) { %><a class="dir-btn" href="<%: PageUrl(CurrentPage + 1) %>"><%: L.T("Coordinator.Placements.Next") %> <span data-ui-icon="next" aria-hidden="true"></span></a><% } %>
            </nav>
            <% } %>
        </div>
        <% } %>
    </section>
    <% } %>
</div>
</asp:Content>
