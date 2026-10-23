<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Grades.aspx.cs" Inherits="InternshipManagementSystem.Pages.Reports.Grades" Title="Grades &amp; Results" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .grades-heading { display: flex; align-items: center; justify-content: space-between; gap: 1rem; flex-wrap: wrap; margin-bottom: 1.5rem; }
        .grades-heading h2 { font-size: 1.5rem; margin: 0 0 .4rem; }
        .grades-muted { color: var(--muted); }
        .grades-summary { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: .75rem; margin-bottom: 1rem; }
        .grades-scope { display: inline-block; padding: .35rem .7rem; border-radius: 100px; background: var(--brand-light); color: var(--brand-dark); font-size: .85rem; }
        .grades-filters { display: flex; align-items: end; gap: .75rem; flex-wrap: wrap; }
        .grades-search { flex: 1 1 260px; }
        .grades-status { flex: 0 1 180px; }
        .grades-table { min-width: 1100px; }
        .grades-table th { white-space: nowrap; }
        .grades-student { display: block; font-weight: 600; }
        .grades-result { display: inline-block; border-radius: 100px; padding: .25rem .65rem; font-size: .8rem; font-weight: 600; background: #f0f2f5; color: #4b5563; }
        .grades-result[data-result="Pass"] { background: #e5f5ec; color: #17603a; }
        .grades-result[data-result="Fail"] { background: #fdebed; color: #9d2334; }
        .grades-empty { padding: 2.5rem 1rem; text-align: center; }
        .grades-empty h3 { font-size: 1.1rem; }
        .grades-note { font-size: .85rem; margin-top: 1rem; }
        @media (max-width: 600px) { .grades-heading .btn, .grades-filters .btn { width: 100%; } .grades-status { flex: 1 1 180px; } }
    </style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="grades-heading">
        <div><h2>Grades &amp; results</h2><p class="grades-muted mb-0">Review internship grades and download the current selection as an Excel workbook.</p></div>
        <asp:Button ID="btnExport" runat="server" Text="Export to Excel (.xlsx)" CssClass="btn btn-brand" OnClick="btnExport_Click" CausesValidation="false" />
    </div>
    <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
    <section class="uims-card" aria-label="Filter grades and results">
        <div class="grades-summary"><span class="grades-scope"><asp:Literal ID="litScope" runat="server" Mode="Encode" /></span><span class="grades-muted">Confidential &middot; Supervisor and coordinator access</span></div>
        <div class="grades-filters">
            <div class="grades-search"><asp:Label runat="server" AssociatedControlID="txtSearch" Text="Search students or companies" CssClass="form-label" /><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Name, student number or company" /></div>
            <div class="grades-status"><asp:Label runat="server" AssociatedControlID="ddlResult" Text="Result" CssClass="form-label" /><asp:DropDownList ID="ddlResult" runat="server" CssClass="form-select"><asp:ListItem Value="" Text="All results" /><asp:ListItem Value="Pending" Text="Pending" /><asp:ListItem Value="Pass" Text="Pass" /><asp:ListItem Value="Fail" Text="Fail" /></asp:DropDownList></div>
            <asp:Button ID="btnApply" runat="server" Text="Apply filters" CssClass="btn btn-outline-primary" OnClick="btnApply_Click" CausesValidation="false" />
            <asp:Button ID="btnReset" runat="server" Text="Reset" CssClass="btn btn-outline-secondary" OnClick="btnReset_Click" CausesValidation="false" />
        </div>
    </section>
    <section class="uims-card" aria-labelledby="gradesHeading">
        <div class="grades-summary"><h3 id="gradesHeading" class="mb-0">Student results</h3><span class="grades-muted" role="status"><asp:Literal ID="litCount" runat="server" Mode="Encode" /></span></div>
        <asp:Panel ID="pnlTable" runat="server" CssClass="table-responsive" role="region" aria-label="Grades and results table" tabindex="0">
            <table class="uims-table grades-table">
                <caption class="visually-hidden">Grades for the selected internships. Pending indicates a grade or released result is unavailable.</caption>
                <thead><tr><th scope="col">Student</th><th scope="col">Company</th><th scope="col">Tasks graded</th><th scope="col">Approved hours</th><th scope="col">Tasks</th><th scope="col">Company grade</th><% if (ShowAcademic) { %><th scope="col">Academic grade</th><% } %><th scope="col">Final grade</th><th scope="col">Review status</th><th scope="col">Result</th></tr></thead>
                <tbody><asp:Repeater ID="rptGrades" runat="server"><ItemTemplate>
                    <tr><td><span class="grades-student"><%#: Eval("StudentName") %></span><span class="grades-muted"><%#: Eval("StudentNumber") %></span></td><td><%#: Eval("CompanyName") %></td><td><%#: Eval("GradedTasks") %> / <%#: Eval("AssignedTasks") %></td><td><%#: Eval("ApprovedHours") %></td><td><%#: Eval("TaskGrade") %></td><td><%#: Eval("CompanyGrade") %></td><asp:PlaceHolder runat="server" Visible='<%# ShowAcademic %>'><td><%#: Eval("AcademicGrade") %></td></asp:PlaceHolder><td><%#: Eval("FinalGrade") %></td><td><%#: Eval("ReviewStatus") %></td><td><span class="grades-result" data-result="<%#: Eval("Result") %>"><%#: Eval("Result") %></span></td></tr>
                </ItemTemplate></asp:Repeater></tbody>
            </table>
        </asp:Panel>
        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="grades-empty"><h3>No results to display</h3><p class="grades-muted mb-0">There are no assigned internships matching your selection. Try resetting the filters.</p></asp:Panel>
        <p class="grades-muted grades-note mb-0">Pending grades are never treated as zero. Final grades and Pass/Fail results appear after coordinator approval and use the saved completion record. The Excel file includes the same selection, numeric grades, and export notes.</p>
    </section>
</asp:Content>
