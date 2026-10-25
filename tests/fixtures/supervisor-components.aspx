<%@ Page CodePage="65001" Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" %>
<script runat="server">
protected void Page_PreInit(object sender, EventArgs e) { if (Request.QueryString["role"] == "academic") MasterPageFile = "~/Layout/Academic.master"; }
</script>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<header class="sw-heading"><h1>Supervisor UI — synthetic component fixture</h1><p>Local browser verification only. These records are not application data.</p></header>
<dl class="sw-metrics" style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:16px">
<div class="sw-metric"><dt>Assigned students</dt><dd>18</dd><small>Synthetic summary</small></div>
<div class="metric-card"><div class="title">Approved hours</div><div class="value">260</div><div class="desc">Approved entries only</div></div>
<div class="tasks-stat-card"><div><p class="tasks-stat-label">Work to review</p><p class="tasks-stat-number">3</p><p class="tasks-stat-note">Synthetic summary</p></div></div></dl>
<section class="card-custom p-4 mt-4"><h2>Records and controls</h2>
<div class="filter-container d-flex flex-wrap gap-3 my-3">
<div><label for="kitSearch">Search by student name or ID</label><input id="kitSearch" type="search" placeholder="Search by student name or ID" class="filter-input" /></div>
<div><label for="kitFilter">Status</label><select id="kitFilter" class="filter-input"><option>All statuses</option><option>Active</option></select></div>
<button type="button" class="btn btn-primary" id="kitPrimary">Review records</button><button type="button" class="btn btn-exact-match btn-style-light" id="kitSecondary">View details</button><button type="button" class="btn btn-danger" id="kitDanger">Reject</button><button type="button" class="btn" disabled id="kitDisabled">Unavailable</button>
</div>
<table class="clean-table"><thead><tr><th>Student</th><th>Status</th><th>Approved hours</th><th>Action</th></tr></thead><tbody><tr><td><strong>UI fixture student</strong><small>Computer Science · #TEST-001</small></td><td><span class="application-status status-accepted">Accepted</span><span class="badge bg-warning text-dark">Pending</span><span class="status-badge status-rejected">Rejected</span></td><td><div class="su-progress-label"><span>260 / 400 h</span><span>65%</span></div><div class="progress"><div id="kitProgress" class="progress-fill" data-ui-progress="true" data-ui-approved="260" data-ui-target="400"></div></div></td><td><button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#kitModal" id="kitOpen">Edit assessment</button></td></tr></tbody></table>
</section>
<div class="modal fade" id="kitModal" tabindex="-1" aria-labelledby="kitTitle" aria-hidden="true"><div class="modal-dialog modal-dialog-centered"><div class="modal-content"><div class="modal-header"><h2 class="modal-title" id="kitTitle">Review student record</h2><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button></div><div class="modal-body"><label for="kitComment">Feedback</label><textarea id="kitComment" class="form-control" placeholder="Add useful feedback"></textarea><p class="form-text">Synthetic form — nothing is submitted.</p><label for="kitCheck"><input id="kitCheck" type="checkbox" /> I have reviewed this record</label><label for="kitInvalid">Required field</label><input id="kitInvalid" type="text" aria-invalid="true" aria-describedby="kitError" /><span id="kitError" class="ui-field-error">Please check this field.</span><label for="kitReadOnly">Student ID</label><input id="kitReadOnly" readonly value="TEST-001" /></div><div class="modal-footer"><button type="button" class="btn btn-light" data-bs-dismiss="modal">Cancel</button><button type="button" class="btn btn-primary" data-bs-dismiss="modal">Done</button></div></div></div></div>
<section class="uims-paper mt-4 p-3" data-bs-theme="light"><h2 id="kitPaperHeading">Printable document fixture</h2><span class="badge" id="kitPaperBadge">Original document styling</span></section>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server"></asp:Content>
