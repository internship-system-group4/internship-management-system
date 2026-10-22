
<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true" CodeBehind="Profile.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.Profile"
    Title="My Profile" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.sp-page {
    --sp-navy:var(--ui-primary);
    --sp-blue:#28547d;
    --sp-muted:#72839a;
    --sp-line:#e1e9f2;
    max-width:1150px;
    margin:0 auto;
    padding-bottom:35px;
    color:#213d59;
}
.sp-page * {box-sizing:border-box}
.sp-title {margin-bottom:22px}
.sp-title h2 {
    font-size:27px;
    font-weight:800;
    color:var(--sp-navy);
    margin:0 0 7px;
}
.sp-title p {color:var(--sp-muted);font-size:13px;margin:0}

.sp-cover {
    height:115px;
    border-radius:15px 15px 0 0;
    background:linear-gradient(110deg,#173a60,#3678a9);
    position:relative;
    overflow:hidden;
}
.sp-cover:after {
    content:"";
    position:absolute;
    width:210px;height:210px;
    border:35px solid rgba(255,255,255,.08);
    border-radius:50%;
    right:-50px;top:-110px;
}
.sp-profile-header {
    background:#fff;
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
    border:5px solid #fff;
    background:#eaf2fb;
    display:flex;
    align-items:center;
    justify-content:center;
    color:#28547d;
    font-size:31px;
    font-weight:800;
    overflow:hidden;
    flex-shrink:0;
}
.sp-avatar img {width:100%;height:100%;object-fit:cover}
.sp-identity-info {padding-bottom:5px}
.sp-identity-info h3 {
    font-size:20px;
    color:var(--sp-navy);
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
    background:#fff;
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
    border-bottom:1px solid #edf1f6;
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
    background:#eaf2fb;
    color:var(--sp-blue);
    font-size:17px;
    font-weight:800;
}
.sp-panel h3 {
    color:var(--sp-navy);
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
    background:#f0f3f7;
    color:#69798d;
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
    color:#355572;
    font-size:12px;
    font-weight:750;
    margin-bottom:8px;
}
.sp-input {
    width:100%;
    min-height:43px;
    border:1px solid #d8e3ee;
    border-radius:9px;
    padding:11px 13px;
    background:#fbfdff;
    color:#244562;
    font:inherit;
    font-size:13px;
    outline:none;
}
.sp-input:focus {
    border-color:#5d94c2;
    box-shadow:0 0 0 3px rgba(45,103,157,.10);
}
.sp-input[readonly] {
    background:#f3f6fa;
    color:#77889a;
    cursor:not-allowed;
}
textarea.sp-input {min-height:105px;resize:vertical}
input[type=file].sp-input {padding:9px}
.sp-file-row {
    padding:16px;
    border:1px dashed #c8d9e9;
    border-radius:11px;
    background:#f9fbfe;
}
.sp-file-row strong {
    display:block;
    font-size:12px;
    color:#2a4b6a;
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
    color:#286391;
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
.sp-btn:hover {background:#102e4d}
.sp-btn-light {
    background:#eaf1f9;
    color:var(--sp-navy)!important;
}
.sp-btn-light:hover {background:#dce8f5}
.sp-alert {
    padding:14px 17px;
    border-radius:10px;
    font-size:13px;
    margin-bottom:19px;
}
.sp-success {
    background:#e9f8ef;
    color:#226a44;
    border:1px solid #c5e8d2;
}
.sp-error {
    background:#fff1ef;
    color:#a53e36;
    border:1px solid #f1cdc8;
}
.sp-note {
    padding:13px 16px;
    border-radius:9px;
    background:#f0f6fc;
    color:#54728d;
    font-size:12px;
    line-height:1.8;
    margin-bottom:18px;
}
@media(max-width:700px) {
    .sp-fields {grid-template-columns:1fr}
    .sp-field-wide {grid-column:auto}
    .sp-panel {padding:18px}
    .sp-profile-header {padding-left:18px;padding-right:18px}
    .sp-title h2 {font-size:23px}
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="sp-page">

    <div class="sp-title">
        <h2>My Student Profile</h2>
        <p>Manage your personal details, academic information and professional profile.</p>
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
                    <img src="<%: PhotoUrl %>" alt="Student profile photo" />
                <% } else { %>
                    <%: Initials %>
                <% } %>
            </div>

            <div class="sp-identity-info">
                <h3><%: StudentName %></h3>
                <p><%: StudentMajor %> | German Jordanian University</p>
            </div>
        </div>

        <div class="sp-photo-upload">
            <label for="spPhoto" class="sp-btn sp-btn-light">
                Choose Profile Photo
            </label>
            <input type="file" id="spPhoto" name="spPhoto"
                   accept=".jpg,.jpeg,.png"
                   style="max-width:240px;font-size:12px" />
            <span class="sp-help">JPG or PNG, maximum 2 MB.</span>
        </div>
    </div>

    <div class="sp-panel">
        <div class="sp-panel-header">
            <div class="sp-panel-title">
                <div class="sp-section-icon">&#9786;</div>
                <div>
                    <h3>Personal Information</h3>
                    <p>Update your personal and contact information.</p>
                </div>
            </div>
        </div>

        <div class="sp-fields">
            <div class="sp-field">
                <label for="spName">Full Name *</label>
                <input class="sp-input" id="spName" name="spName"
                       type="text" maxlength="120" required
                       value="<%: FormValue("spName", StudentName) %>" />
            </div>

            <div class="sp-field">
                <label for="spAge">Age</label>
                <input class="sp-input" id="spAge" name="spAge"
                       type="number" min="16" max="100"
                       value="<%: FormValue("spAge", AgeText) %>" />
            </div>

            <div class="sp-field">
                <label for="spEmail">University / Account Email</label>
                <input class="sp-input" id="spEmail" type="email"
                       value="<%: StudentEmail %>" readonly />
                <div class="sp-help">Managed by your university account.</div>
            </div>

            <div class="sp-field">
                <label for="spPhone">Phone Number</label>
                <input class="sp-input" id="spPhone" name="spPhone"
                       type="tel" maxlength="25"
                       placeholder="+962 7X XXX XXXX"
                       value="<%: FormValue("spPhone", StudentPhone) %>" />
            </div>
        </div>
    </div>

    <div class="sp-panel">
        <div class="sp-panel-header">
            <div class="sp-panel-title">
                <div class="sp-section-icon">&#127891;</div>
                <div>
                    <h3>Academic Information</h3>
                    <p>Your official university and training details.</p>
                </div>
            </div>
            <span class="sp-readonly-badge">Read Only</span>
        </div>

        <div class="sp-note">
            Academic details are managed by the internship coordinator.
            Contact your coordinator if any information is incorrect.
        </div>

        <div class="sp-fields">
            <div class="sp-field">
                <label>Student ID</label>
                <input class="sp-input" type="text"
                       value="<%: StudentNumber %>" readonly />
            </div>

            <div class="sp-field">
                <label>University</label>
                <input class="sp-input" type="text"
                       value="<%: StudentUniversity %>" readonly />
            </div>

            <div class="sp-field">
                <label>College</label>
                <input class="sp-input" type="text"
                       value="<%: StudentCollege %>" readonly />
            </div>

            <div class="sp-field">
                <label>Major / Specialization</label>
                <input class="sp-input" type="text"
                       value="<%: StudentMajor %>" readonly />
            </div>

            <div class="sp-field">
                <label>Required Training Hours</label>
                <input class="sp-input" type="text"
                       value="<%: RequiredHoursText %>" readonly />
            </div>

            <div class="sp-field">
                <label>Approved Training Hours</label>
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
                    <h3>Skills &amp; Competencies</h3>
                    <p>Highlight the skills you can offer to companies.</p>
                </div>
            </div>
        </div>

        <div class="sp-fields">
            <div class="sp-field">
                <label for="spTechnical">Technical Skills</label>
                <textarea class="sp-input" id="spTechnical"
                          name="spTechnical" maxlength="1500"
                          placeholder="Example: C#, ASP.NET, HTML, CSS, SQL, Git"><%: FormValue("spTechnical", TechnicalSkills) %></textarea>
                <div class="sp-help">Programming languages, frameworks, tools and technologies.</div>
            </div>

            <div class="sp-field">
                <label for="spSoft">Soft Skills</label>
                <textarea class="sp-input" id="spSoft"
                          name="spSoft" maxlength="1500"
                          placeholder="Example: Teamwork, communication, time management"><%: FormValue("spSoft", SoftSkills) %></textarea>
                <div class="sp-help">Communication, leadership, problem-solving and teamwork.</div>
            </div>
        </div>
    </div>

    
<div class="sp-panel">

    <div class="sp-panel-header">
        <div class="sp-panel-title">
            <div class="sp-section-icon">&#128196;</div>
            <div>
                <h3>CV &amp; Professional Portfolio</h3>
                <p>Manage your professional documents and online presence.</p>
            </div>
        </div>
    </div>

    <div class="sp-note">
        Keep your CV and portfolio up to date so companies
        can learn more about your experience, projects and skills.
    </div>

    <div class="sp-fields">

        <div class="sp-field">
            <div class="sp-file-row">
                <strong>Curriculum Vitae (CV)</strong>
                <p>
                    Upload your latest CV, replace an existing file,
                    or manage your online CV link.
                </p>

                <% if (HasCvFile) { %>
                    <a class="sp-file-link"
                       href="<%: CvDownloadUrl %>">
                        Download Current CV &rarr;
                    </a>
                <% } else { %>
                    <span class="sp-help">
                        No uploaded CV available.
                    </span>
                <% } %>
            </div>
        </div>

        <div class="sp-field">
            <div class="sp-file-row">
                <strong>Project Portfolio</strong>
                <p>
                    Showcase your academic projects, practical work,
                    achievements and professional experience.
                </p>

                <% if (HasPortfolioFile) { %>
                    <a class="sp-file-link"
                       href="<%: PortfolioDownloadUrl %>">
                        Download Current Portfolio &rarr;
                    </a>
                <% } else { %>
                    <span class="sp-help">
                        No uploaded portfolio available.
                    </span>
                <% } %>
            </div>
        </div>

        <div class="sp-field sp-field-wide">
            <label for="spLinkedIn">LinkedIn Profile</label>
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
            Manage CV &amp; Portfolio &rarr;
        </a>

        <button class="sp-btn"
                type="submit"
                name="spAction"
                value="save" data-ui-action="save" data-ui-validation="none" data-loading-label="Saving…">
            Update Profile
        </button>
    </div>

</div>


         
    

</asp:Content>
