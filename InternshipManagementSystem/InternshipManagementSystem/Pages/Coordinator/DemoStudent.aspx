<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="DemoStudent.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.DemoStudent" Title="Demo student" %>
<%@ Import Namespace="InternshipManagementSystem.Services" %>
<%-- ===================================================================
     Demo student (development tool, local machine only)  -  Owner: Ahmad
     Creates one fictional student whose internship is ready for the
     final completion review. See Services/DemoStudentService.cs.
     =================================================================== --%>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <script>document.documentElement.classList.add('rv-js');setTimeout(function(){if(!window.UimsReview)document.documentElement.classList.remove('rv-js');},2500);</script>
    <link rel="stylesheet" href="<%: ResolveUrl("~/Assets/css/review-system.css?v=20261023-rv6") %>" />
    <style>
        .demo-page { width:100%; }
        .demo-grid { display:grid; grid-template-columns:minmax(0,1.1fr) minmax(0,1fr); gap:24px; align-items:start; }
        .demo-form { display:grid; grid-template-columns:repeat(2, minmax(0,1fr)); gap:20px 24px; }
        .demo-form .demo-wide { grid-column:1 / -1; }
        .demo-form label { display:block; font-weight:650; margin-bottom:8px; }
        .demo-form .form-control { min-height:52px; border-radius:12px; }
        .demo-form small { display:block; color:var(--ui-muted); margin-top:6px; }
        .demo-create { min-height:56px; padding-inline:30px; font-weight:650; border-radius:12px; }
        .demo-list { list-style:none; margin:0; padding:0; display:grid; gap:14px; }
        .demo-list li { display:flex; gap:14px; align-items:flex-start; }
        .demo-list li::before { content:""; flex:none; width:12px; height:12px; margin-top:9px; border-radius:50%; background:var(--ui-success); box-shadow:0 0 0 5px var(--ui-success-soft); }
        .demo-steps { margin:0; padding:0; list-style:none; counter-reset:step; display:grid; gap:18px; }
        .demo-steps li { counter-increment:step; display:grid; grid-template-columns:44px minmax(0,1fr); gap:16px; align-items:start; }
        .demo-steps li::before { content:counter(step); width:44px; height:44px; display:grid; place-items:center; border-radius:50%; font-weight:700; font-size:19px; color:#fff; background:var(--ui-primary); }
        .demo-steps strong { display:block; font-size:19px; margin-bottom:4px; }
        .demo-row { display:grid; grid-template-columns:minmax(0,1fr) auto; gap:20px; align-items:center; padding:22px 28px; border-bottom:1px solid var(--ui-border); }
        .demo-row:last-child { border-bottom:0; }
        .demo-row strong { display:block; font-size:20px; }
        .demo-row small { display:block; color:var(--ui-muted); margin-top:4px; }
        .demo-row .rv-badge { margin-top:10px; }
        .demo-row .rv-actions .btn { min-height:50px; padding-inline:22px; font-weight:650; border-radius:12px; }
        .demo-created { display:flex; flex-wrap:wrap; gap:14px; align-items:center; margin-top:12px; }
        .demo-created .btn { min-height:52px; padding-inline:24px; font-weight:650; border-radius:12px; }
        @media (max-width: 1100px) { .demo-grid { grid-template-columns:1fr; } }
        @media (max-width: 640px) { .demo-form { grid-template-columns:1fr; } .demo-row { grid-template-columns:1fr; padding:18px; } .demo-row .rv-actions .btn, .demo-create { width:100%; } }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="rv-scope demo-page">
    <header class="rv-heading" data-rv-reveal>
        <div>
            <span class="rv-eyebrow"><%: L.T("Coordinator.Demo.Eyebrow") %></span>
            <h2><%: L.T("Coordinator.Demo.Title") %></h2>
            <p><%: L.T("Coordinator.Demo.Intro") %></p>
        </div>
        <a class="btn btn-outline-secondary rv-btn-icon" href="CompletionReview.aspx"><%: L.T("Coordinator.Demo.OpenQueue") %></a>
    </header>

    <div class="rv-alert is-info" role="note" data-rv-reveal><div><strong><%: L.T("Coordinator.Demo.SafetyTitle") %></strong><br /><%: L.T("Coordinator.Demo.SafetyText") %></div></div>

    <% if (Message != null) { %>
    <div class="rv-alert <%: MessageIsError ? "is-error" : "is-success" %>" role="<%: MessageIsError ? "alert" : "status" %>" data-rv-reveal>
        <div><strong><%: Message %></strong>
        <% if (CreatedId != null) { %>
            <div class="demo-created">
                <a class="btn btn-brand" href="CompletionReview.aspx?id=<%: Server.UrlEncode(CreatedId) %>"><%: L.T("Coordinator.Demo.ReviewNow") %></a>
                <span><%: L.T("Coordinator.Demo.SignInHint") %></span>
            </div>
        <% } %></div>
    </div>
    <% } %>

    <div class="demo-grid">
        <section class="rv-card" aria-labelledby="demoCreateTitle" data-rv-reveal>
            <div class="rv-card-head"><div><h3 id="demoCreateTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M19 8v6M22 11h-6"/></svg></span><%: L.T("Coordinator.Demo.CreateTitle") %></h3><p><%: L.T("Coordinator.Demo.CreateNote") %></p></div></div>
            <div class="rv-card-body">
                <div class="demo-form">
                    <div class="demo-wide"><label for="<%= txtName.ClientID %>"><%: L.T("Coordinator.Demo.Name") %></label><asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="120" autocomplete="off" /></div>
                    <div class="demo-wide"><label for="<%= txtEmail.ClientID %>"><%: L.T("Coordinator.Demo.Email") %></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" autocomplete="off" /><small><%: L.T("Coordinator.Demo.EmailHelp") %></small></div>
                    <div><label for="<%= txtPassword.ClientID %>"><%: L.T("Coordinator.Demo.Password") %></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" autocomplete="new-password" /></div>
                    <div><label for="<%= txtConfirm.ClientID %>"><%: L.T("Coordinator.Demo.Confirm") %></label><asp:TextBox ID="txtConfirm" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" autocomplete="new-password" /></div>
                    <small class="demo-wide"><%: L.T("Coordinator.Demo.PasswordHelp") %></small>
                    <div class="demo-wide"><asp:Button ID="btnCreate" runat="server" CssClass="btn btn-brand demo-create" Text="<%$ Resources:Coordinator, Demo.Create %>" OnClick="Create_Click" data-ui-action="save" data-ui-validation="none" /></div>
                </div>
            </div>
        </section>

        <section class="rv-card" aria-labelledby="demoWhatTitle" data-rv-reveal>
            <div class="rv-card-head"><h3 id="demoWhatTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M9 11l3 3 8-8"/><path d="M20 12v7a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h9"/></svg></span><%: L.T("Coordinator.Demo.WhatTitle") %></h3></div>
            <div class="rv-card-body">
                <ul class="demo-list">
                    <li><%: L.T("Coordinator.Demo.What1") %></li>
                    <li><%: L.T("Coordinator.Demo.What2") %></li>
                    <li><%: L.T("Coordinator.Demo.What3") %></li>
                    <li><%: L.T("Coordinator.Demo.What4") %></li>
                    <li><%: L.T("Coordinator.Demo.What5") %></li>
                    <li><%: L.T("Coordinator.Demo.What6") %></li>
                </ul>
            </div>
        </section>
    </div>

    <section class="rv-card" aria-labelledby="demoListTitle" data-rv-reveal>
        <div class="rv-card-head"><div><h3 id="demoListTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg></span><%: L.T("Coordinator.Demo.ListTitle") %></h3><p><%: L.T("Coordinator.Demo.ListNote") %></p></div></div>
        <% if (Demos.Count == 0) { %><div class="rv-card-body"><div class="rv-empty"><%: L.T("Coordinator.Demo.None") %></div></div><% } %>
        <asp:Repeater ID="rptDemos" runat="server" OnItemCommand="Demos_Command" OnItemDataBound="Demos_ItemDataBound">
            <ItemTemplate>
                <div class="demo-row">
                    <div>
                        <strong><%#: Eval("FullName") %></strong>
                        <small><%#: Eval("Email") %> · <%#: Eval("CompanyName") %></small>
                        <small><%: L.T("Coordinator.Demo.Supervisors") %> <%#: Eval("CompanySupervisorName") %> · <%#: Eval("AcademicSupervisorName") %></small>
                        <span class='<%#: StatusCss((CompletionStatus)Eval("Status")) %>'><%#: StatusLabel((CompletionStatus)Eval("Status")) %></span>
                    </div>
                    <div class="rv-actions">
                        <a class="btn btn-brand" href='CompletionReview.aspx?id=<%#: Eval("StudentId") %>'><%: L.T("Coordinator.Demo.OpenReview") %></a>
                        <asp:Button ID="btnReset" runat="server" CssClass="btn btn-outline-secondary" CommandName="reset" CommandArgument='<%# Eval("StudentId") %>' Text="<%$ Resources:Coordinator, Demo.Reset %>" data-ui-action="reset" data-ui-validation="none" />
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>
    </section>

    <section class="rv-card" aria-labelledby="demoStepsTitle" data-rv-reveal>
        <div class="rv-card-head"><h3 id="demoStepsTitle"><span class="rv-icon" aria-hidden="true"><svg viewBox="0 0 24 24"><path d="M5 12h14M12 5l7 7-7 7"/></svg></span><%: L.T("Coordinator.Demo.StepsTitle") %></h3></div>
        <div class="rv-card-body">
            <ol class="demo-steps">
                <li><div><strong><%: L.T("Coordinator.Demo.Step1Title") %></strong><span><%: L.T("Coordinator.Demo.Step1") %></span></div></li>
                <li><div><strong><%: L.T("Coordinator.Demo.Step2Title") %></strong><span><%: L.T("Coordinator.Demo.Step2") %></span></div></li>
                <li><div><strong><%: L.T("Coordinator.Demo.Step3Title") %></strong><span><%: L.T("Coordinator.Demo.Step3") %></span></div></li>
                <li><div><strong><%: L.T("Coordinator.Demo.Step4Title") %></strong><span><%: L.T("Coordinator.Demo.Step4") %></span></div></li>
            </ol>
        </div>
    </section>
</div>
</asp:Content>

<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%: ResolveUrl("~/Assets/js/review-system.js?v=20261023-rv6") %>"></script>
</asp:Content>
