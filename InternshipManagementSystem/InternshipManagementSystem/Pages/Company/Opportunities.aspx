<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Opportunities.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Opportunities" Title="Manage Opportunities" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
.op-page{max-width:1060px;margin:auto}.op-heading{display:flex;justify-content:space-between;gap:1rem;align-items:center;margin-bottom:1.25rem}.op-heading h2{font-size:1.6rem;font-weight:750;color:var(--brand-dark);margin:0}.op-sub{color:var(--muted);margin:.4rem 0 0}.op-panel{background:var(--surface);border:1px solid var(--line);border-radius:16px;box-shadow:var(--shadow);padding:1.6rem}.op-section{font-size:1rem;font-weight:700;color:var(--brand-dark);padding-bottom:.7rem;border-bottom:1px solid var(--line);margin:1.4rem 0 1rem}.op-section:first-child{margin-top:0}.op-field label,.op-field legend{display:block;font-weight:650;font-size:.91rem;margin-bottom:.4rem}.op-field input,.op-field textarea,.op-field select{width:100%;border:1px solid #cbd5e1;border-radius:9px;padding:.7rem .85rem;background:white;color:var(--ink)}.op-field input:focus,.op-field textarea:focus,.op-field select:focus{outline:2px solid var(--brand-light);border-color:var(--brand)}.op-field textarea{min-height:125px;resize:vertical}.op-help{font-size:.81rem;color:var(--muted);margin-top:.35rem}.op-req{color:#b42318}.op-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1.1rem}.op-field{margin-bottom:1.1rem}.op-checks{display:flex;flex-wrap:wrap;gap:.6rem}.op-check{display:flex;align-items:center;gap:.45rem;border:1px solid var(--line);border-radius:8px;padding:.65rem .85rem;background:var(--canvas)}.op-check input{width:auto}.op-actions{display:flex;align-items:center;gap:1rem;justify-content:flex-end;border-top:1px solid var(--line);padding-top:1.3rem;margin-top:1rem}.op-submit{border:0;background:var(--brand);color:white;font-weight:700;border-radius:9px;padding:.75rem 1.4rem}.op-submit:hover{background:var(--brand-dark)}.op-note{font-size:.84rem;color:var(--muted)}.op-alert{border-radius:9px;padding:1rem;margin-bottom:1rem}.op-error{background:#fff1f0;color:#9b1c1c;border:1px solid #f9c7c2}.op-success{background:#e9f8ee;color:#186038;border:1px solid #b7e5c5}@media(max-width:700px){.op-grid{grid-template-columns:1fr}.op-panel{padding:1rem}.op-actions{flex-direction:column;align-items:stretch}.op-submit{width:100%}}
</style>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<div class="op-page">
 <div class="op-heading"><div><h2>Create Internship Opportunity</h2><p class="op-sub">Publish an opportunity for eligible GJU students.</p></div><span class="uims-pill uims-pill-info">R01 · Company Supervisor</span></div>
 <% if (!string.IsNullOrEmpty(Notice)) { %><div class="op-alert <%= NoticeIsError ? "op-error" : "op-success" %>" role="alert"><%: Notice %></div><% } %>
 <div class="op-panel">
  <h3 class="op-section">Opportunity information</h3>
  <div class="op-field"><label for="opTitle">Opportunity title <span class="op-req">*</span></label><input id="opTitle" name="opTitle" maxlength="160" required value="<%: FormValue("opTitle") %>" placeholder="e.g. Software Engineering Intern" /></div>
  <div class="op-grid"><div class="op-field"><label for="opCompany">Company</label><input id="opCompany" value="<%: SupervisorCompanyName %>" readonly /><div class="op-help">Automatically linked to your supervisor account.</div></div><div class="op-field"><label for="opLocation">Location <span class="op-req">*</span></label><input id="opLocation" name="opLocation" maxlength="160" required value="<%: FormValue("opLocation") %>" placeholder="Amman / Hybrid / Remote" /></div></div>
  <div class="op-field"><label for="opDescription">Description <span class="op-req">*</span></label><textarea id="opDescription" name="opDescription" maxlength="5000" required placeholder="Describe responsibilities, learning objectives and internship activities..."><%: FormValue("opDescription") %></textarea></div>
  <div class="op-field"><label for="opRequirements">Requirements <span class="op-req">*</span></label><textarea id="opRequirements" name="opRequirements" maxlength="3000" required placeholder="Technical skills, prerequisites and expectations..."><%: FormValue("opRequirements") %></textarea></div>
  <h3 class="op-section">Student eligibility</h3>
  <div class="op-grid"><div class="op-field"><label for="opCollege">Eligible college <span class="op-req">*</span></label><select id="opCollege" name="opCollege" required><option value="School of Computing" selected>School of Computing</option></select><div class="op-help">Uses the college configured in the shared project constants.</div></div><div class="op-field"><label for="opDuration">Duration (weeks) <span class="op-req">*</span></label><input id="opDuration" type="number" name="opDuration" min="1" max="104" required value="<%: FormValueOrDefault("opDuration", "12") %>" /></div></div>
  <div class="op-field"><label>Eligible majors <span class="op-req">*</span></label><div class="op-checks"><label class="op-check"><input type="checkbox" name="opMajors" value="Computer Engineering" <%= IsMajorSelected("Computer Engineering") ? "checked" : "" %> /> Computer Engineering</label><label class="op-check"><input type="checkbox" name="opMajors" value="Computer Science" <%= IsMajorSelected("Computer Science") ? "checked" : "" %> /> Computer Science</label></div><div class="op-help">Select one or both. These values match the project's configured programs.</div></div>
  <h3 class="op-section">Availability & dates</h3>
  <div class="op-grid"><div class="op-field"><label for="opSeats">Total available seats <span class="op-req">*</span></label><input id="opSeats" type="number" name="opSeats" min="1" max="10000" required value="<%: FormValueOrDefault("opSeats", "1") %>" /></div><div class="op-field"><label for="opDeadline">Application deadline <span class="op-req">*</span></label><input id="opDeadline" type="date" name="opDeadline" required value="<%: FormValue("opDeadline") %>" /></div></div>
  <div class="op-field"><label for="opStart">Expected start date <span class="op-req">*</span></label><input id="opStart" type="date" name="opStart" required value="<%: FormValue("opStart") %>" /></div>
  <div class="op-actions"><span class="op-note">Publishing creates an Open opportunity in Firebase.</span><button class="op-submit" type="submit" name="opAction" value="publish" id="opPublish">Publish Opportunity</button></div>
 </div>
</div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
<script>
const button = document.querySelector(
    'button[type="submit"]'
);

if (button instanceof HTMLButtonElement) {
    button.disabled = true;
    button.textContent = "Publishing...";
}
</script>
</asp:Content>


    
