<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Placements.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Placements" Title="Placements & Progress" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>.placements-intro{margin-bottom:1.5rem}.placements-intro h2{font-size:1.45rem;margin:0 0 .35rem}.placements-search{display:flex;gap:.5rem;flex-wrap:wrap;margin-bottom:1rem}.placements-search .form-control{max-width:360px}.placements-muted{color:var(--muted)}</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="placements-intro"><h2>Placements &amp; Progress</h2><p class="placements-muted mb-0">Monitor each confirmed internship and open its task, evaluation and hours details.</p></div>
    <section class="uims-card" aria-labelledby="placementsHeading">
        <h3 id="placementsHeading">Confirmed internships</h3>
        <div class="placements-search">
            <label class="visually-hidden" for="<%= txtSearch.ClientID %>">Search placements</label>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search student, company or opportunity" />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-brand" OnClick="btnSearch_Click" CausesValidation="false" />
            <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClear_Click" CausesValidation="false" />
        </div>
        <div class="table-responsive"><table class="uims-table">
            <thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Opportunity</th><th scope="col">Approved hours</th><th scope="col">Status</th><th scope="col">Details</th></tr></thead>
            <tbody><asp:Repeater ID="rptPlacements" runat="server"><ItemTemplate>
                <tr><td><%#: Eval("Student") %></td><td><%#: Eval("Company") %></td><td><%#: Eval("Opportunity") %></td><td><%#: Eval("Hours") %></td><td><%#: Eval("Status") %></td>
                <td><asp:HyperLink runat="server" NavigateUrl='<%# Eval("DetailsUrl") %>' Text="View details" CssClass="btn btn-sm btn-outline-primary" /></td></tr>
            </ItemTemplate></asp:Repeater></tbody>
        </table></div>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false"><p class="placements-muted mt-2 mb-0"><asp:Literal ID="litEmpty" runat="server" /></p></asp:Panel>
    </section>
</asp:Content>
