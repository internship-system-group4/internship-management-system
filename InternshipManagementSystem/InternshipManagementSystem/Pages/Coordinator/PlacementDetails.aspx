<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="PlacementDetails.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.PlacementDetails" Title="Placement Details" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <style>
        .placement-intro{display:flex;justify-content:space-between;align-items:start;gap:1rem;flex-wrap:wrap;margin-bottom:1.5rem}.placement-intro h2{font-size:1.45rem;margin:0 0 .35rem}.placement-muted{color:var(--muted)}
        .placement-grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:1rem}.placement-fact{border-top:1px solid var(--line);padding-top:.65rem}.placement-fact small{display:block;color:var(--muted)}.placement-fact strong{display:block;margin-top:.2rem;overflow-wrap:anywhere}
        .placement-stats{display:flex;gap:1rem;flex-wrap:wrap}.placement-stats strong{color:var(--brand-text,var(--brand-dark))}.placement-feedback{white-space:pre-wrap;overflow-wrap:anywhere}
        @media(max-width:750px){.placement-grid{grid-template-columns:repeat(2,minmax(0,1fr))}}@media(max-width:520px){.placement-grid{grid-template-columns:1fr}}
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="placement-intro"><div><h2>Placement details</h2><p class="placement-muted mb-0">Tasks, submissions, evaluations and training hours for one confirmed internship.</p></div><a class="btn btn-outline-secondary" href="<%: ResolveUrl("~/Pages/Coordinator/Placements.aspx") %>">Back to placements</a></div>
    <asp:Panel ID="pnlMissing" runat="server" Visible="false" CssClass="uims-card"><p class="placement-muted mb-0"><asp:Literal ID="litMissing" runat="server" /></p></asp:Panel>

    <asp:Panel ID="pnlDetails" runat="server" Visible="false">
        <section class="uims-card" aria-labelledby="studentHeading">
            <div class="d-flex justify-content-between align-items-start gap-3 flex-wrap"><h3 id="studentHeading"><asp:Literal ID="litStudent" runat="server" /></h3><asp:HyperLink ID="lnkFinalReview" runat="server" Text="Open final completion review" CssClass="btn btn-sm btn-outline-primary" /></div>
            <div class="placement-grid">
                <div class="placement-fact"><small>Student number</small><strong><asp:Literal ID="litStudentNumber" runat="server" /></strong></div>
                <div class="placement-fact"><small>Program</small><strong><asp:Literal ID="litProgram" runat="server" /></strong></div>
                <div class="placement-fact"><small>Status</small><strong><asp:Literal ID="litStatus" runat="server" /></strong></div>
                <div class="placement-fact"><small>Company</small><strong><asp:Literal ID="litCompany" runat="server" /></strong></div>
                <div class="placement-fact"><small>Opportunity</small><strong><asp:Literal ID="litOpportunity" runat="server" /></strong></div>
                <div class="placement-fact"><small>Company supervisor</small><strong><asp:Literal ID="litCompanySupervisor" runat="server" /></strong></div>
                <div class="placement-fact"><small>Academic supervisor</small><strong><asp:Literal ID="litAcademicSupervisor" runat="server" /></strong></div>
                <div class="placement-fact"><small>Training period</small><strong><asp:Literal ID="litPeriod" runat="server" /></strong></div>
            </div>
        </section>

        <section class="uims-card" aria-labelledby="tasksHeading">
            <h3 id="tasksHeading">Tasks and evaluations</h3>
            <p class="placement-stats"><span><strong><asp:Literal ID="litTaskCount" runat="server" /></strong> assigned tasks</span><span><strong><asp:Literal ID="litSubmissionCount" runat="server" /></strong> submissions</span><span><strong><asp:Literal ID="litGradedCount" runat="server" /></strong> graded tasks</span></p>
            <div class="table-responsive"><table class="uims-table"><thead><tr><th scope="col">Task</th><th scope="col">Deadline</th><th scope="col">Status</th><th scope="col">Attempts</th><th scope="col">Latest grade</th><th scope="col">Latest feedback</th></tr></thead>
                <tbody><asp:Repeater ID="rptTasks" runat="server"><ItemTemplate><tr><td><%#: Eval("Title") %></td><td><%#: Eval("Deadline") %></td><td><%#: Eval("Status") %></td><td><%#: Eval("Attempts") %></td><td><%#: Eval("Grade") %></td><td class="placement-feedback"><%#: Eval("Feedback") %></td></tr></ItemTemplate></asp:Repeater></tbody>
            </table></div>
            <asp:Panel ID="pnlNoTasks" runat="server" Visible="false"><p class="placement-muted mb-0">No tasks have been assigned yet.</p></asp:Panel>
        </section>

        <section class="uims-card" aria-labelledby="hoursHeading">
            <h3 id="hoursHeading">Training hours</h3>
            <p class="mb-2"><strong><asp:Literal ID="litHours" runat="server" /></strong> approved / required · <asp:Literal ID="litPendingHours" runat="server" /> reported hours awaiting review</p>
            <div id="hoursProgress" runat="server" class="progress mb-2" role="progressbar" aria-label="Approved hours progress" aria-valuemin="0" aria-valuemax="100"><div id="hoursBar" runat="server" class="progress-bar btn-brand" style="width:0%"></div></div>
            <p class="placement-muted small"><asp:Literal ID="litHoursPercent" runat="server" /> of required hours approved.</p>
            <div class="table-responsive"><table class="uims-table"><thead><tr><th scope="col">Work date</th><th scope="col">Entry</th><th scope="col">Hours</th><th scope="col">Status</th></tr></thead>
                <tbody><asp:Repeater ID="rptHours" runat="server"><ItemTemplate><tr><td><%#: Eval("Date") %></td><td><%#: Eval("Description") %></td><td><%#: Eval("Hours") %></td><td><%#: Eval("Status") %></td></tr></ItemTemplate></asp:Repeater></tbody>
            </table></div>
            <asp:Panel ID="pnlNoHours" runat="server" Visible="false"><p class="placement-muted mb-0">No hours have been reported yet.</p></asp:Panel>
        </section>

        <section class="uims-card" aria-labelledby="finalHeading"><h3 id="finalHeading">Final review status</h3>
            <div class="placement-grid"><div class="placement-fact"><small>Company final evaluation</small><strong><asp:Literal ID="litCompanyEvaluation" runat="server" /></strong></div><div class="placement-fact"><small>Academic final evaluation</small><strong><asp:Literal ID="litAcademicEvaluation" runat="server" /></strong></div><div class="placement-fact"><small>Completion</small><strong><asp:Literal ID="litCompletion" runat="server" /></strong></div></div>
        </section>
    </asp:Panel>
</asp:Content>
