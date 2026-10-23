<%@ Page Language="C#"
    MasterPageFile="~/Layout/Student.master"
    AutoEventWireup="true"
    CodeBehind="DisplayEditProfile.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.StudentArea.DisplayEditProfile" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.profile-page{max-width:1150px;margin:auto}.profile-heading{display:flex;justify-content:space-between;align-items:center;gap:1rem;flex-wrap:wrap;margin-bottom:1.5rem}.profile-heading h1{font-size:1.8rem;font-weight:750;color:var(--ink)}.profile-heading p,.profile-hint{color:var(--muted)}.profile-card{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);box-shadow:var(--shadow);padding:1.5rem;margin-bottom:1.25rem}.profile-card h2{font-size:1.13rem;font-weight:700;color:var(--brand-text,var(--brand));margin:0 0 1.2rem}.profile-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1.1rem}.profile-field label{display:block;font-weight:600;font-size:.9rem;margin-bottom:.35rem}.profile-field .form-control[readonly]{background:var(--canvas);color:var(--ink)}.profile-note{font-size:.83rem;color:var(--muted);margin-top:.6rem}.profile-lock{font-size:.85rem;color:var(--muted);font-weight:500}.profile-actions{display:flex;gap:.7rem;justify-content:flex-end}.profile-alert{display:block;margin-bottom:1rem}.profile-alert:empty{display:none}.profile-skill-input{min-height:90px}.profile-section-icon{color:var(--accent);margin-inline-end:.35rem}@media(max-width:700px){.profile-grid{grid-template-columns:1fr}.profile-card{padding:1.1rem}}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="profile-page">
  <div class="profile-heading"><div><h1><%: L.T("Student.DisplayEditProfile.MyProfile") %></h1><p><%: L.T("Student.DisplayEditProfile.ViewYourInformationAndKeepYour") %></p></div><span class="profile-lock"><%: L.T("Student.DisplayEditProfile.AcademicInformationIsManagedByThe") %></span></div>
  <asp:Label ID="lblStatus" runat="server" CssClass="profile-alert" role="status" />
  <section class="profile-card"><h2><%: L.T("Student.DisplayEditProfile.PersonalInformation") %></h2><div class="profile-grid">
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.FullName") %></label><asp:TextBox ID="txtName" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.EmailAddress") %></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label for="MainContent_txtPhone"><%: L.T("Student.DisplayEditProfile.PhoneNumber") %></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" MaxLength="25" /></div>
  </div><p class="profile-note"><%: L.T("Student.DisplayEditProfile.YourPhoneNumberCanBeUpdated") %></p></section>
  <section class="profile-card"><h2><%: L.T("Student.DisplayEditProfile.AcademicInformation") %> <span class="profile-lock"><%: L.T("Student.DisplayEditProfile.ReadOnly") %></span></h2><div class="profile-grid">
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.StudentNumber") %></label><asp:TextBox ID="txtStudentNumber" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.University") %></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.College") %></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.Major") %></label><asp:TextBox ID="txtMajor" runat="server" CssClass="form-control" ReadOnly="true" /></div>
    <div class="profile-field"><label><%: L.T("Student.DisplayEditProfile.RequiredTrainingHours") %></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control" ReadOnly="true" /></div>
  </div><p class="profile-note"><%: L.T("Student.DisplayEditProfile.TheseFieldsAreControlledByThe") %></p></section>
  <section class="profile-card"><h2><%: L.T("Student.DisplayEditProfile.TechnicalSkills") %></h2><div class="profile-field"><label for="MainContent_txtTechnical"><%: L.T("Student.DisplayEditProfile.YourTechnicalSkills") %></label><asp:TextBox ID="txtTechnical" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control profile-skill-input" MaxLength="1000" /></div><p class="profile-note"><%: L.T("Student.DisplayEditProfile.SeparateSkillsWithCommasForExample") %></p></section>
  <section class="profile-card"><h2><%: L.T("Student.DisplayEditProfile.SoftSkills") %></h2><div class="profile-field"><label for="MainContent_txtSoft"><%: L.T("Student.DisplayEditProfile.YourSoftSkills") %></label><asp:TextBox ID="txtSoft" runat="server" TextMode="MultiLine" Rows="3" CssClass="form-control profile-skill-input" MaxLength="1000" /></div><p class="profile-note"><%: L.T("Student.DisplayEditProfile.SeparateSkillsWithCommasForExample2") %></p></section>
  <div class="profile-actions"><asp:Button ID="btnCancel" runat="server" Text="<%$ Resources:Student, DisplayEditProfile.CancelChanges %>" CssClass="btn btn-outline-secondary" CausesValidation="false" OnClick="btnCancel_Click" /><asp:Button ID="btnSave" runat="server" Text="<%$ Resources:Student, DisplayEditProfile.SaveChanges %>" CssClass="btn btn-brand" OnClick="btnSave_Click"  data-ui-action="save" data-loading-label="Saving…"/></div>
</div>
</asp:Content>
