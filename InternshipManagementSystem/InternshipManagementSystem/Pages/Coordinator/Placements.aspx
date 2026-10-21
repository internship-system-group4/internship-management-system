<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Placements.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Placements" Title="Placements & Progress" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/coordinator-monitoring.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="monitor-page">
    <div class="monitor-heading"><div><h2>Placements &amp; progress</h2><p>Find a student's confirmed internship and review their progress.</p></div><a href="Dashboard.aspx">Back to dashboard</a></div>
    <div class="monitor-filters">
        <div><asp:Label runat="server" AssociatedControlID="SearchText" Text="Search placements" /><asp:TextBox ID="SearchText" runat="server" MaxLength="120" CssClass="form-control" placeholder="Student name, number, UID or company" /></div>
        <div><asp:Label runat="server" AssociatedControlID="StatusList" Text="Placement status" /><asp:DropDownList ID="StatusList" runat="server" CssClass="form-select"><asp:ListItem Value="">All statuses</asp:ListItem><asp:ListItem Value="1">Confirmed</asp:ListItem><asp:ListItem Value="2">Active</asp:ListItem><asp:ListItem Value="3">Awaiting completion</asp:ListItem><asp:ListItem Value="4">Completed</asp:ListItem><asp:ListItem Value="5">Cancelled</asp:ListItem></asp:DropDownList></div>
        <asp:Button ID="SearchButton" runat="server" Text="Search" OnClick="Search_Click" CssClass="btn btn-brand" /><a href="Placements.aspx">Clear filters</a>
    </div>
    <% if (LoadError != null) { %><div class="monitor-error" role="alert"><%: LoadError %> <a href="Placements.aspx">Retry</a></div><% } else { %>
    <section class="monitor-panel"><div class="monitor-panel-heading"><h3>Student placements</h3><span><%: Matched %> matching &middot; <%: Total %> total</span></div>
    <% if (Rows.Count == 0) { %><div class="monitor-empty"><%: Total == 0 ? "No confirmed placements yet. A student's first offer confirmation creates their placement." : "No placements match these filters. Try another name, number or status." %></div><% } else { %>
    <div class="monitor-table-scroll"><table class="monitor-table"><caption class="visually-hidden">Confirmed student placements and approved-hour progress</caption><thead><tr><th scope="col">Student</th><th scope="col">Major</th><th scope="col">Company / opportunity</th><th scope="col">Status</th><th scope="col">Approved hours</th><th scope="col">Action</th></tr></thead><tbody>
    <% foreach (var row in Rows) { %><tr data-student-id="<%: row.Placement.StudentId %>"><td><strong><%: row.StudentName %></strong><small><%: row.StudentNumber %></small></td><td><%: row.Major %></td><td><strong><%: row.Placement.CompanyName %></strong><small><%: row.Placement.OpportunityTitle %></small></td><td><span class="monitor-status"><%: row.StatusText %></span></td><td><span><%: row.HoursText %></span><progress value="<%: row.HoursPercent %>" max="100" aria-label="Approved hours for <%: row.StudentName %>"><%: row.HoursPercent %>%</progress></td><td><a href="PlacementDetails.aspx?id=<%: Server.UrlEncode(row.Placement.Id) %>" aria-label="View internship for <%: row.StudentName %>">View details</a></td></tr><% } %>
    </tbody></table></div>
    <div class="monitor-pagination"><span>Page <%: CurrentPage %> of <%: PageCount %> &middot; Showing <%: Math.Min(Matched, (CurrentPage - 1) * 10 + 1) %>&ndash;<%: Math.Min(Matched, CurrentPage * 10) %> of <%: Matched %></span><nav aria-label="Placements pagination"><% if (CurrentPage > 1) { %><a href="<%: PageUrl(CurrentPage - 1) %>">Previous</a><% } %><% if (CurrentPage < PageCount) { %><a href="<%: PageUrl(CurrentPage + 1) %>">Next</a><% } %></nav></div>
    <% } %></section>
    <p class="monitor-note">Hours are calculated from approved training-hour entries. Completing a task does not approve hours or complete an internship.</p>
    <% } %>
</div>
</asp:Content>
