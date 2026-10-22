
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="Dashboard.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Dashboard"
    Title="Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.student-dashboard {
    --sd-navy: #183d63;
    --sd-blue: #24547f;
    --sd-muted: #71839b;
    --sd-border: #e3eaf3;
    --sd-bg: #f5f8fd;
    color: #18324f;
    padding-bottom: 30px;
}
.student-dashboard * { box-sizing: border-box; }

.sd-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 18px;
    flex-wrap: wrap;
    margin-bottom: 22px;
}
.sd-heading h2 {
    font-size: 27px;
    font-weight: 800;
    margin: 0 0 7px;
    color: var(--sd-navy);
}
.sd-heading p {
    margin: 0;
    font-size: 14px;
    color: var(--sd-muted);
}
.sd-btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 9px;
    padding: 11px 17px;
    border-radius: 9px;
    background: var(--sd-navy);
    color: #fff !important;
    text-decoration: none !important;
    font-size: 13px;
    font-weight: 700;
    transition: .2s ease;
}
.sd-btn:hover {
    background: #102e4d;
    transform: translateY(-1px);
}
.sd-btn-light {
    background: #eef4fb;
    color: var(--sd-navy) !important;
}
.sd-btn-light:hover { background: #e0ebf8; }

.sd-welcome {
    position: relative;
    overflow: hidden;
    border-radius: 15px;
    padding: 25px 29px;
    background: linear-gradient(115deg, #173b60, #28618d);
    color: #fff;
    margin-bottom: 22px;
}
.sd-welcome::after {
    content: "";
    position: absolute;
    width: 210px;
    height: 210px;
    right: -65px;
    top: -105px;
    border: 35px solid rgba(255,255,255,.07);
    border-radius: 50%;
}
.sd-welcome .sd-eyebrow {
    display: block;
    color: #c4ddf4;
    font-size: 12px;
    letter-spacing: .5px;
    font-weight: 700;
    margin-bottom: 8px;
}
.sd-welcome h3 {
    color: white;
    font-size: 25px;
    font-weight: 800;
    margin: 0 0 9px;
}
.sd-welcome p {
    color: #e3effa;
    font-size: 13px;
    margin: 0;
}
.sd-metrics {
    display: grid;
    grid-template-columns: repeat(4, minmax(0, 1fr));
    gap: 15px;
    margin-bottom: 22px;
}
.sd-card, .sd-panel {
    background: white;
    border: 1px solid var(--sd-border);
    border-radius: 13px;
    box-shadow: 0 4px 16px rgba(20,50,80,.035);
}
.sd-card {
    padding: 19px 19px 17px;
    min-height: 153px;
}
.sd-card-top {
    display: flex;
    align-items: flex-start;
    justify-content: space-between;
    gap: 8px;
    margin-bottom: 17px;
}
.sd-card-label {
    color: #61748d;
    font-size: 12px;
    font-weight: 700;
}
.sd-icon {
    width: 38px;
    height: 38px;
    flex: 0 0 38px;
    display: grid;
    place-items: center;
    border-radius: 10px;
    background: #eaf2fc;
    color: var(--sd-blue);
}
.sd-icon svg {
    width: 19px;
    height: 19px;
    stroke: currentColor;
    fill: none;
    stroke-width: 1.8;
    stroke-linecap: round;
    stroke-linejoin: round;
}
.sd-card-value {
    color: var(--sd-navy);
    font-size: 30px;
    font-weight: 800;
    line-height: 1.1;
    margin-bottom: 10px;
}
.sd-card-caption {
    color: var(--sd-muted);
    font-size: 11px;
    line-height: 1.5;
}
.sd-layout {
    display: grid;
    grid-template-columns: minmax(0, 1.3fr) minmax(0, 1fr);
    gap: 18px;
    margin-bottom: 20px;
}
.sd-panel {
    padding: 21px;
    min-width: 0;
}
.sd-panel-heading {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    margin-bottom: 18px;
}
.sd-panel-heading h3 {
    color: var(--sd-navy);
    font-size: 16px;
    font-weight: 800;
    margin: 0 0 5px;
}
.sd-panel-heading p {
    font-size: 12px;
    color: var(--sd-muted);
    margin: 0;
}
.sd-view-link {
    color: var(--sd-blue);
    font-size: 12px;
    font-weight: 700;
    text-decoration: none;
    white-space: nowrap;
}
.sd-view-link:hover { text-decoration: underline; }

.sd-list { width: 100%; }
.sd-list-item {
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    padding: 14px 0;
    border-top: 1px solid #edf1f6;
}
.sd-list-item:first-child { border-top: 0; padding-top: 3px; }
.sd-item-main { min-width: 0; }
.sd-item-title {
    font-size: 13px;
    font-weight: 750;
    color: #244766;
    margin-bottom: 5px;
    overflow-wrap: anywhere;
}
.sd-item-meta {
    font-size: 11px;
    color: var(--sd-muted);
    line-height: 1.6;
}
.sd-pill {
    display: inline-block;
    border-radius: 50px;
    background: #eaf2fb;
    color: #24547f;
    padding: 5px 10px;
    font-size: 10px;
    font-weight: 800;
    white-space: nowrap;
}
.sd-empty {
    padding: 23px 12px;
    border: 1px dashed #d9e4f0;
    border-radius: 10px;
    background: #f9fbfe;
    text-align: center;
    color: var(--sd-muted);
    font-size: 13px;
}
.sd-progress-value {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 13px;
    font-size: 13px;
}
.sd-progress-value strong {
    color: var(--sd-navy);
    font-size: 22px;
}
.sd-progress-track {
    height: 11px;
    background: #e8eff7;
    border-radius: 30px;
    overflow: hidden;
}
.sd-progress-fill {
    height: 100%;
    width: 0;
    border-radius: 30px;
    background: linear-gradient(90deg,#285f90,#5a9bcc);
}
.sd-progress-note {
    margin: 13px 0 0;
    font-size: 12px;
    line-height: 1.7;
    color: var(--sd-muted);
}
.sd-progress-actions {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
    margin-top: 20px;
}
.sd-section-title {
    color: var(--sd-navy);
    font-size: 16px;
    font-weight: 800;
    margin: 0 0 15px;
}
.sd-shortcuts {
    display: grid;
    grid-template-columns: repeat(4, minmax(0,1fr));
    gap: 13px;
}
.sd-shortcut {
    display: block;
    padding: 18px;
    border: 1px solid var(--sd-border);
    background: #fff;
    border-radius: 12px;
    text-decoration: none !important;
    transition: .2s;
}
.sd-shortcut:hover {
    border-color: #a9c4e1;
    transform: translateY(-2px);
    box-shadow: 0 8px 20px rgba(20,50,80,.07);
}
.sd-shortcut .sd-icon { margin-bottom: 14px; }
.sd-shortcut strong {
    display: block;
    color: var(--sd-navy);
    font-size: 13px;
    margin-bottom: 6px;
}
.sd-shortcut span:last-child {
    display: block;
    font-size: 11px;
    line-height: 1.6;
    color: var(--sd-muted);
}
.sd-alert {
    padding: 14px 16px;
    margin-bottom: 20px;
    background: #fff7e7;
    border: 1px solid #f0d7a7;
    border-radius: 10px;
    color: #795316;
    font-size: 13px;
}
@media (max-width: 1100px) {
    .sd-metrics { grid-template-columns: repeat(2, minmax(0,1fr)); }
    .sd-shortcuts { grid-template-columns: repeat(2, minmax(0,1fr)); }
}
@media (max-width: 800px) {
    .sd-layout { grid-template-columns: 1fr; }
}
@media (max-width: 520px) {
    .sd-metrics, .sd-shortcuts { grid-template-columns: 1fr; }
    .sd-heading h2 { font-size: 23px; }
    .sd-welcome { padding: 22px; }
    .sd-welcome h3 { font-size: 21px; }
    .sd-panel { padding: 17px; }
    .sd-list-item { align-items: flex-start; flex-direction: column; }
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="student-dashboard">

    <div class="sd-heading">
        <div>
            <h2>Student Dashboard</h2>
            <p>Your personal internship overview and academic progress.</p>
        </div>
        <a class="sd-btn"
           href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
            Explore Opportunities &rarr;
        </a>
    </div>

    <div class="sd-welcome">
        <span class="sd-eyebrow">STUDENT PORTAL</span>
        <h3>Welcome back, <asp:Literal ID="litStudentName" runat="server" />!</h3>
        <p>Stay up to date with your internship applications, assigned tasks,
           evaluations and training progress.</p>
    </div>

    <asp:Panel ID="pnlError" runat="server"
        Visible="false" CssClass="sd-alert">
        Some dashboard information could not be loaded.
        Please refresh the page or try again later.
    </asp:Panel>

    <div class="sd-metrics">

        <div class="sd-card">
            <div class="sd-card-top">
                <span class="sd-card-label">My Applications</span>
                <span class="sd-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M7 3h8l4 4v14H7z"/>
                        <path d="M15 3v5h4M10 12h6M10 16h6"/>
                    </svg>
                </span>
            </div>
            <div class="sd-card-value">
                <asp:Literal ID="litApplications" runat="server" />
            </div>
            <div class="sd-card-caption">Total submitted internship applications</div>
        </div>

        <div class="sd-card">
            <div class="sd-card-top">
                <span class="sd-card-label">Assigned Tasks</span>
                <span class="sd-icon">
                    <svg viewBox="0 0 24 24">
                        <rect x="4" y="4" width="16" height="17" rx="2"/>
                        <path d="M8 11l2 2 5-5M8 17h8"/>
                    </svg>
                </span>
            </div>
            <div class="sd-card-value">
                <asp:Literal ID="litTasks" runat="server" />
            </div>
            <div class="sd-card-caption">Tasks assigned during your training</div>
        </div>

        <div class="sd-card">
            <div class="sd-card-top">
                <span class="sd-card-label">Evaluated Tasks</span>
                <span class="sd-icon">
                    <svg viewBox="0 0 24 24">
                        <path d="M12 3l3 6 6 .9-4.5 4.4 1.1 6.2L12 17.6l-5.6 2.9 1.1-6.2L3 9.9 9 9z"/>
                    </svg>
                </span>
            </div>
            <div class="sd-card-value">
                <asp:Literal ID="litEvaluations" runat="server" />
            </div>
            <div class="sd-card-caption">Tasks with recorded evaluations</div>
        </div>

        <div class="sd-card">
            <div class="sd-card-top">
                <span class="sd-card-label">Approved Hours</span>
                <span class="sd-icon">
                    <svg viewBox="0 0 24 24">
                        <circle cx="12" cy="12" r="9"/>
                        <path d="M12 7v5l3 2"/>
                    </svg>
                </span>
            </div>
            <div class="sd-card-value">
                <asp:Literal ID="litHours" runat="server" />
            </div>
            <div class="sd-card-caption">Officially approved training hours</div>
        </div>

    </div>

    <div class="sd-layout">

        <div class="sd-panel">
            <div class="sd-panel-heading">
                <div>
                    <h3>Recent Application Updates</h3>
                    <p>Track the latest decisions on your applications.</p>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
                    View all &rarr;
                </a>
            </div>

            <asp:Repeater ID="rptApplications" runat="server">
                <ItemTemplate>
                    <div class="sd-list-item">
                        <div class="sd-item-main">
                            <div class="sd-item-title">
                                <%#: Eval("Title") %>
                            </div>
                            <div class="sd-item-meta">
                                <%#: Eval("Company") %>
                                &bull;
                                <%#: Eval("Date") %>
                            </div>
                        </div>
                        <span class="sd-pill">
                            <%#: Eval("Status") %>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoApplications" runat="server"
                Visible="false" CssClass="sd-empty">
                You haven't submitted any applications yet.
                <div style="margin-top:12px">
                    <a class="sd-view-link"
                       href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
                        Find an internship opportunity &rarr;
                    </a>
                </div>
            </asp:Panel>
        </div>

        <div class="sd-panel">
            <div class="sd-panel-heading">
                <div>
                    <h3>Upcoming Deadlines</h3>
                    <p>Keep track of your training tasks.</p>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">
                    My tasks &rarr;
                </a>
            </div>

            <asp:Repeater ID="rptTasks" runat="server">
                <ItemTemplate>
                    <div class="sd-list-item">
                        <div class="sd-item-main">
                            <div class="sd-item-title">
                                <%#: Eval("Title") %>
                            </div>
                            <div class="sd-item-meta">
                                Due: <%#: Eval("DeadlineText") %>
                            </div>
                        </div>
                        <span class="sd-pill">
                            <%#: Eval("Status") %>
                        </span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Panel ID="pnlNoTasks" runat="server"
                Visible="false" CssClass="sd-empty">
                No upcoming task deadlines right now.
            </asp:Panel>
        </div>

    </div>

    <div class="sd-layout">

        <div class="sd-panel">
            <div class="sd-panel-heading">
                <div>
                    <h3>Training Progress</h3>
                    <p>Your approved hours toward the required total.</p>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/Progress.aspx") %>">
                    Details &rarr;
                </a>
            </div>

            <div class="sd-progress-value">
                <span>
                    <asp:Literal ID="litProgressHours" runat="server" />
                </span>
                <strong>
                    <asp:Literal ID="litPercent" runat="server" />%
                </strong>
            </div>

            <div class="sd-progress-track"
                 role="progressbar"
                 aria-label="Approved training hours progress"
                 aria-valuemin="0"
                 aria-valuemax="100">
                <div ID="progressFill" runat="server"
                     class="sd-progress-fill"></div>
            </div>

            <p class="sd-progress-note">
                Only supervisor-approved hours count toward your training
                progress. Reported hours awaiting approval are not included.
            </p>

            <div class="sd-progress-actions">
                <a class="sd-btn sd-btn-light"
                   href="<%: ResolveUrl("~/Pages/Student/Progress.aspx") %>">
                    View Progress
                </a>
                <a class="sd-btn sd-btn-light"
                   href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">
                    View Tasks
                </a>
            </div>
        </div>

        <div class="sd-panel">
            <div class="sd-panel-heading">
                <div>
                    <h3>Academic &amp; Training Support</h3>
                    <p>Important areas of your student portal.</p>
                </div>
            </div>

            <div class="sd-list-item">
                <div class="sd-item-main">
                    <div class="sd-item-title">My Profile</div>
                    <div class="sd-item-meta">
                        Review your academic and personal information.
                    </div>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/Profile.aspx") %>">
                    Open &rarr;
                </a>
            </div>

            <div class="sd-list-item">
                <div class="sd-item-main">
                    <div class="sd-item-title">Progress &amp; Evaluation</div>
                    <div class="sd-item-meta">
                        Review your training progress and available feedback.
                    </div>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/Progress.aspx") %>">
                    Open &rarr;
                </a>
            </div>

            <div class="sd-list-item">
                <div class="sd-item-main">
                    <div class="sd-item-title">My Applications</div>
                    <div class="sd-item-meta">
                        Check application status and company decisions.
                    </div>
                </div>
                <a class="sd-view-link"
                   href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
                    Open &rarr;
                </a>
            </div>
        </div>

    </div>

    <h3 class="sd-section-title">Quick Access</h3>

    <div class="sd-shortcuts">

        <a class="sd-shortcut"
           href="<%: ResolveUrl("~/Pages/Student/Opportunities.aspx") %>">
            <span class="sd-icon">
                <svg viewBox="0 0 24 24">
                    <circle cx="10" cy="10" r="6"/>
                    <path d="m15 15 6 6"/>
                </svg>
            </span>
            <strong>Explore Opportunities</strong>
            <span>Find internships matching your academic program.</span>
        </a>

        <a class="sd-shortcut"
           href="<%: ResolveUrl("~/Pages/Student/MyApplications.aspx") %>">
            <span class="sd-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M7 3h8l4 4v14H7zM15 3v5h4M10 12h6M10 16h6"/>
                </svg>
            </span>
            <strong>My Applications</strong>
            <span>Review submitted applications and their status.</span>
        </a>

        <a class="sd-shortcut"
           href="<%: ResolveUrl("~/Pages/Student/MyTasks.aspx") %>">
            <span class="sd-icon">
                <svg viewBox="0 0 24 24">
                    <rect x="4" y="4" width="16" height="17" rx="2"/>
                    <path d="M8 11l2 2 5-5M8 17h8"/>
                </svg>
            </span>
            <strong>My Tasks</strong>
            <span>Follow assignments and upcoming deadlines.</span>
        </a>

        <a class="sd-shortcut"
           href="<%: ResolveUrl("~/Pages/Student/StudentCVPortfolio.aspx") %>">
            <span class="sd-icon">
                <svg viewBox="0 0 24 24">
                    <path d="M7 3h8l4 4v14H7zM15 3v5h4M10 12h6"/>
                </svg>
            </span>
            <strong>CV &amp; Portfolio</strong>
            <span>Manage your CV and professional portfolio links.</span>
        </a>

    </div>

</div>

</asp:Content>
