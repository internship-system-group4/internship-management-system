<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Grades.aspx.cs" Inherits="InternshipManagementSystem.Pages.Reports.Grades" Title="Grades &amp; Results" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .grades-heading { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; margin-bottom: 1.5rem; }
        .grades-heading h2 { font-size: 1.5rem; margin: 0 0 .4rem; }
        .grades-muted { color: var(--muted); }
        .grades-summary { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: .75rem; margin-bottom: 1rem; }
        .grades-scope { display: inline-block; padding: .35rem .7rem; border-radius: 100px; background: var(--brand-light); color: var(--brand-text,var(--brand-dark)); font-size: .85rem; }
        .grades-filters { display: flex; align-items: end; gap: .75rem; flex-wrap: wrap; }
        .grades-search { flex: 1 1 260px; }
        .grades-status { flex: 0 1 180px; }
        .grades-table { min-width: 1100px; }
        .grades-table th { white-space: nowrap; }
        .grades-student { display: block; font-weight: 600; }
        .grades-result { display: inline-block; border-radius: 100px; padding: .25rem .65rem; font-size: .8rem; font-weight: 600; background: var(--th-bg-f0f2f5,#f0f2f5); color: var(--th-fg-4b5563,#4b5563); }
        .grades-result[data-result="Pass"] { background: var(--th-bg-e5f5ec,#e5f5ec); color: var(--th-fg-17603a,#17603a); }
        .grades-result[data-result="Fail"] { background: var(--th-bg-fdebed,#fdebed); color: var(--th-fg-9d2334,#9d2334); }
        .grades-empty { padding: 2.5rem 1rem; text-align: center; }
        .grades-empty h3 { font-size: 1.1rem; }
        .grades-note { font-size: .85rem; margin-top: 1rem; }
        @media (max-width: 600px) { .grades-heading .btn, .grades-filters .btn { width: 100%; } .grades-status { flex: 1 1 180px; } }
    </style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="grades-heading">
        <div><h2><%: L.T("Shared.Grades.GradesResults") %></h2><p class="grades-muted mb-0"><%: L.T("Shared.Grades.ReviewInternshipGradesAndDownloadThe") %></p></div>
        <asp:Button ID="btnExport" runat="server" Text="<%$ Resources:Shared, Grades.ExportToExcelXlsx %>" CssClass="btn btn-brand" OnClick="btnExport_Click" CausesValidation="false" />
    </div>
    <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
    <section class="uims-card" aria-label="<%: L.T("Shared.Grades.FilterGradesAndResults") %>">
        <div class="grades-summary"><span class="grades-scope"><asp:Literal ID="litScope" runat="server" Mode="Encode" /></span><span class="grades-muted"><%: L.T("Shared.Grades.ConfidentialSupervisorAndCoordinatorAccess") %></span></div>
        <div class="grades-filters">
            <div class="grades-search"><asp:Label runat="server" AssociatedControlID="txtSearch" Text="<%$ Resources:Shared, Grades.SearchStudentsOrCompanies %>" CssClass="form-label" /><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="<%$ Resources:Shared, Grades.NameStudentNumberOrCompany %>" /></div>
            <div class="grades-status"><asp:Label runat="server" AssociatedControlID="ddlResult" Text="<%$ Resources:Shared, Grades.Result %>" CssClass="form-label" /><asp:DropDownList ID="ddlResult" runat="server" CssClass="form-select"><asp:ListItem Value="" Text="<%$ Resources:Shared, Grades.AllResults %>" /><asp:ListItem Value="Pending" Text="<%$ Resources:Shared, Grades.Pending %>" /><asp:ListItem Value="Pass" Text="<%$ Resources:Shared, Grades.Pass %>" /><asp:ListItem Value="Fail" Text="<%$ Resources:Shared, Grades.Fail %>" /></asp:DropDownList></div>
            <asp:Button ID="btnApply" runat="server" Text="<%$ Resources:Shared, Grades.ApplyFilters %>" CssClass="btn btn-outline-primary" OnClick="btnApply_Click" CausesValidation="false" />
            <asp:Button ID="btnReset" runat="server" Text="<%$ Resources:Shared, Grades.Reset %>" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" CausesValidation="false" />
        </div>
    </section>
    <section class="uims-card" aria-labelledby="gradesHeading">
        <div class="grades-summary"><h3 id="gradesHeading" class="mb-0"><%: L.T("Shared.Grades.StudentResults") %></h3><span class="grades-muted" role="status"><asp:Literal ID="litCount" runat="server" Mode="Encode" /></span></div>
        <asp:Panel ID="pnlTable" runat="server" CssClass="table-responsive" role="region" aria-label="<%$ Resources:Shared, Grades.GradesAndResultsTable %>" tabindex="0">
            <table class="uims-table grades-table">
                <caption class="visually-hidden"><%: L.T("Shared.Grades.GradesForTheSelectedInternshipsPending") %></caption>
                <thead><tr><th scope="col"><%: L.T("Shared.Grades.Student") %></th><th scope="col"><%: L.T("Shared.Grades.Company") %></th><th scope="col"><%: L.T("Shared.Grades.TasksGraded") %></th><th scope="col"><%: L.T("Shared.Grades.ApprovedHours") %></th><th scope="col"><%: L.T("Shared.Grades.Tasks") %></th><th scope="col"><%: L.T("Shared.Grades.CompanyGrade") %></th><% if (ShowAcademic) { %><th scope="col"><%: L.T("Shared.Grades.AcademicGrade") %></th><% } %><th scope="col"><%: L.T("Shared.Grades.FinalGrade") %></th><th scope="col"><%: L.T("Shared.Grades.ReviewStatus") %></th><th scope="col"><%: L.T("Shared.Grades.Result") %></th></tr></thead>
                <tbody><asp:Repeater ID="rptGrades" runat="server"><ItemTemplate>
                    <tr><td><span class="grades-student"><%#: Eval("StudentName") %></span><span class="grades-muted"><%#: Eval("StudentNumber") %></span></td><td><%#: Eval("CompanyName") %></td><td><%#: Eval("GradedTasks") %> / <%#: Eval("AssignedTasks") %></td><td><%#: Eval("ApprovedHours") %></td><td><%#: Eval("TaskGrade") %></td><td><%#: Eval("CompanyGrade") %></td><asp:PlaceHolder runat="server" Visible='<%# ShowAcademic %>'><td><%#: Eval("AcademicGrade") %></td></asp:PlaceHolder><td><%#: Eval("FinalGrade") %></td><td><%#: Eval("ReviewStatus") %></td><td><span class="grades-result" data-result="<%#: Eval("Result") %>"><%#: Eval("Result") %></span></td></tr>
                </ItemTemplate></asp:Repeater></tbody>
            </table>
        </asp:Panel>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="grades-empty"><h3><%: L.T("Shared.Grades.NoResultsToDisplay") %></h3><p class="grades-muted mb-0"><%: L.T("Shared.Grades.ThereAreNoAssignedInternshipsMatching") %></p></asp:Panel>
        <p class="grades-muted grades-note mb-0"><%: L.T("Shared.Grades.PendingGradesAreNeverTreatedAs") %></p>
    </section>
</asp:Content>
