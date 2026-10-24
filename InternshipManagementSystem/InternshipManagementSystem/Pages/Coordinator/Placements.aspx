<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Placements.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Placements" Title="Placements & Progress" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>.placements-intro{margin-bottom:1.5rem}.placements-intro h2{font-size:1.45rem;margin:0 0 .35rem}.placements-search{display:flex;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem}.placements-search .form-control{max-width:360px}.placements-muted{color:var(--muted)}</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="placements-intro"><h2><%: L.T("Coordinator.Placements.PlacementsProgress2") %></h2><p class="placements-muted mb-0"><%: L.T("Coordinator.Placements.MonitorEachConfirmedInternshipAndOpen") %></p></div>
    <section class="uims-card" aria-labelledby="placementsHeading">
        <h3 id="placementsHeading"><%: L.T("Coordinator.Placements.ConfirmedInternships") %></h3>
        <div class="placements-search">
            <label class="visually-hidden" for="<%= txtSearch.ClientID %>"><%: L.T("Coordinator.Placements.SearchPlacements") %></label>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Coordinator, Placements.SearchStudentCompanyOrOpportunity %>" />
            <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Coordinator, Placements.Search2 %>" CssClass="btn btn-brand" OnClick="btnSearch_Click" CausesValidation="false" />
            <asp:Button ID="btnClear" runat="server" Text="<%$ Resources:Coordinator, Placements.Clear %>" CssClass="btn btn-outline-secondary" OnClick="btnClear_Click" CausesValidation="false" />
        </div>
        <div class="table-responsive"><table class="uims-table">
            <thead><tr><th scope="col"><%: L.T("Coordinator.Placements.Student2") %></th><th scope="col"><%: L.T("Coordinator.Placements.Company") %></th><th scope="col"><%: L.T("Coordinator.Placements.Opportunity") %></th><th scope="col"><%: L.T("Coordinator.Placements.ApprovedHours2") %></th><th scope="col"><%: L.T("Coordinator.Placements.Status2") %></th><th scope="col"><%: L.T("Coordinator.Placements.Details") %></th></tr></thead>
            <tbody><asp:Repeater ID="rptPlacements" runat="server"><ItemTemplate>
                <tr><td><%#: Eval("Student") %></td><td><%#: Eval("Company") %></td><td><%#: Eval("Opportunity") %></td><td><%#: Eval("Hours") %></td><td><%#: L.Value("Ui", Eval("Status")) %></td>
                <td><asp:HyperLink runat="server" NavigateUrl='<%# Eval("DetailsUrl") %>' Text="<%$ Resources:Coordinator, Placements.ViewDetails2 %>" CssClass="btn btn-sm btn-outline-primary" /></td></tr>
            </ItemTemplate></asp:Repeater></tbody>
        </table></div>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false"><p class="placements-muted mt-2 mb-0"><asp:Literal ID="litEmpty" runat="server" /></p></asp:Panel>
    </section>
</asp:Content>
