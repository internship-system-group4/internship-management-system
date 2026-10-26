
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Profile"
    Title="My Profile" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
/* My Profile: editable details live on the page with one always-visible Save bar. */
.spx, .spx-toast {
    --spx-line: var(--ui-border, #e3e8ee);
    --spx-surface: var(--ui-surface, #fff);
    --spx-ink: var(--ui-ink, #1d2733);
    --spx-muted: var(--ui-muted, #5f6b7a);
    --spx-primary: var(--ui-primary, #173a60);
    --spx-soft: var(--ui-primary-soft, #e8eef6);
}
.spx {
    width: 100%;
    max-width: 1180px;
    margin: 0 auto;
    padding: 8px 4px 48px;
    color: var(--spx-ink);
}
.spx * { box-sizing: border-box; }

.spx-head { margin-bottom: 20px; }
body.uims-portal .spx .spx-head h2 { margin: 0 0 4px; font-size: 26px; font-weight: 800; color: var(--ui-primary-text, var(--spx-primary)); }
body.uims-portal .spx .spx-head p { margin: 0; font-size: 14px; color: var(--spx-muted); }

.spx-alert {
    display: flex; gap: 10px; align-items: flex-start;
    margin-bottom: 18px; padding: 12px 14px;
    border-radius: 12px; font-size: 14px; font-weight: 600;
    background: var(--ui-danger-soft, #fdecec); color: var(--ui-danger-strong, #8f1d1d);
    border: 1px solid color-mix(in srgb, var(--ui-danger, #c62828) 30%, transparent);
}
.spx-alert svg { flex: 0 0 18px; width: 18px; height: 18px; margin-top: 1px; }

.spx-card {
    background: var(--spx-surface);
    border: 1px solid var(--spx-line);
    border-radius: 16px;
    box-shadow: 0 1px 2px rgba(16,24,40,.04), 0 6px 18px rgba(16,24,40,.04);
}

/* Identity strip */
.spx-hero {
    display: grid;
    grid-template-columns: auto 1fr auto;
    gap: 22px;
    align-items: center;
    padding: 22px 24px;
    margin-bottom: 20px;
    position: relative;
    overflow: hidden;
}
.spx-hero::before {
    content: ""; position: absolute; inset-block: 0; inset-inline-start: 0; width: 5px;
    background: linear-gradient(180deg, var(--spx-primary), var(--ui-accent, #d9a43b));
}
.spx-avatar {
    position: relative; width: 92px; height: 92px; border-radius: 50%;
    display: grid; place-items: center; overflow: hidden;
    background: var(--spx-soft); color: var(--spx-primary);
    font-size: 30px; font-weight: 800; letter-spacing: .02em;
    border: 3px solid var(--spx-surface);
    box-shadow: 0 0 0 1px var(--spx-line), 0 6px 16px rgba(16,24,40,.10);
}
.spx-avatar img { width: 100%; height: 100%; object-fit: cover; }
.spx-avatar-edit {
    position: absolute; inset: auto 0 0 0; height: 34%;
    display: grid; place-items: center; cursor: pointer;
    background: rgba(15,27,45,.62); color: #fff;
    opacity: 0; transition: opacity .18s ease;
}
.spx-avatar:hover .spx-avatar-edit,
.spx-avatar:focus-within .spx-avatar-edit { opacity: 1; }
.spx-avatar-edit svg { width: 18px; height: 18px; }
body.uims-portal .spx .spx-name { margin: 0 0 4px; font-size: 22px; font-weight: 800; }
.spx-meta { margin: 0 0 10px; color: var(--spx-muted); font-size: 14px; }
.spx-chips { display: flex; flex-wrap: wrap; gap: 8px; }
.spx-chip {
    display: inline-flex; align-items: center; gap: 6px;
    padding: 4px 10px; border-radius: 999px;
    background: var(--ui-neutral-soft, #f1f4f8); color: var(--spx-ink);
    font-size: 12px; font-weight: 600;
}
.spx-chip svg { width: 14px; height: 14px; }
.spx-photo-link {
    display: inline-flex; align-items: center; gap: 6px; margin-top: 10px;
    color: var(--ui-primary-text, var(--spx-primary)); font-size: 13px; font-weight: 700;
    cursor: pointer; background: none; border: 0; padding: 0;
}
.spx-photo-link:hover { text-decoration: underline; }
.spx-photo-link svg { width: 16px; height: 16px; }
.spx-photo-name { display: block; margin-top: 4px; font-size: 12px; color: var(--spx-muted); }

.spx-hours { min-width: 190px; text-align: end; }
.spx-hours strong { display: block; font-size: 24px; font-weight: 800; line-height: 1.1; }
.spx-hours small { color: var(--spx-muted); font-size: 12px; }
.spx-bar { height: 8px; margin-top: 10px; border-radius: 99px; background: var(--ui-neutral-soft, #eef1f5); overflow: hidden; }
.spx-bar span {
    display: block; height: 100%; border-radius: inherit;
    background: linear-gradient(90deg, var(--spx-primary), var(--ui-success, #2e7d32));
    transform-origin: left; animation: spx-grow .9s cubic-bezier(.2,.8,.2,1) both;
}
[dir=rtl] .spx-bar span { transform-origin: right; }
@keyframes spx-grow { from { transform: scaleX(0); } }

/* Two columns: form + side information */
.spx-grid { display: grid; grid-template-columns: minmax(0,1fr) 340px; gap: 20px; align-items: start; }
.spx-side { display: grid; gap: 20px; }

.spx-card-head {
    display: flex; align-items: center; justify-content: space-between; gap: 12px;
    padding: 18px 22px 14px; border-bottom: 1px solid var(--spx-line);
}
body.uims-portal .spx .spx-card-head h3 { margin: 0; font-size: 16px; font-weight: 800; }
body.uims-portal .spx .spx-card-head p { margin: 2px 0 0; font-size: 13px; color: var(--spx-muted); }
.spx-badge {
    display: inline-flex; align-items: center; gap: 5px; flex-shrink: 0;
    padding: 3px 9px; border-radius: 999px; font-size: 11px; font-weight: 700;
    background: var(--ui-neutral-soft, #f1f4f8); color: var(--spx-muted);
}
.spx-badge svg { width: 12px; height: 12px; }

.spx-body { padding: 20px 22px 6px; }
.spx-group + .spx-group { margin-top: 6px; padding-top: 18px; border-top: 1px dashed var(--spx-line); }
.spx-group-title {
    margin: 0 0 12px; font-size: 12px; font-weight: 800;
    letter-spacing: .06em; text-transform: uppercase; color: var(--spx-muted);
}
.spx-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 14px 16px; margin-bottom: 14px; }
.spx-field { display: flex; flex-direction: column; gap: 6px; min-width: 0; }
.spx-field.spx-wide { grid-column: 1 / -1; }
.spx-field label, .spx-field-label { font-size: 13px; font-weight: 700; }
.spx-field label .spx-req { color: var(--ui-danger, #c62828); }
.spx-input {
    width: 100%; min-height: 42px; padding: 9px 12px;
    font: inherit; font-size: 14px; color: var(--spx-ink);
    background: var(--ui-surface-raised, var(--spx-surface));
    border: 1px solid var(--ui-control-border, #cfd7e1); border-radius: 10px;
    transition: border-color .15s ease, box-shadow .15s ease;
}
textarea.spx-input { min-height: 92px; resize: vertical; line-height: 1.5; }
.spx-input:hover { border-color: color-mix(in srgb, var(--spx-primary) 45%, var(--ui-control-border, #cfd7e1)); }
.spx-input:focus { outline: none; border-color: var(--spx-primary); box-shadow: 0 0 0 3px var(--ui-focus, rgba(23,58,96,.18)); }
.spx-help { font-size: 12px; color: var(--spx-muted); }
.spx-locked {
    display: flex; align-items: center; gap: 8px; min-height: 42px; padding: 9px 12px;
    border-radius: 10px; background: var(--ui-neutral-soft, #f4f6f9); color: var(--spx-muted);
    font-size: 14px; overflow-wrap: anywhere;
}
.spx-locked svg { width: 15px; height: 15px; flex-shrink: 0; }

/* Save bar: always visible at the bottom of the form while scrolling */
.spx-savebar {
    position: sticky; bottom: 12px; z-index: 5;
    display: flex; align-items: center; justify-content: space-between; gap: 12px;
    margin: 8px 12px 12px; padding: 12px 14px;
    border-radius: 14px; border: 1px solid var(--spx-line);
    background: color-mix(in srgb, var(--spx-surface) 92%, transparent);
    backdrop-filter: blur(8px);
    box-shadow: 0 8px 24px rgba(16,24,40,.10);
}
.spx-status { display: flex; align-items: center; gap: 8px; font-size: 13px; color: var(--spx-muted); }
.spx-status-dot { width: 8px; height: 8px; border-radius: 50%; background: var(--ui-success, #2e7d32); }
.spx-dirty .spx-status { color: var(--ui-warning-strong, #8a5a00); font-weight: 700; }
.spx-dirty .spx-status-dot { background: var(--ui-warning, #e0a100); animation: spx-pulse 1.4s ease-in-out infinite; }
@keyframes spx-pulse { 50% { box-shadow: 0 0 0 5px color-mix(in srgb, var(--ui-warning, #e0a100) 25%, transparent); } }
.spx-buttons { display: flex; gap: 8px; }
.spx-btn {
    display: inline-flex; align-items: center; justify-content: center; gap: 7px;
    min-height: 42px; padding: 9px 18px; border-radius: 10px;
    font: inherit; font-size: 14px; font-weight: 700; cursor: pointer; text-decoration: none;
    white-space: nowrap;
    border: 1px solid transparent; transition: background .15s ease, transform .1s ease, box-shadow .15s ease;
}
.spx-btn:active { transform: translateY(1px); }
.spx-btn svg { width: 17px; height: 17px; }
.spx-btn-primary { background: var(--spx-primary); color: #fff; }
.spx-btn-primary:hover { background: var(--ui-primary-hover, #0f2b49); color: #fff; }
.spx-dirty .spx-btn-primary { box-shadow: 0 0 0 4px var(--ui-focus, rgba(23,58,96,.18)); }
.spx-btn-ghost { background: transparent; color: var(--spx-ink); border-color: var(--spx-line); }
.spx-btn-ghost:hover { background: var(--ui-neutral-soft, #f1f4f8); color: var(--spx-ink); }
.spx-btn-ghost[hidden] { display: none; }
.spx-btn:focus-visible { outline: 3px solid var(--ui-focus, rgba(23,58,96,.35)); outline-offset: 2px; }

/* Side cards */
.spx-note { margin: 14px 22px 0; padding: 10px 12px; border-radius: 10px; font-size: 12.5px; line-height: 1.5; background: var(--ui-info-soft, #eaf2fb); color: var(--spx-ink); }
.spx-list { margin: 0; padding: 6px 22px 14px; }
.spx-list div { display: flex; justify-content: space-between; gap: 12px; padding: 10px 0; border-bottom: 1px solid var(--spx-line); }
.spx-list div:last-child { border-bottom: 0; }
.spx-list dt { font-size: 13px; color: var(--spx-muted); font-weight: 600; }
.spx-list dd { margin: 0; font-size: 13px; font-weight: 700; text-align: end; overflow-wrap: anywhere; }
.spx-doc { display: flex; align-items: center; gap: 12px; padding: 12px 22px; border-bottom: 1px solid var(--spx-line); }
.spx-doc-icon { width: 38px; height: 38px; border-radius: 10px; display: grid; place-items: center; background: var(--spx-soft); color: var(--spx-primary); flex-shrink: 0; }
.spx-doc-icon svg { width: 18px; height: 18px; }
.spx-doc strong { display: block; font-size: 14px; }
.spx-doc a, .spx-doc span { font-size: 12px; }
.spx-doc a { color: var(--ui-primary-text, var(--spx-primary)); font-weight: 700; }
.spx-doc span { color: var(--spx-muted); }
.spx-side-foot { padding: 14px 22px 18px; }
.spx-side-foot .spx-btn { width: 100%; }

/* Animated "Saved" toast */
.spx-toast {
    position: fixed; z-index: var(--ui-z-toast, 1080);
    inset-block-start: 22px; inset-inline-end: 22px;
    display: flex; align-items: center; gap: 12px;
    min-width: 260px; max-width: calc(100vw - 32px);
    padding: 14px 16px 16px; border-radius: 14px; overflow: hidden;
    background: var(--spx-surface); color: var(--spx-ink);
    border: 1px solid color-mix(in srgb, var(--ui-success, #2e7d32) 35%, var(--spx-line));
    box-shadow: 0 18px 40px rgba(16,24,40,.18);
    animation: spx-toast-in .55s cubic-bezier(.2,1.2,.3,1) both;
}
.spx-toast.spx-leaving { animation: spx-toast-out .35s ease-in both; }
.spx-toast strong { display: block; font-size: 15px; }
.spx-toast small { color: var(--spx-muted); font-size: 13px; }
.spx-toast-close { margin-inline-start: auto; background: none; border: 0; color: var(--spx-muted); cursor: pointer; padding: 4px; border-radius: 6px; }
.spx-toast-close svg { width: 16px; height: 16px; }
.spx-check { width: 40px; height: 40px; flex-shrink: 0; }
.spx-check circle { fill: var(--ui-success-soft, #e7f4ea); stroke: var(--ui-success, #2e7d32); stroke-width: 2.5; stroke-dasharray: 126; stroke-dashoffset: 126; animation: spx-draw .6s .15s ease-out forwards; }
.spx-check path { fill: none; stroke: var(--ui-success, #2e7d32); stroke-width: 3.5; stroke-linecap: round; stroke-linejoin: round; stroke-dasharray: 30; stroke-dashoffset: 30; animation: spx-draw .35s .6s ease-out forwards; }
.spx-toast-timer { position: absolute; inset-inline: 0; bottom: 0; height: 3px; background: var(--ui-success, #2e7d32); transform-origin: left; animation: spx-timer 4.5s linear forwards; }
[dir=rtl] .spx-toast-timer { transform-origin: right; }
@keyframes spx-draw { to { stroke-dashoffset: 0; } }
@keyframes spx-timer { to { transform: scaleX(0); } }
@keyframes spx-toast-in { from { opacity: 0; transform: translateY(-16px) scale(.96); } }
@keyframes spx-toast-out { to { opacity: 0; transform: translateY(-12px) scale(.97); } }
.spx-saved-flash { animation: spx-flash 1.6s ease-out .2s; }
@keyframes spx-flash { 0% { box-shadow: 0 0 0 0 color-mix(in srgb, var(--ui-success, #2e7d32) 45%, transparent); } 100% { box-shadow: 0 0 0 14px transparent; } }

.spx-visually-hidden { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); white-space: nowrap; border: 0; }

@media (max-width: 1080px) {
    .spx-grid { grid-template-columns: 1fr; }
    .spx-side { grid-template-columns: 1fr 1fr; }
}
@media (max-width: 720px) {
    .spx-hero { grid-template-columns: auto 1fr; padding: 18px; gap: 16px; }
    .spx-hours { grid-column: 1 / -1; text-align: start; }
    .spx-avatar { width: 72px; height: 72px; font-size: 24px; }
    .spx-fields, .spx-side { grid-template-columns: 1fr; }
    .spx-body { padding: 16px 16px 4px; }
    .spx-card-head { padding: 16px; }
    .spx-savebar { flex-direction: column; align-items: stretch; margin: 6px 8px 8px; }
    .spx-buttons .spx-btn { flex: 1; }
    .spx-toast { inset-inline: 16px; }
}
@media (prefers-reduced-motion: reduce) {
    .spx *, .spx-toast, .spx-toast * { animation-duration: .01ms !important; animation-delay: 0s !important; transition: none !important; }
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="spx" id="studentProfilePage">

    <div class="spx-head">
        <h2><%: L.T("Student.Profile.MyStudentProfile") %></h2>
        <p><%: L.T("Student.Profile.ManageYourPersonalDetailsAcademicInformation") %></p>
    </div>

    <% if (NoticeIsError && !string.IsNullOrWhiteSpace(Notice)) { %>
    <div class="spx-alert" role="alert">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16.5v.5"/></svg>
        <span><%: Notice %></span>
    </div>
    <% } %>

    <% if (student != null) { %>
    <!-- Identity -->
    <div class="spx-card spx-hero<%= JustSaved ? " spx-saved-flash" : "" %>">
        <div class="spx-avatar" id="spxAvatar">
            <% if (HasPhoto) { %>
                <img src="<%: PhotoUrl %>" alt="<%: L.T("Student.Profile.StudentProfilePhoto") %>" />
            <% } else { %>
                <span id="spxInitials"><%: Initials %></span>
            <% } %>
            <label class="spx-avatar-edit" for="spPhoto" title="<%: L.T("Student.Profile.ChangePhoto") %>">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></svg>
                <span class="spx-visually-hidden"><%: L.T("Student.Profile.ChangePhoto") %></span>
            </label>
        </div>

        <div>
            <h3 class="spx-name"><%: StudentName %></h3>
            <p class="spx-meta"><%: StudentMajor %><%: string.IsNullOrEmpty(StudentMajor) ? "" : " · " %><%: L.T("Student.Profile.GermanJordanianUniversity").TrimStart('|', ' ') %></p>
            <div class="spx-chips">
                <span class="spx-chip">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m2 9 10-5 10 5-10 5-10-5Zm4 2v5c4 3 8 3 12 0v-5"/></svg>
                    <%: L.T("Student.Profile.Student") %>
                </span>
                <% if (!string.IsNullOrEmpty(StudentNumber)) { %>
                <span class="spx-chip">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="5" width="18" height="14" rx="2"/><path d="M7 10h4M7 14h6M15 10h2"/></svg>
                    <%: StudentNumber %>
                </span>
                <% } %>
            </div>
            <label class="spx-photo-link" for="spPhoto">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 8h3l2-3h6l2 3h3v11H4z"/><circle cx="12" cy="13" r="3.5"/></svg>
                <%: L.T("Student.Profile.ChangePhoto") %>
            </label>
            <span class="spx-photo-name" id="spxPhotoName"><%: L.T("Student.Profile.JPGOrPNGMaximum2MB") %></span>
        </div>

        <div class="spx-hours">
            <small><%: L.T("Student.Profile.TrainingHours") %></small>
            <strong><%: ApprovedHoursText %> / <%: RequiredHoursText %></strong>
            <small><%: L.T("Student.Profile.ApprovedTrainingHours") %></small>
            <div class="spx-bar" role="progressbar" aria-valuemin="0" aria-valuemax="100" aria-valuenow="<%= HoursPercent %>" aria-label="<%: L.T("Student.Profile.TrainingHours") %>"><span style="width:<%= HoursPercent %>%"></span></div>
        </div>
    </div>

    <div class="spx-grid">

        <!-- Editable details -->
        <section class="spx-card" id="spxForm" aria-labelledby="spxFormTitle">
            <div class="spx-card-head">
                <div>
                    <h3 id="spxFormTitle"><%: L.T("Student.Profile.PersonalInformation") %></h3>
                    <p><%: L.T("Student.Profile.UpdateYourPersonalAndContactInformation") %></p>
                </div>
            </div>

            <div class="spx-body">
                <input type="file" id="spPhoto" name="spPhoto" accept=".jpg,.jpeg,.png" class="spx-visually-hidden" tabindex="-1" />

                <div class="spx-group">
                    <div class="spx-fields">
                        <div class="spx-field spx-wide">
                            <label for="spName"><%: L.T("Student.Profile.FullName") %></label>
                            <input class="spx-input" id="spName" name="spName" type="text" maxlength="120" required autocomplete="name"
                                   value="<%: FormValue("spName", StudentName) %>" />
                        </div>
                        <div class="spx-field">
                            <label for="spAge"><%: L.T("Student.Profile.Age") %></label>
                            <input class="spx-input" id="spAge" name="spAge" type="number" min="16" max="100" inputmode="numeric"
                                   value="<%: FormValue("spAge", AgeText) %>" />
                        </div>
                        <div class="spx-field">
                            <label for="spPhone"><%: L.T("Student.Profile.PhoneNumber") %></label>
                            <input class="spx-input" id="spPhone" name="spPhone" type="tel" maxlength="25" autocomplete="tel"
                                   placeholder="<%: L.T("Student.Profile.9627XXXXXXXX") %>"
                                   value="<%: FormValue("spPhone", StudentPhone) %>" />
                        </div>
                        <div class="spx-field spx-wide">
                            <span class="spx-field-label"><%: L.T("Student.Profile.UniversityAccountEmail") %></span>
                            <div class="spx-locked">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>
                                <%: StudentEmail %>
                            </div>
                            <span class="spx-help"><%: L.T("Student.Profile.ManagedByYourUniversityAccount") %></span>
                        </div>
                    </div>
                </div>

                <div class="spx-group">
                    <p class="spx-group-title"><%: L.T("Student.Profile.SkillsCompetencies") %></p>
                    <div class="spx-fields">
                        <div class="spx-field">
                            <label for="spTechnical"><%: L.T("Student.Profile.TechnicalSkills") %></label>
                            <textarea class="spx-input" id="spTechnical" name="spTechnical" maxlength="1500"
                                      placeholder="<%: L.T("Student.Profile.ExampleCASPNETHTMLCSS") %>"><%: FormValue("spTechnical", TechnicalSkills) %></textarea>
                            <span class="spx-help"><%: L.T("Student.Profile.ProgrammingLanguagesFrameworksToolsAndTechnologies") %></span>
                        </div>
                        <div class="spx-field">
                            <label for="spSoft"><%: L.T("Student.Profile.SoftSkills") %></label>
                            <textarea class="spx-input" id="spSoft" name="spSoft" maxlength="1500"
                                      placeholder="<%: L.T("Student.Profile.ExampleTeamworkCommunicationTimeManagement") %>"><%: FormValue("spSoft", SoftSkills) %></textarea>
                            <span class="spx-help"><%: L.T("Student.Profile.CommunicationLeadershipProblemSolvingAndTeamwork") %></span>
                        </div>
                        <div class="spx-field spx-wide">
                            <label for="spLinkedIn"><%: L.T("Student.Profile.LinkedInProfile") %></label>
                            <input class="spx-input" id="spLinkedIn" name="spLinkedIn" type="url" maxlength="500"
                                   placeholder="https://www.linkedin.com/in/..."
                                   value="<%: FormValue("spLinkedIn", LinkedInUrl) %>" />
                        </div>
                    </div>
                </div>
            </div>

            <div class="spx-savebar" id="spxSaveBar">
                <span class="spx-status" aria-live="polite">
                    <span class="spx-status-dot" aria-hidden="true"></span>
                    <span id="spxStatusText"
                          data-clean="<%: L.T("Student.Profile.AllChangesSaved") %>"
                          data-dirty="<%: L.T("Student.Profile.UnsavedChanges") %>"><%: L.T("Student.Profile.AllChangesSaved") %></span>
                </span>
                <span class="spx-buttons">
                    <a class="spx-btn spx-btn-ghost" id="spxDiscard" href="<%: ResolveUrl("~/Pages/Student/Profile.aspx") %>" hidden><%: L.T("Student.Profile.Cancel") %></a>
                    <button class="spx-btn spx-btn-primary" type="submit" name="spAction" value="save"
                            data-ui-action="save" data-ui-validation="none"
                            data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 4h11l3 3v13H5z"/><path d="M8 4v5h7V4M8 20v-6h8v6"/></svg>
                        <%: L.T("Student.Profile.SaveChanges") %>
                    </button>
                </span>
            </div>
        </section>

        <!-- Read-only information -->
        <div class="spx-side">
            <section class="spx-card" aria-labelledby="spxAcademicTitle">
                <div class="spx-card-head">
                    <div>
                        <h3 id="spxAcademicTitle"><%: L.T("Student.Profile.AcademicInformation") %></h3>
                    </div>
                    <span class="spx-badge">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" aria-hidden="true"><rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/></svg>
                        <%: L.T("Student.Profile.ReadOnly") %>
                    </span>
                </div>
                <div class="spx-note"><%: L.T("Student.Profile.AcademicDetailsAreManagedByThe") %></div>
                <dl class="spx-list">
                    <div><dt><%: L.T("Student.Profile.StudentID") %></dt><dd><%: StudentNumber %></dd></div>
                    <div><dt><%: L.T("Student.Profile.University") %></dt><dd><%: StudentUniversity %></dd></div>
                    <div><dt><%: L.T("Student.Profile.College") %></dt><dd><%: StudentCollege %></dd></div>
                    <div><dt><%: L.T("Student.Profile.MajorSpecialization") %></dt><dd><%: StudentMajor %></dd></div>
                    <div><dt><%: L.T("Student.Profile.RequiredTrainingHours") %></dt><dd><%: RequiredHoursText %></dd></div>
                    <div><dt><%: L.T("Student.Profile.ApprovedTrainingHours") %></dt><dd><%: ApprovedHoursText %></dd></div>
                </dl>
            </section>

            <section class="spx-card" aria-labelledby="spxDocsTitle">
                <div class="spx-card-head">
                    <div>
                        <h3 id="spxDocsTitle"><%: L.T("Student.Profile.CVProfessionalPortfolio") %></h3>
                        <p><%: L.T("Student.Profile.ManageYourProfessionalDocumentsAndOnline") %></p>
                    </div>
                </div>
                <div class="spx-doc">
                    <span class="spx-doc-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M6 3h8l4 4v14H6zM14 3v5h4M9 13h6M9 17h6"/></svg></span>
                    <div>
                        <strong><%: L.T("Student.Profile.CurriculumVitaeCV") %></strong>
                        <% if (HasCvFile) { %><a href="<%: CvDownloadUrl %>"><%: L.T("Student.Profile.DownloadCurrentCV") %></a>
                        <% } else { %><span><%: L.T("Student.Profile.NoUploadedCVAvailable") %></span><% } %>
                    </div>
                </div>
                <div class="spx-doc">
                    <span class="spx-doc-icon"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="7" width="18" height="13" rx="2"/><path d="M8 7V4h8v3"/></svg></span>
                    <div>
                        <strong><%: L.T("Student.Profile.ProjectPortfolio") %></strong>
                        <% if (HasPortfolioFile) { %><a href="<%: PortfolioDownloadUrl %>"><%: L.T("Student.Profile.DownloadCurrentPortfolio") %></a>
                        <% } else { %><span><%: L.T("Student.Profile.NoUploadedPortfolioAvailable") %></span><% } %>
                    </div>
                </div>
                <div class="spx-side-foot">
                    <a class="spx-btn spx-btn-ghost" href="<%: ResolveUrl("~/Pages/Student/StudentCVPortfolio.aspx") %>"><%: L.T("Student.Profile.ManageCVPortfolio") %></a>
                </div>
            </section>
        </div>
    </div>
    <% } %>
</div>

<% if (JustSaved) { %>
<div class="spx-toast" id="spxToast" role="status" aria-live="polite">
    <svg class="spx-check" viewBox="0 0 44 44" aria-hidden="true"><circle cx="22" cy="22" r="20"/><path d="M13 22.5l6 6 12-13"/></svg>
    <span>
        <strong><%: L.T("Student.Profile.Saved") %></strong>
        <small><%: L.T("Student.Profile.YourProfileHasBeenUpdatedSuccessfully") %></small>
    </span>
    <button type="button" class="spx-toast-close" id="spxToastClose" aria-label="<%: L.T("Student.Profile.Close") %>">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" aria-hidden="true"><path d="m6 6 12 12M18 6 6 18"/></svg>
    </button>
    <span class="spx-toast-timer" aria-hidden="true"></span>
</div>
<% } %>

<script type="text/javascript">
(function () {
    var form = document.getElementById("spxForm");
    if (!form) return;
    var bar = document.getElementById("spxSaveBar");
    var status = document.getElementById("spxStatusText");
    var discard = document.getElementById("spxDiscard");
    var fields = form.querySelectorAll("input:not([type=file]), textarea");
    var photo = document.getElementById("spPhoto");
    var start = {};

    Array.prototype.forEach.call(fields, function (f) { start[f.id] = f.value; });

    function refresh() {
        var dirty = (photo.files && photo.files.length > 0) ||
            Array.prototype.some.call(fields, function (f) { return f.value !== start[f.id]; });
        <% if (NoticeIsError) { %>dirty = true;<% } %>
        bar.classList.toggle("spx-dirty", dirty);
        status.textContent = dirty ? status.getAttribute("data-dirty") : status.getAttribute("data-clean");
        discard.hidden = !dirty;
    }
    form.addEventListener("input", refresh);

    // Photo preview before saving.
    photo.addEventListener("change", function () {
        var file = photo.files && photo.files[0];
        if (!file) { refresh(); return; }
        document.getElementById("spxPhotoName").textContent = file.name;
        var avatar = document.getElementById("spxAvatar");
        var img = avatar.querySelector("img");
        if (!img) {
            img = document.createElement("img");
            img.alt = "";
            var initials = document.getElementById("spxInitials");
            if (initials) initials.remove();
            avatar.insertBefore(img, avatar.firstChild);
        }
        img.src = URL.createObjectURL(file);
        refresh();
    });

    // Warn before leaving with unsaved edits (not when saving).
    var saving = false;
    form.querySelector("button[name=spAction]").addEventListener("click", function () { saving = true; });
    window.addEventListener("beforeunload", function (e) {
        if (!saving && bar.classList.contains("spx-dirty")) { e.preventDefault(); e.returnValue = ""; }
    });
    discard.addEventListener("click", function () { saving = true; });

    refresh();

    // "Saved" toast: drop ?saved=1 so a refresh does not show it again, then fade it out.
    var toast = document.getElementById("spxToast");
    if (toast) {
        try { history.replaceState(null, "", location.pathname); } catch (e) {}
        var hide = function () {
            if (!toast.parentNode) return;
            toast.classList.add("spx-leaving");
            setTimeout(function () { if (toast.parentNode) toast.parentNode.removeChild(toast); }, 350);
        };
        document.getElementById("spxToastClose").addEventListener("click", hide);
        setTimeout(hide, 4500);
    }
})();
</script>
</asp:Content>
