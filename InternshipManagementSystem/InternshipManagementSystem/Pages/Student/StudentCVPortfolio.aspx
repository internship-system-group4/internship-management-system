<%@ Page Language="C#" MasterPageFile="~/Layout/Student.master" AutoEventWireup="true" CodeBehind="StudentCVPortfolio.aspx.cs" Inherits="InternshipManagementSystem.Pages.StudentArea.StudentCVPortfolio" Title="CV & Portfolio" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
<style>
/* R07 only: uses the team's shared GJU theme tokens */
.r07-page{max-width:1060px;margin:0 auto;padding:8px 0 36px;color:var(--ink)}
.r07-breadcrumb{font-size:12px;color:var(--muted);margin-bottom:16px}
.r07-breadcrumb strong{color:var(--brand-dark)}
.r07-top{display:flex;justify-content:space-between;align-items:center;gap:16px;margin-bottom:22px;flex-wrap:wrap}
.r07-top h1{font-size:25px;font-weight:700;color:var(--brand-dark);margin:0 0 5px}
.r07-top p{font-size:14px;color:var(--muted);margin:0}
.r07-pill{background:var(--brand-light);color:var(--brand-dark);padding:7px 12px;border-radius:20px;font-size:12px;font-weight:600}
.r07-layout{display:grid;grid-template-columns:minmax(0,1.65fr) minmax(260px,1fr);gap:20px;align-items:start}
.r07-card{background:var(--surface);border:1px solid var(--line);border-radius:var(--radius);box-shadow:var(--shadow);padding:24px;margin-bottom:18px}
.r07-card-title{display:flex;align-items:center;gap:11px;margin-bottom:9px}
.r07-icon{width:35px;height:35px;border-radius:8px;display:grid;place-items:center;background:var(--brand-light);color:var(--brand-dark);font-size:17px}
.r07-card h2{font-size:17px;font-weight:700;color:var(--brand-dark);margin:0}
.r07-muted{font-size:13px;color:var(--muted);line-height:1.65;margin:0 0 18px}
.r07-label{display:block;font-size:13px;font-weight:600;color:var(--ink);margin-bottom:7px}
.r07-input{display:block;width:100%;padding:11px 12px;font-size:14px;color:var(--ink);background:#fff;border:1px solid var(--line);border-radius:7px;transition:border-color .15s,box-shadow .15s}
.r07-input:focus{outline:0;border-color:var(--brand);box-shadow:0 0 0 3px var(--brand-light)}
.r07-hint{font-size:12px;color:var(--muted);margin-top:7px;display:block}
.r07-actions{display:flex;gap:10px;align-items:center;flex-wrap:wrap;margin-top:8px}
.r07-primary{border:1px solid var(--brand);background:var(--brand);color:#fff;font-weight:600;border-radius:7px;padding:10px 19px;cursor:pointer}
.r07-primary:hover{background:var(--brand-dark);color:#fff}
.r07-secondary{border:1px solid var(--line);background:#fff;color:var(--brand-dark);font-weight:600;border-radius:7px;padding:10px 16px;cursor:pointer}
.r07-secondary:hover{background:var(--brand-light)}
.r07-message{display:block;margin-bottom:15px}
.r07-saved{padding:13px 0;border-bottom:1px solid var(--line);font-size:13px;overflow-wrap:anywhere}
.r07-saved:last-child{border-bottom:0;padding-bottom:0}
.r07-saved strong{display:block;color:var(--ink);margin-bottom:5px}
.r07-saved a{color:var(--brand);text-decoration:underline}
.r07-empty{color:var(--muted)}
.r07-upload-preview{border:1px dashed #a8bdd1;background:var(--brand-light);border-radius:8px;padding:19px 12px;text-align:center;color:var(--brand-dark);font-size:13px}
.r07-upload-preview strong{display:block;margin:4px 0}
.r07-upload-preview small{display:block;color:var(--muted);line-height:1.5}
.r07-notice{border-left:3px solid var(--accent);background:var(--canvas);padding:12px 14px;color:var(--muted);font-size:12px;line-height:1.6;border-radius:4px;margin-top:14px}
.r07-count{text-align:right;font-size:11px;color:var(--muted);margin-top:5px}
@media(max-width:800px){.r07-layout{grid-template-columns:1fr}}
@media(max-width:480px){.r07-card{padding:18px}.r07-top h1{font-size:22px}}
</style>
<script>
function r07Count(inputId, outputId) {
    var input=document.getElementById(inputId), output=document.getElementById(outputId);
    if(input && output) output.textContent=(input.value||"").length+" / 2000";
}
function r07ResetInputs() {
    var cv=document.getElementById('<%= txtCvUrl.ClientID %>');
    var portfolio=document.getElementById('<%= txtPortfolioUrl.ClientID %>');
    if(cv) cv.value="";
    if(portfolio) portfolio.value="";
    r07Count('<%= txtCvUrl.ClientID %>','r07CvCount');
    r07Count('<%= txtPortfolioUrl.ClientID %>','r07PortfolioCount');
}
document.addEventListener("DOMContentLoaded",function(){
    ["<%= txtCvUrl.ClientID %>","<%= txtPortfolioUrl.ClientID %>"].forEach(function(id,i){
        var el=document.getElementById(id), dest=i===0?"r07CvCount":"r07PortfolioCount";
        if(el){el.addEventListener("input",function(){r07Count(id,dest)});r07Count(id,dest)}
    });
});
</script>
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<main class="r07-page">
  <div class="r07-breadcrumb">Student portal &nbsp;›&nbsp; My profile &nbsp;›&nbsp; <strong>CV &amp; Portfolio</strong></div>
  <header class="r07-top">
    <div><h1>CV &amp; Portfolio</h1><p>Manage the professional links attached to your student profile.</p></div>
    <span class="r07-pill">Student profile</span>
  </header>
  <asp:Label ID="lblMessage" runat="server" CssClass="r07-message" role="status" EnableViewState="false" />
  <div class="r07-layout">
    <div>
      <section class="r07-card" aria-labelledby="r07-cv-heading">
        <div class="r07-card-title"><span class="r07-icon" aria-hidden="true">▤</span><h2 id="r07-cv-heading">Curriculum Vitae (CV)</h2></div>
        <p class="r07-muted">Add a shareable link to your latest CV. You can update it whenever your experience changes.</p>
        <label class="r07-label" for="<%= txtCvUrl.ClientID %>">CV URL</label>
        <asp:TextBox ID="txtCvUrl" runat="server" CssClass="r07-input" MaxLength="2000" placeholder="https://example.com/my-cv.pdf" />
        <span class="r07-hint">Use a public or shareable HTTPS link. Leave empty if you do not have one yet.</span>
        <div class="r07-count" id="r07CvCount">0 / 2000</div>
      </section>
      <section class="r07-card" aria-labelledby="r07-portfolio-heading">
        <div class="r07-card-title"><span class="r07-icon" aria-hidden="true">⌘</span><h2 id="r07-portfolio-heading">Portfolio</h2></div>
        <p class="r07-muted">Showcase your projects using a GitHub, Behance or personal portfolio website link.</p>
        <label class="r07-label" for="<%= txtPortfolioUrl.ClientID %>">Portfolio URL</label>
        <asp:TextBox ID="txtPortfolioUrl" runat="server" CssClass="r07-input" MaxLength="2000" placeholder="https://github.com/username" />
        <span class="r07-hint">HTTPS links only. You can add or change this later.</span>
        <div class="r07-count" id="r07PortfolioCount">0 / 2000</div>
      </section>
      <div class="r07-actions">
        <asp:Button ID="btnSave" runat="server" Text="Save changes" CssClass="r07-primary" OnClick="btnSave_Click" />
        <button class="r07-secondary" type="button" onclick="r07ResetInputs()">Clear fields</button>
      </div>
    </div>
    <aside>
      <section class="r07-card" aria-labelledby="r07-saved-heading">
        <div class="r07-card-title"><span class="r07-icon" aria-hidden="true">✓</span><h2 id="r07-saved-heading">Saved references</h2></div>
        <p class="r07-muted">Your saved links are loaded from your student account.</p>
        <div class="r07-saved"><strong>CV</strong>
          <asp:HyperLink ID="lnkCv" runat="server" Target="_blank" rel="noopener noreferrer" Visible="false" Text="Open saved CV ↗" />
          <asp:Label ID="lblNoCv" runat="server" CssClass="r07-empty" Text="Not added yet" />
        </div>
        <div class="r07-saved"><strong>Portfolio</strong>
          <asp:HyperLink ID="lnkPortfolio" runat="server" Target="_blank" rel="noopener noreferrer" Visible="false" Text="Open saved portfolio ↗" />
          <asp:Label ID="lblNoPortfolio" runat="server" CssClass="r07-empty" Text="Not added yet" />
        </div>
      </section>
      <section class="r07-card" aria-labelledby="r07-upload-heading">
        <div class="r07-card-title"><span class="r07-icon" aria-hidden="true">↑</span><h2 id="r07-upload-heading">File upload</h2></div>
        <div class="r07-upload-preview"><strong>File upload — coming soon</strong><small>Figma-style upload area preview.<br/>File storage and permissions must be configured before enabling uploads.</small></div>
        <div class="r07-notice">For now, upload your document to an approved shareable location and paste its HTTPS link above. No file is uploaded from this page.</div>
      </section>
    </aside>
  </div>
</main>
</asp:Content>
