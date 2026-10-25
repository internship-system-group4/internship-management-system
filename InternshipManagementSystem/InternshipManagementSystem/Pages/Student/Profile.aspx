
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Profile"
    Title="My Profile" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css" />

<style>

.sp-page {
    --sp-primary: var(--ui-primary, #173a60);
    --sp-ink: var(--ui-primary-text, #173a60);
    --sp-border: var(--th-line-e3e8ee, #e3e8ee);

    width: 100%;
    max-width: 1400px;
    margin: 0 auto;
    padding: 10px 24px 40px;

    box-sizing: border-box;
    color: var(--th-fg-1d2733, #1d2733);
}


.sp-page * { box-sizing: border-box; }

.sp-heading {
    margin-bottom: 22px;
    padding-bottom: 15px;
    border-bottom: 1px solid var(--sp-border);
}

.sp-heading h2 {
    font-size: 27px;
    font-weight: 800;
    color: var(--sp-ink);
    margin: 0 0 5px;
}

.sp-heading p {
    font-size: 13px;
    color: var(--ui-muted);
    margin: 0;
}

.sp-card {
    background: var(--ui-surface,#fff);
    border-radius: 20px;
    overflow: hidden;
    box-shadow: 0 4px 20px rgba(0,0,0,.05);
    border: 1px solid var(--sp-border);
    margin-bottom: 20px;
}

.sp-cover {
    height: 150px;
    background: linear-gradient(
        135deg,
        var(--sp-primary),
        var(--th-bg-2b4560,#2b4560)
    );
    position: relative;
}

.sp-edit-button {
    position: absolute;
    top: 17px;
    right: 18px;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    background: var(--ui-surface,#fff);
    border: 1px solid var(--sp-primary);
    border-radius: 999px;
    padding: 9px 18px;
    color: var(--sp-ink);
    font-weight: 700;
    font-size: 13px;
    cursor: pointer;
}

.sp-edit-button:hover {
    background: var(--th-bg-f0f4f8,#f0f4f8);
}

.sp-avatar-holder {
    position: relative;
    margin-top: -70px;
    text-align: center;
}

.sp-avatar {
    height: 140px;
    width: 140px;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    overflow: hidden;
    border: 5px solid var(--th-line-ffffff,#fff);
    border-radius: 50%;
    background: var(--th-bg-e8f0f7,#e8f0f7);
    color: var(--sp-ink);
    font-size: 38px;
    font-weight: 800;
    box-shadow: 0 4px 15px rgba(0,0,0,.1);
}

.sp-avatar img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}

.sp-person {
    text-align: center;
    padding: 14px 20px 28px;
}

.sp-person h3 {
    font-size: 23px;
    color: var(--sp-ink);
    margin: 0 0 7px;
    font-weight: 800;
}

.sp-person p {
    font-size: 13px;
    color: var(--ui-muted);
    margin: 0 0 12px;
}

.sp-role {
    display: inline-block;
    background: var(--th-bg-e8f0f7,#e8f0f7);
    color: var(--sp-ink);
    padding: 7px 17px;
    border-radius: 999px;
    font-size: 12px;
    font-weight: 750;
}

.sp-sections {
    display: grid;
    gap: 13px;
}

.sp-section {
    border: 1px solid var(--sp-border);
    border-radius: 14px;
    background: var(--ui-surface,#fff);
    overflow: hidden;
    box-shadow: 0 2px 10px rgba(0,0,0,.025);
}

.sp-section-toggle {
    width: 100%;
    display: flex;
    justify-content: space-between;
    align-items: center;
    gap: 12px;
    background: transparent;
    border: 0;
    padding: 18px 21px;
    text-align: start;
    cursor: pointer;
    color: inherit;
}

.sp-section-toggle:hover {
    background: var(--th-bg-f8fafc,#f8fafc);
}

.sp-section-toggle:focus-visible {
    outline: 3px solid var(--th-line-7aa6cf,#7aa6cf);
    outline-offset: -3px;
}

.sp-section-title {
    display: flex;
    align-items: center;
    gap: 13px;
}

.sp-section-title strong {
    display: block;
    font-size: 15px;
    color: var(--sp-ink);
}

.sp-section-title small {
    display: block;
    font-size: 11px;
    color: var(--ui-muted);
    margin-top: 4px;
}

.sp-section-icon {
    display: grid;
    place-items: center;
    flex-shrink: 0;
    width: 40px;
    height: 40px;
    border-radius: 11px;
    background: var(--th-bg-e8f0f7,#e8f0f7);
    color: var(--sp-ink);
    font-size: 18px;
}

.sp-section-right {
    display: flex;
    align-items: center;
    gap: 12px;
}

.sp-chevron {
    transition: transform .2s;
    color: var(--ui-muted);
}

.sp-open .sp-chevron {
    transform: rotate(180deg);
}

.sp-section-body {
    padding: 21px;
    border-top: 1px solid var(--sp-border);
}

.sp-section-body[hidden] {
    display: none !important;
}

.sp-info-grid {
    display: grid;
    grid-template-columns: repeat(2,minmax(0,1fr));
    gap: 14px;
}

.sp-info-grid .sp-field {
    min-width: 0;
    background: var(--th-bg-f8fafc,#f8fafc);
    border: 1px solid var(--sp-border);
    border-radius: 12px;
    padding: 15px 17px;
}

.sp-info-grid .sp-field-wide {
    grid-column: 1 / -1;
}

.sp-info-grid .sp-field label {
    display: block;
    font-size: 11px;
    font-weight: 750;
    color: var(--ui-muted);
    margin-bottom: 7px;
}

.sp-view-value {
    font-size: 14px;
    font-weight: 650;
    color: var(--th-fg-1d2733,#1d2733);
    overflow-wrap: anywhere;
    min-height: 20px;
}

.sp-view-multiline {
    white-space: pre-wrap;
    line-height: 1.6;
}

.sp-info-grid .sp-input[readonly] {
    border: 0;
    background: transparent;
    padding: 0;
    width: 100%;
    font-size: 14px;
    font-weight: 650;
    color: var(--th-fg-1d2733,#1d2733);
    outline: none;
}

.sp-help {
    font-size: 11px;
    color: var(--ui-muted);
    display: block;
    margin-top: 7px;
}

.sp-note {
    background: var(--th-bg-f0f6fc,#f0f6fc);
    border-radius: 10px;
    padding: 12px 14px;
    font-size: 12px;
    color: var(--th-fg-54728d,#54728d);
    margin-bottom: 15px;
}

.sp-file-row strong {
    font-size: 13px;
    display: block;
    margin-bottom: 6px;
}

.sp-file-row p {
    font-size: 12px;
    color: var(--ui-muted);
    margin: 0 0 7px;
}

.sp-file-link {
    font-size: 12px;
    color: var(--sp-ink);
    font-weight: 700;
}

.sp-readonly-badge {
    font-size: 10px;
    font-weight: 700;
    color: var(--ui-muted);
    background: var(--th-bg-f0f4f8,#f0f4f8);
    padding: 6px 9px;
    border-radius: 20px;
}

.sp-actions {
    margin-top: 16px;
    text-align: right;
}

.sp-btn {
    display: inline-block;
    border: 0;
    border-radius: 999px;
    padding: 10px 20px;
    background: var(--sp-primary);
    color: white !important;
    text-decoration: none !important;
    font-size: 13px;
    font-weight: 700;
    cursor: pointer;
}

.sp-btn-light {
    background: var(--th-bg-e8f0f7,#e8f0f7);
    color: var(--sp-ink) !important;
}

.sp-alert {
    padding: 13px 16px;
    border-radius: 10px;
    margin-bottom: 16px;
    font-size: 13px;
}

.sp-error {
    background: var(--th-bg-fff1ef,#fff1ef);
    color: var(--th-fg-a53e36,#a53e36);
    border: 1px solid var(--th-line-f1cdc8,#f1cdc8);
}

.sp-success {
    background: var(--th-bg-e9f8ef,#e9f8ef);
    color: var(--th-fg-226a44,#226a44);
    border: 1px solid var(--th-line-c5e8d2,#c5e8d2);
}

/* Edit Profile Modal */

.sp-modal {
    position: fixed;
    inset: 0;
    z-index: 1055;
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 18px;
    background: rgba(12,30,49,.57);
}

.sp-modal[hidden] {
    display: none !important;
}

.sp-modal-dialog {
    width: 100%;
    max-width: 550px;
    max-height: 90vh;
    overflow-y: auto;
    background: var(--ui-surface,#fff);
    border-radius: 18px;
    box-shadow: 0 20px 70px rgba(0,0,0,.22);
}

.sp-modal-head {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 22px 25px 10px;
}

.sp-modal-head h3 {
    font-size: 19px;
    font-weight: 800;
    color: var(--sp-ink);
    margin: 0;
}

.sp-modal-close {
    border: 0;
    background: transparent;
    font-size: 25px;
    color: var(--ui-muted);
    cursor: pointer;
}

.sp-modal-body {
    padding: 12px 25px 20px;
}

.sp-modal-body .sp-field {
    margin-bottom: 16px;
}

.sp-modal-body .sp-field label {
    display: block;
    font-size: 12px;
    font-weight: 700;
    margin-bottom: 7px;
}

.sp-modal-body .sp-input {
    display: block;
    width: 100%;
    border: 1px solid var(--sp-border);
    border-radius: 9px;
    padding: 11px 13px;
    font: inherit;
    font-size: 13px;
    background: var(--th-bg-f8fafc,#f8fafc);
    color: var(--th-fg-1d2733,#1d2733);
}

.sp-modal-body textarea.sp-input {
    min-height: 80px;
    resize: vertical;
}

.sp-modal-foot {
    display: flex;
    justify-content: flex-end;
    gap: 10px;
    padding: 0 25px 25px;
}

.sp-photo-picker {
    border: 1px dashed var(--sp-primary);
    border-radius: 12px;
    padding: 13px;
    margin-bottom: 18px;
    text-align: center;
    background: var(--th-bg-f8fafc,#f8fafc);
}

.sp-photo-picker input {
    max-width: 100%;
    font-size: 12px;
}

@media(max-width:700px) {
    .sp-page { padding: 0 10px 28px; }
    .sp-info-grid { grid-template-columns: 1fr; }
    .sp-info-grid .sp-field-wide { grid-column: auto; }
    .sp-cover { height: 125px; }
    .sp-avatar-holder { margin-top: -60px; }
    .sp-avatar { width: 120px; height: 120px; }
    .sp-section-toggle { padding: 15px; }
    .sp-section-body { padding: 14px; }
    .sp-modal-body { padding: 12px 17px; }
    .sp-modal-head { padding: 19px 17px 9px; }
    .sp-modal-foot { padding: 0 17px 20px; }
}

/* ==========================================
   STUDENT PROFILE - RESPONSIVE PAGE SPACING
   ========================================== */

/* Large desktop screens */
@media (min-width: 1600px) {
    .sp-page {
        max-width: 1450px;
        padding-left: 32px;
        padding-right: 32px;
    }
}

/* Standard desktop and laptop */
@media (min-width: 1024px) and (max-width: 1599px) {
    .sp-page {
        max-width: 1400px;
        padding-left: 24px;
        padding-right: 24px;
    }
}

/* Tablets */
@media (min-width: 701px) and (max-width: 1023px) {
    .sp-page {
        max-width: 100%;
        padding-left: 18px;
        padding-right: 18px;
    }
}

/* Mobile */
@media (max-width: 700px) {
    .sp-page {
        width: 100%;
        max-width: 100%;
        padding: 0 10px 28px;
    }
}

</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="sp-page" id="studentProfilePage">

    <div class="sp-heading">
        <h2><%: L.T("Student.Profile.MyStudentProfile") %></h2>
        <p><%: L.T("Student.Profile.ManageYourPersonalDetailsAcademicInformation") %></p>
    </div>

    <% if (!string.IsNullOrWhiteSpace(Notice)) { %>
        <div class='sp-alert <%= NoticeIsError ? "sp-error" : "sp-success" %>'
             role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <!-- Profile Card -->
    <div class="sp-card">

        <div class="sp-cover">
            <button type="button" class="sp-edit-button" id="spOpenEdit">
                <i class="bi bi-pencil-square" aria-hidden="true"></i>
                <%: L.T("Student.Profile.EditProfile") %>
            </button>
        </div>

        <div class="sp-avatar-holder">
            <div class="sp-avatar">
                <% if (HasPhoto) { %>
                    <img src="<%: PhotoUrl %>"
                         alt="<%: L.T("Student.Profile.StudentProfilePhoto") %>" />
                <% } else { %>
                    <%: Initials %>
                <% } %>
            </div>
        </div>

        <div class="sp-person">
            <h3><%: StudentName %></h3>
            <p>
                <%: StudentMajor %> ·
                <%: L.T("Student.Profile.GermanJordanianUniversity") %>
            </p>
            <span class="sp-role">
                <i class="bi bi-mortarboard" aria-hidden="true"></i>
                <%: L.T("Student.Profile.Student") %>
            </span>
        </div>

    </div>

    <!-- Accordion Sections -->
    <div class="sp-sections">

        <!-- Personal Information -->
        <section class="sp-section sp-open">

            <button type="button"
                    class="sp-section-toggle"
                    aria-expanded="true">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-person" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.PersonalInformation") %></strong>
                        <small><%: L.T("Student.Profile.UpdateYourPersonalAndContactInformation") %></small>
                    </span>
                </span>

                <span class="sp-section-right">
                    <i class="bi bi-chevron-down sp-chevron" aria-hidden="true"></i>
                </span>
            </button>

            <div class="sp-section-body">
                <div class="sp-info-grid">

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.FullName") %></label>
                        <div class="sp-view-value">
                            <%: FormValue("spName", StudentName) %>
                        </div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.Age") %></label>
                        <div class="sp-view-value">
                            <%: FormValue("spAge", AgeText) %>
                        </div>
                    </div>

                    <div class="sp-field">
                        <label for="spAccountEmail"><%: L.T("Student.Profile.UniversityAccountEmail") %></label>
                        <input id="spAccountEmail" class="sp-input"
                               type="email"
                               value="<%: StudentEmail %>"
                               readonly />
                        <span class="sp-help">
                            <%: L.T("Student.Profile.ManagedByYourUniversityAccount") %>
                        </span>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.PhoneNumber") %></label>
                        <div class="sp-view-value">
                            <%: FormValue("spPhone", StudentPhone) %>
                        </div>
                    </div>

                </div>
            </div>
        </section>

        <!-- Academic Information -->
        <section class="sp-section">

            <button type="button"
                    class="sp-section-toggle"
                    aria-expanded="false">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-mortarboard" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.AcademicInformation") %></strong>
                        <small><%: L.T("Student.Profile.YourOfficialUniversityAndTrainingDetails") %></small>
                    </span>
                </span>

                <span class="sp-section-right">
                    <span class="sp-readonly-badge">
                        <%: L.T("Student.Profile.ReadOnly") %>
                    </span>
                    <i class="bi bi-chevron-down sp-chevron" aria-hidden="true"></i>
                </span>
            </button>

            <div class="sp-section-body" hidden>

                <div class="sp-note">
                    <%: L.T("Student.Profile.AcademicDetailsAreManagedByThe") %>
                </div>

                <div class="sp-info-grid">

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.StudentID") %></label>
                        <input class="sp-input" type="text"
                               value="<%: StudentNumber %>" readonly />
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.University") %></label>
                        <input class="sp-input" type="text"
                               value="<%: StudentUniversity %>" readonly />
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.College") %></label>
                        <input class="sp-input" type="text"
                               value="<%: StudentCollege %>" readonly />
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.MajorSpecialization") %></label>
                        <input class="sp-input" type="text"
                               value="<%: StudentMajor %>" readonly />
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.RequiredTrainingHours") %></label>
                        <input class="sp-input" type="text"
                               value="<%: RequiredHoursText %>" readonly />
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.ApprovedTrainingHours") %></label>
                        <input class="sp-input" type="text"
                               value="<%: ApprovedHoursText %>" readonly />
                    </div>

                </div>
            </div>
        </section>

        <!-- Skills -->
        <section class="sp-section">

            <button type="button"
                    class="sp-section-toggle"
                    aria-expanded="false">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-code-slash" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.SkillsCompetencies") %></strong>
                        <small><%: L.T("Student.Profile.HighlightTheSkillsYouCanOffer") %></small>
                    </span>
                </span>

                <span class="sp-section-right">
                    <i class="bi bi-chevron-down sp-chevron" aria-hidden="true"></i>
                </span>
            </button>

            <div class="sp-section-body" hidden>
                <div class="sp-info-grid">

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.TechnicalSkills") %></label>
                        <div class="sp-view-value sp-view-multiline"><%: FormValue("spTechnical", TechnicalSkills) %></div>
                        <span class="sp-help">
                            <%: L.T("Student.Profile.ProgrammingLanguagesFrameworksToolsAndTechnologies") %>
                        </span>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.SoftSkills") %></label>
                        <div class="sp-view-value sp-view-multiline"><%: FormValue("spSoft", SoftSkills) %></div>
                        <span class="sp-help">
                            <%: L.T("Student.Profile.CommunicationLeadershipProblemSolvingAndTeamwork") %>
                        </span>
                    </div>

                </div>
            </div>
        </section>

        <!-- CV & Portfolio -->
        <section class="sp-section">

            <button type="button"
                    class="sp-section-toggle"
                    aria-expanded="false">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-file-earmark-text" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.CVProfessionalPortfolio") %></strong>
                        <small><%: L.T("Student.Profile.ManageYourProfessionalDocumentsAndOnline") %></small>
                    </span>
                </span>

                <span class="sp-section-right">
                    <i class="bi bi-chevron-down sp-chevron" aria-hidden="true"></i>
                </span>
            </button>

            <div class="sp-section-body" hidden>

                <div class="sp-note">
                    <%: L.T("Student.Profile.KeepYourCVAndPortfolioUp") %>
                </div>

                <div class="sp-info-grid">

                    <div class="sp-field">
                        <div class="sp-file-row">
                            <strong>
                                <%: L.T("Student.Profile.CurriculumVitaeCV") %>
                            </strong>

                            <p>
                                <%: L.T("Student.Profile.UploadYourLatestCVReplaceAn") %>
                            </p>

                            <% if (HasCvFile) { %>
                                <a class="sp-file-link"
                                   href="<%: CvDownloadUrl %>">
                                    <%: L.T("Student.Profile.DownloadCurrentCV") %>
                                </a>
                            <% } else { %>
                                <span class="sp-help">
                                    <%: L.T("Student.Profile.NoUploadedCVAvailable") %>
                                </span>
                            <% } %>
                        </div>
                    </div>

                    <div class="sp-field">
                        <div class="sp-file-row">
                            <strong>
                                <%: L.T("Student.Profile.ProjectPortfolio") %>
                            </strong>

                            <p>
                                <%: L.T("Student.Profile.ShowcaseYourAcademicProjectsPracticalWork") %>
                            </p>

                            <% if (HasPortfolioFile) { %>
                                <a class="sp-file-link"
                                   href="<%: PortfolioDownloadUrl %>">
                                    <%: L.T("Student.Profile.DownloadCurrentPortfolio") %>
                                </a>
                            <% } else { %>
                                <span class="sp-help">
                                    <%: L.T("Student.Profile.NoUploadedPortfolioAvailable") %>
                                </span>
                            <% } %>
                        </div>
                    </div>

                    <div class="sp-field sp-field-wide">
                        <label><%: L.T("Student.Profile.LinkedInProfile") %></label>
                        <div class="sp-view-value">
                            <%: FormValue("spLinkedIn", LinkedInUrl) %>
                        </div>
                    </div>

                </div>

                <div class="sp-actions">
                    <a class="sp-btn sp-btn-light"
                       href="<%: ResolveUrl("~/Pages/Student/StudentCVPortfolio.aspx") %>">
                        <%: L.T("Student.Profile.ManageCVPortfolio") %>
                    </a>
                </div>

            </div>
        </section>

    </div>
</div>

<!-- Edit Profile Popup -->
<div class="sp-modal"
     id="spEditModal"
     role="dialog"
     aria-modal="true"
     aria-labelledby="spEditTitle"
     hidden>

    <div class="sp-modal-dialog"
         tabindex="-1"
         id="spModalDialog">

        <div class="sp-modal-head">
            <h3 id="spEditTitle"><%: L.T("Student.Profile.EditProfile") %></h3>
            <button type="button"
                    class="sp-modal-close"
                    id="spCloseEdit"
                    aria-label="<%: L.T("Student.Profile.Close") %>">
                &times;
            </button>
        </div>

        <div class="sp-modal-body">

            <!-- Profile Photo -->
            <div class="sp-photo-picker">
                <label for="spPhoto">
                    <strong>
                        <i class="bi bi-camera"></i>
                        <%: L.T("Student.Profile.ChooseProfilePhoto") %>
                    </strong>
                </label>

                <div>
                    <input type="file"
                           id="spPhoto"
                           name="spPhoto"
                           accept=".jpg,.jpeg,.png" />
                </div>

                <span class="sp-help">
                    <%: L.T("Student.Profile.JPGOrPNGMaximum2MB") %>
                </span>
            </div>

            <!-- Full Name -->
            <div class="sp-field">
                <label for="spName">
                    <%: L.T("Student.Profile.FullName") %>
                </label>

                <input class="sp-input"
                       id="spName"
                       name="spName"
                       type="text"
                       maxlength="120"
                       required
                       value="<%: FormValue("spName", StudentName) %>" />
            </div>

            <!-- Age -->
            <div class="sp-field">
                <label for="spAge">
                    <%: L.T("Student.Profile.Age") %>
                </label>

                <input class="sp-input"
                       id="spAge"
                       name="spAge"
                       type="number"
                       min="16"
                       max="100"
                       value="<%: FormValue("spAge", AgeText) %>" />
            </div>

            <!-- Phone -->
            <div class="sp-field">
                <label for="spPhone">
                    <%: L.T("Student.Profile.PhoneNumber") %>
                </label>

                <input class="sp-input"
                       id="spPhone"
                       name="spPhone"
                       type="tel"
                       maxlength="25"
                       placeholder="<%: L.T("Student.Profile.9627XXXXXXXX") %>"
                       value="<%: FormValue("spPhone", StudentPhone) %>" />
            </div>

            <!-- Technical Skills -->
            <div class="sp-field">
                <label for="spTechnical">
                    <%: L.T("Student.Profile.TechnicalSkills") %>
                </label>

                <textarea class="sp-input"
                          id="spTechnical"
                          name="spTechnical"
                          maxlength="1500"
                          placeholder="<%: L.T("Student.Profile.ExampleCASPNETHTMLCSS") %>"><%: FormValue("spTechnical", TechnicalSkills) %></textarea>
            </div>

            <!-- Soft Skills -->
            <div class="sp-field">
                <label for="spSoft">
                    <%: L.T("Student.Profile.SoftSkills") %>
                </label>

                <textarea class="sp-input"
                          id="spSoft"
                          name="spSoft"
                          maxlength="1500"
                          placeholder="<%: L.T("Student.Profile.ExampleTeamworkCommunicationTimeManagement") %>"><%: FormValue("spSoft", SoftSkills) %></textarea>
            </div>

            <!-- LinkedIn -->
            <div class="sp-field">
                <label for="spLinkedIn">
                    <%: L.T("Student.Profile.LinkedInProfile") %>
                </label>

                <input class="sp-input"
                       id="spLinkedIn"
                       name="spLinkedIn"
                       type="url"
                       maxlength="500"
                       placeholder="https://www.linkedin.com/in/..."
                       value="<%: FormValue("spLinkedIn", LinkedInUrl) %>" />
            </div>

        </div>

        <div class="sp-modal-foot">

            <button type="button"
                    class="sp-btn sp-btn-light"
                    id="spCancelEdit">
                <%: L.T("Student.Profile.Cancel") %>
            </button>

            <button class="sp-btn"
                    type="submit"
                    name="spAction"
                    value="save"
                    data-ui-action="save"
                    data-ui-validation="none"
                    data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                <%: L.T("Student.Profile.UpdateProfile") %>
            </button>

        </div>

    </div>
</div>

<script type="text/javascript">
(function () {

    var modal = document.getElementById("spEditModal");
    var dialog = document.getElementById("spModalDialog");
    var openButton = document.getElementById("spOpenEdit");
    var closeButton = document.getElementById("spCloseEdit");
    var cancelButton = document.getElementById("spCancelEdit");
    var previousFocus = null;

    function openModal() {
        previousFocus = document.activeElement;
        modal.hidden = false;
        document.body.style.overflow = "hidden";
        dialog.focus();
    }

    function closeModal() {
        modal.hidden = true;
        document.body.style.overflow = "";

        if (previousFocus && previousFocus.focus) {
            previousFocus.focus();
        }
    }

    openButton.addEventListener("click", openModal);
    closeButton.addEventListener("click", closeModal);

    cancelButton.addEventListener("click", function () {
        window.location.href = window.location.pathname;
    });

    modal.addEventListener("click", function (event) {
        if (event.target === modal) {
            closeModal();
        }
    });

    document.addEventListener("keydown", function (event) {

        if (modal.hidden) return;

        if (event.key === "Escape") {
            closeModal();
            return;
        }

        if (event.key === "Tab") {

            var controls = Array.prototype.slice.call(
                modal.querySelectorAll(
                    "button,input,textarea,select,a[href]"
                )
            ).filter(function (element) {
                return !element.disabled &&
                       element.offsetParent !== null;
            });

            if (!controls.length) return;

            var first = controls[0];
            var last = controls[controls.length - 1];

            if (event.shiftKey &&
                document.activeElement === first) {

                event.preventDefault();
                last.focus();

            } else if (!event.shiftKey &&
                       document.activeElement === last) {

                event.preventDefault();
                first.focus();
            }
        }
    });

    // Accordion - one section open at a time
    document.querySelectorAll(".sp-section").forEach(function (section) {

        var button = section.querySelector(".sp-section-toggle");
        var panel = section.querySelector(".sp-section-body");

        button.addEventListener("click", function () {

            var opening = !section.classList.contains("sp-open");

            document.querySelectorAll(".sp-section").forEach(function (other) {

                other.classList.remove("sp-open");

                other.querySelector(".sp-section-toggle")
                     .setAttribute("aria-expanded", "false");

                other.querySelector(".sp-section-body").hidden = true;
            });

            if (opening) {
                section.classList.add("sp-open");
                button.setAttribute("aria-expanded", "true");
                panel.hidden = false;
            }
        });
    });

    <% if (NoticeIsError) { %>
        openModal();
    <% } %>

})();
</script>

</asp:Content>
