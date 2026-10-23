
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Profile"
    Title="My Profile" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.sp-page {
    --sp-navy:var(--ui-primary);
    --sp-blue:#28547d;
    --sp-muted:var(--th-fg-72839a,#72839a);
    --sp-line:var(--th-line-e1e9f2,#e1e9f2);
    max-width:1150px;
    margin:0 auto;
    padding-bottom:35px;
    color:var(--th-fg-213d59,#213d59);
}
.sp-page * {box-sizing:border-box}
.sp-title {margin-bottom:22px}
.sp-title h2 {
    font-size:27px;
    font-weight:800;
    color:var(--ui-primary-text,var(--sp-navy));
    margin:0 0 7px;
}
.sp-title p {color:var(--sp-muted);font-size:13px;margin:0}

.sp-cover {
    height:115px;
    border-radius:15px 15px 0 0;
    background:linear-gradient(110deg,var(--th-bg-173a60,#173a60),#3678a9);
    position:relative;
    overflow:hidden;
}
.sp-cover:after {
    content:"";
    position:absolute;
    width:210px;height:210px;
    border:35px solid rgba(255,255,255,.08);
    border-radius:50%;
    inset-inline-end:-50px;top:-110px;
}
.sp-profile-header {
    background:var(--ui-surface,#fff);
    border:1px solid var(--sp-line);
    border-top:0;
    border-radius:0 0 15px 15px;
    padding:0 25px 23px;
    margin-bottom:20px;
}
.sp-identity {
    display:flex;
    align-items:flex-end;
    gap:17px;
    flex-wrap:wrap;
    margin-top:-39px;
    position:relative;
}
.sp-avatar {
    width:91px;height:91px;
    border-radius:50%;
    border:5px solid var(--th-line-ffffff,#fff);
    background:var(--th-bg-eaf2fb,#eaf2fb);
    display:flex;
    align-items:center;
    justify-content:center;
    color:var(--th-fg-28547d,#28547d);
    font-size:31px;
    font-weight:800;
    overflow:hidden;
    flex-shrink:0;
}
.sp-avatar img {width:100%;height:100%;object-fit:cover}
.sp-identity-info {padding-bottom:5px}
.sp-identity-info h3 {
    font-size:20px;
    color:var(--ui-primary-text,var(--sp-navy));
    margin:0 0 6px;
    font-weight:800;
}
.sp-identity-info p {margin:0;color:var(--sp-muted);font-size:12px}
.sp-photo-upload {
    margin-top:17px;
    display:flex;
    flex-wrap:wrap;
    align-items:center;
    gap:10px;
}
.sp-help {font-size:11px;color:var(--sp-muted);line-height:1.6}

.sp-panel {
    background:var(--ui-surface,#fff);
    border:1px solid var(--sp-line);
    border-radius:13px;
    padding:23px;
    margin-bottom:19px;
}
.sp-panel-header {
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:12px;
    margin-bottom:21px;
    padding-bottom:15px;
    border-bottom:1px solid var(--th-line-edf1f6,#edf1f6);
}
.sp-panel-title {
    display:flex;
    align-items:center;
    gap:11px;
}
.sp-section-icon {
    width:37px;height:37px;
    border-radius:10px;
    display:grid;
    place-items:center;
    background:var(--th-bg-eaf2fb,#eaf2fb);
    color:var(--ui-primary-text,var(--sp-blue));
    font-size:17px;
    font-weight:800;
}
.sp-panel h3 {
    color:var(--ui-primary-text,var(--sp-navy));
    font-size:16px;
    font-weight:800;
    margin:0 0 4px;
}
.sp-panel-header p {
    font-size:11px;
    color:var(--sp-muted);
    margin:0;
}
.sp-readonly-badge {
    background:var(--ui-neutral-soft,#f0f3f7);
    color:var(--th-fg-69798d,#69798d);
    border-radius:25px;
    padding:7px 11px;
    font-size:10px;
    font-weight:800;
    white-space:nowrap;
}
.sp-fields {
    display:grid;
    grid-template-columns:repeat(2,minmax(0,1fr));
    gap:17px;
}
.sp-field {min-width:0}
.sp-field-wide {grid-column:1/-1}
.sp-field label {
    display:block;
    color:var(--th-fg-355572,#355572);
    font-size:12px;
    font-weight:750;
    margin-bottom:8px;
}
.sp-input {
    width:100%;
    min-height:43px;
    border:1px solid var(--th-line-d8e3ee,#d8e3ee);
    border-radius:9px;
    padding:11px 13px;
    background:var(--th-bg-fbfdff,#fbfdff);
    color:var(--th-fg-244562,#244562);
    font:inherit;
    font-size:13px;
    outline:none;
}
.sp-input:focus {
    border-color:var(--th-line-5d94c2,#5d94c2);
    box-shadow:0 0 0 3px rgba(45,103,157,.10);
}
.sp-input[readonly] {
    background:var(--th-bg-f3f6fa,#f3f6fa);
    color:var(--th-fg-77889a,#77889a);
    cursor:not-allowed;
}
textarea.sp-input {min-height:105px;resize:vertical}
input[type=file].sp-input {padding:9px}
.sp-file-row {
    padding:16px;
    border:1px dashed var(--th-line-c8d9e9,#c8d9e9);
    border-radius:11px;
    background:var(--th-bg-f9fbfe,#f9fbfe);
}
.sp-file-row strong {
    display:block;
    font-size:12px;
    color:var(--th-fg-2a4b6a,#2a4b6a);
    margin-bottom:7px;
}
.sp-file-row p {
    color:var(--sp-muted);
    font-size:11px;
    margin:0 0 11px;
    line-height:1.7;
}
.sp-file-link {
    display:inline-block;
    color:var(--th-fg-286391,#286391);
    font-size:12px;
    font-weight:800;
    margin-top:9px;
    text-decoration:none;
}
.sp-file-link:hover {text-decoration:underline}
.sp-actions {
    display:flex;
    align-items:center;
    justify-content:flex-end;
    flex-wrap:wrap;
    gap:11px;
    margin-top:22px;
}
.sp-btn {
    display:inline-flex;
    align-items:center;
    justify-content:center;
    border:0;
    border-radius:9px;
    padding:12px 22px;
    background:var(--sp-navy);
    color:#fff!important;
    font-size:13px;
    font-weight:800;
    text-decoration:none!important;
    cursor:pointer;
}
.sp-btn:hover {background:var(--th-bg-102e4d,#102e4d)}
.sp-btn-light {
    background:var(--th-bg-eaf1f9,#eaf1f9);
    color:var(--ui-primary-text,var(--sp-navy))!important;
}
.sp-btn-light:hover {background:var(--th-bg-dce8f5,#dce8f5)}
.sp-alert {
    padding:14px 17px;
    border-radius:10px;
    font-size:13px;
    margin-bottom:19px;
}
.sp-success {
    background:var(--th-bg-e9f8ef,#e9f8ef);
    color:var(--th-fg-226a44,#226a44);
    border:1px solid var(--th-line-c5e8d2,#c5e8d2);
}
.sp-error {
    background:var(--th-bg-fff1ef,#fff1ef);
    color:var(--th-fg-a53e36,#a53e36);
    border:1px solid var(--th-line-f1cdc8,#f1cdc8);
}
.sp-note {
    padding:13px 16px;
    border-radius:9px;
    background:var(--th-bg-f0f6fc,#f0f6fc);
    color:var(--th-fg-54728d,#54728d);
    font-size:12px;
    line-height:1.8;
    margin-bottom:18px;
}
@media(max-width:700px) {
    .sp-fields {grid-template-columns:1fr}
    .sp-field-wide {grid-column:auto}
    .sp-panel {padding:18px}
    .sp-profile-header {padding-inline-start:18px;padding-inline-end:18px}
    .sp-title h2 {font-size:23px}
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="sp-page">

    <div class="sp-title">
        <h2><%: L.T("Student.Profile.MyStudentProfile") %></h2>
        <p><%: L.T("Student.Profile.ManageYourPersonalDetailsAcademicInformation") %></p>
    </div>

    <% if (!string.IsNullOrWhiteSpace(Notice)) { %>
        <div class='sp-alert <%= NoticeIsError ? "sp-error" : "sp-success" %>'
             role="alert">
            <%: Notice %>
        </div>
    <% } %>

    <div class="sp-cover"></div>

    <div class="sp-profile-header">
        <div class="sp-identity">
            <div class="sp-avatar">
                <% if (HasPhoto) { %>
                    <img src="<%: PhotoUrl %>" alt="<%: L.T("Student.Profile.StudentProfilePhoto") %>" />
                <% } else { %>
                    <%: Initials %>
                <% } %>
            </div>

            <div class="sp-identity-info">
                <h3><%: StudentName %></h3>
                <p><%: StudentMajor %> <%: L.T("Student.Profile.GermanJordanianUniversity") %></p>
            </div>
        </div>

        <div class="sp-photo-upload">
            <label for="spPhoto" class="sp-btn sp-btn-light">
                <%: L.T("Student.Profile.ChooseProfilePhoto") %>
            </label>
            <input type="file" id="spPhoto" name="spPhoto"
                   accept=".jpg,.jpeg,.png"
                   style="max-width:240px;font-size:12px" />
            <span class="sp-help"><%: L.T("Student.Profile.JPGOrPNGMaximum2MB") %></span>
        </div>
    </div>

    <div class="sp-panel">
        <div class="sp-panel-header">
            <div class="sp-panel-title">
                <div class="sp-section-icon">&#9786;</div>
                <div>
                    <h3><%: L.T("Student.Profile.PersonalInformation") %></h3>
                    <p><%: L.T("Student.Profile.UpdateYourPersonalAndContactInformation") %></p>
                </div>
            </div>
        </div>

        <div class="sp-fields">
            <div class="sp-field">
                <label for="spName"><%: L.T("Student.Profile.FullName") %></label>
                <input class="sp-input" id="spName" name="spName"
                       type="text" maxlength="120" required
                       value="<%: FormValue("spName", StudentName) %>" />
            </div>

            <div class="sp-field">
                <label for="spAge"><%: L.T("Student.Profile.Age") %></label>
                <input class="sp-input" id="spAge" name="spAge"
                       type="number" min="16" max="100"
                       value="<%: FormValue("spAge", AgeText) %>" />
            </div>

            <div class="sp-field">
                <label for="spEmail"><%: L.T("Student.Profile.UniversityAccountEmail") %></label>
                <input class="sp-input" id="spEmail" type="email"
                       value="<%: StudentEmail %>" readonly />
                <div class="sp-help"><%: L.T("Student.Profile.ManagedByYourUniversityAccount") %></div>
            </div>

            <div class="sp-field">
                <label for="spPhone"><%: L.T("Student.Profile.PhoneNumber") %></label>
                <input class="sp-input" id="spPhone" name="spPhone"
                       type="tel" maxlength="25"
                       placeholder="<%: L.T("Student.Profile.9627XXXXXXXX") %>"
                       value="<%: FormValue("spPhone", StudentPhone) %>" />
            </div>
        </div>
    </div>

    <div class="sp-panel">
        <div class="sp-panel-header">
            <div class="sp-panel-title">
                <div class="sp-section-icon">&#127891;</div>
                <div>
                    <h3><%: L.T("Student.Profile.AcademicInformation") %></h3>
                    <p><%: L.T("Student.Profile.YourOfficialUniversityAndTrainingDetails") %></p>
                </div>
            </div>
            <span class="sp-readonly-badge"><%: L.T("Student.Profile.ReadOnly") %></span>
        </div>

        <div class="sp-note">
            <%: L.T("Student.Profile.AcademicDetailsAreManagedByThe") %>
        </div>

        <div class="sp-fields">
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

    <div class="sp-panel">
        <div class="sp-panel-header">
            <div class="sp-panel-title">
                <div class="sp-section-icon">&lt;/&gt;</div>
                <div>
                    <h3><%: L.T("Student.Profile.SkillsCompetencies") %></h3>
                    <p><%: L.T("Student.Profile.HighlightTheSkillsYouCanOffer") %></p>
                </div>
            </div>
        </div>

        <div class="sp-fields">
            <div class="sp-field">
                <label for="spTechnical"><%: L.T("Student.Profile.TechnicalSkills") %></label>
                <textarea class="sp-input" id="spTechnical"
                          name="spTechnical" maxlength="1500"
                          placeholder="<%: L.T("Student.Profile.ExampleCASPNETHTMLCSS") %>"><%: FormValue("spTechnical", TechnicalSkills) %></textarea>
                <div class="sp-help"><%: L.T("Student.Profile.ProgrammingLanguagesFrameworksToolsAndTechnologies") %></div>
            </div>

            <div class="sp-field">
                <label for="spSoft"><%: L.T("Student.Profile.SoftSkills") %></label>
                <textarea class="sp-input" id="spSoft"
                          name="spSoft" maxlength="1500"
                          placeholder="<%: L.T("Student.Profile.ExampleTeamworkCommunicationTimeManagement") %>"><%: FormValue("spSoft", SoftSkills) %></textarea>
                <div class="sp-help"><%: L.T("Student.Profile.CommunicationLeadershipProblemSolvingAndTeamwork") %></div>
            </div>
        </div>
    </div>

    
<div class="sp-panel">

    <div class="sp-panel-header">
        <div class="sp-panel-title">
            <div class="sp-section-icon">&#128196;</div>
            <div>
                <h3><%: L.T("Student.Profile.CVProfessionalPortfolio") %></h3>
                <p><%: L.T("Student.Profile.ManageYourProfessionalDocumentsAndOnline") %></p>
            </div>
        </div>
    </div>

    <div class="sp-note">
        <%: L.T("Student.Profile.KeepYourCVAndPortfolioUp") %>
    </div>

    <div class="sp-fields">

        <div class="sp-field">
            <div class="sp-file-row">
                <strong><%: L.T("Student.Profile.CurriculumVitaeCV") %></strong>
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
                <strong><%: L.T("Student.Profile.ProjectPortfolio") %></strong>
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
            <label for="spLinkedIn"><%: L.T("Student.Profile.LinkedInProfile") %></label>
            <input class="sp-input"
                   id="spLinkedIn"
                   name="spLinkedIn"
                   type="url"
                   maxlength="500"
                   placeholder="https://www.linkedin.com/in/..."
                   value="<%: FormValue("spLinkedIn", LinkedInUrl) %>" />
        </div>

    </div>

    <div class="sp-actions">
        <a class="sp-btn sp-btn-light"
           href="<%: ResolveUrl("~/Pages/Student/StudentCVPortfolio.aspx") %>">
            <%: L.T("Student.Profile.ManageCVPortfolio") %>
        </a>

        <button class="sp-btn"
                type="submit"
                name="spAction"
                value="save" data-ui-action="save" data-ui-validation="none" data-loading-label="Saving…">
            <%: L.T("Student.Profile.UpdateProfile") %>
        </button>
    </div>

</div>


         
    

</asp:Content>
