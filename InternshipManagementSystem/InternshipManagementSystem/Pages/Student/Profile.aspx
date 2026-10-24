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

.sp-section-toggle { cursor: default; }
.sp-section-toggle:hover { background: transparent; }
.sp-section-right { flex-wrap: wrap; justify-content: flex-end; }
.sp-link-row { display: block; margin-top: 8px; overflow-wrap: anywhere; }
.sp-modal-divider {
    display: flex;
    flex-direction: column;
    gap: 5px;
    padding: 13px 15px;
    margin: 7px 0 16px;
    border-radius: 11px;
    background: var(--th-bg-f0f6fc,#f0f6fc);
    color: var(--sp-ink);
}
.sp-modal-divider span { color: var(--ui-muted); font-size: 12px; }
.sp-file-input { padding: 9px !important; }
.sp-result-modal {
    position: fixed;
    inset: 0;
    z-index: 1060;
    display: grid;
    place-items: center;
    padding: 18px;
    background: rgba(12,30,49,.57);
}
.sp-result-card {
    width: min(100%, 390px);
    padding: 30px 26px 25px;
    border: 1px solid var(--sp-border);
    border-radius: 20px;
    background: var(--ui-surface,#fff);
    box-shadow: 0 20px 70px rgba(0,0,0,.22);
    text-align: center;
}
.sp-success-mark {
    display: grid;
    place-items: center;
    width: 64px;
    height: 64px;
    margin: 0 auto 15px;
    border-radius: 50%;
    background: var(--th-bg-e9f8ef,#e9f8ef);
    color: var(--th-fg-226a44,#226a44);
    font-size: 34px;
}
.sp-success-mark i { display: none; }
.sp-success-mark::before { content: ""; width: 15px; height: 27px; border: solid currentColor; border-width: 0 3px 3px 0; transform: rotate(45deg) translate(-2px,-2px); border-radius: 1px; }
.sp-result-card h3 { margin: 0 0 22px; color: var(--sp-ink); font-size: 20px; line-height: 1.45; }
.sp-result-card .sp-success-close { display: inline-flex !important; align-items: center; justify-content: center; gap: 9px; min-width: 140px; min-height: 48px; padding: 0 22px; border: 0 !important; border-radius: 999px; background: var(--sp-primary,#173a60) !important; color: #fff !important; font-size: 14px; font-weight: 700; box-shadow: 0 5px 14px rgba(23,58,96,.18); cursor: pointer; }
.sp-result-card .sp-success-close:hover { filter: brightness(1.08); }
.sp-result-card p { margin: 0 0 22px; color: var(--ui-muted); line-height: 1.6; }
.sp-result-modal[hidden] { display: none !important; }
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
    cursor: default;
    color: inherit;
}

.sp-section-toggle:hover { background: transparent; }

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


.sp-account-value { display: flex; align-items: center; gap: 10px; }
.sp-account-value i { color: var(--sp-primary); font-size: 18px; flex: 0 0 auto; }
.sp-modal-dialog { display: flex; flex-direction: column; overflow: hidden; }
.sp-modal-body { overflow-y: auto; min-height: 0; }
.sp-modal-foot {
    position: sticky;
    bottom: 0;
    z-index: 2;
    flex-shrink: 0;
    background: var(--ui-surface,#fff);
    border-top: 1px solid var(--sp-border);
}
.sp-modal-foot .sp-save-button {
    display: inline-flex !important;
    align-items: center;
    justify-content: center;
    gap: 8px;
    min-width: 150px;
    visibility: visible !important;
    opacity: 1 !important;
}
@media (max-width: 700px) {
    .sp-modal-foot .sp-save-button { min-width: 0; }
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

/* Keep the modal actions visible while the form scrolls. */
.sp-modal-dialog {
    height: 90vh;
    max-height: 90vh;
    overflow: hidden;
}
.sp-modal-head { flex: 0 0 auto; }
.sp-modal-body {
    flex: 1 1 auto;
    min-height: 0;
    overflow-y: auto;
}
.sp-modal-foot {
    position: relative;
    flex: 0 0 auto;
    padding: 14px 25px 20px;
    background: var(--ui-surface,#fff);
}
.sp-modal-foot .sp-save-button {
    color: #fff !important;
    background: var(--sp-primary);
}
/* Student profile resources */
.sp-resource-grid { display:grid; grid-template-columns:repeat(2,minmax(0,1fr)); gap:14px; }
.sp-resource-card { min-width:0; display:flex; flex-direction:column; gap:18px; padding:20px; border:1px solid var(--sp-border); border-radius:15px; background:var(--th-bg-f8fafc,#f8fafc); }
.sp-resource-card-linkedin { grid-column:1/-1; flex-direction:row; align-items:center; justify-content:space-between; flex-wrap:wrap; }
.sp-resource-heading { display:flex; align-items:flex-start; gap:13px; min-width:0; }
.sp-resource-icon { flex:0 0 42px; width:42px; height:42px; display:grid; place-items:center; border-radius:12px; background:var(--th-bg-e8f0f7,#e8f0f7); color:var(--sp-primary); font-size:19px; }
.sp-resource-icon.sp-linkedin-icon { color:#0a66c2; background:#eaf3fb; }
.sp-resource-heading h3 { margin:0 0 5px; color:var(--sp-ink); font-size:15px; font-weight:750; }
.sp-resource-heading p { margin:0; color:var(--ui-muted); font-size:12px; line-height:1.55; }
.sp-resource-actions { display:flex; flex-wrap:wrap; align-items:center; gap:9px; margin-top:auto; }
.sp-resource-link { min-height:40px; display:inline-flex; align-items:center; justify-content:center; gap:8px; max-width:100%; padding:9px 13px; border:1px solid var(--sp-primary); border-radius:10px; background:var(--sp-primary); color:#fff !important; font-size:12px; font-weight:700; text-decoration:none !important; transition:background .16s ease,transform .16s ease; }
.sp-resource-link:hover { background:var(--th-bg-2b4560,#2b4560); transform:translateY(-1px); }
.sp-resource-link-secondary { background:transparent; color:var(--sp-ink) !important; }
.sp-resource-link-secondary:hover { background:var(--th-bg-e8f0f7,#e8f0f7); }
.sp-resource-empty { display:inline-flex; align-items:center; gap:7px; color:var(--ui-muted); font-size:12px; }
.sp-resource-url { max-width:min(42vw,520px); overflow:hidden; text-overflow:ellipsis; white-space:nowrap; color:inherit; opacity:.82; font-weight:500; }
@media(max-width:700px) { .sp-resource-grid { grid-template-columns:1fr; } .sp-resource-card-linkedin { grid-column:auto; flex-direction:column; align-items:stretch; } .sp-resource-card-linkedin .sp-resource-link { align-self:flex-start; } .sp-resource-url { max-width:55vw; } }
/* Compact student profile hero */
.sp-cover { height:112px; }
.sp-avatar-holder { margin-top:-52px; }
.sp-avatar { width:104px; height:104px; }
.sp-person { padding:10px 18px 18px; }
.sp-person h3 { font-size:21px; margin-bottom:5px; }
.sp-person p { margin-bottom:9px; }
.sp-role { padding:6px 14px; }
@media(max-width:700px) {
    .sp-cover { height:96px; }
    .sp-avatar-holder { margin-top:-44px; }
    .sp-avatar { width:88px; height:88px; }
    .sp-person { padding:9px 14px 16px; }
}
/* Refined academic detail cards and lively, professional skill tags */
.sp-academic-section .sp-info-grid .sp-field { position:relative; overflow:hidden; min-height:94px; padding:17px 19px; border-radius:14px; background:linear-gradient(145deg,var(--ui-surface,#fff),var(--th-bg-f8fafc,#f8fafc)); transition:transform .18s ease,border-color .18s ease,box-shadow .18s ease; }
.sp-academic-section .sp-info-grid .sp-field::before { content:""; position:absolute; inset-block:14px; inset-inline-start:0; width:3px; border-radius:0 4px 4px 0; background:var(--sp-primary); opacity:.45; }
.sp-academic-section .sp-info-grid .sp-field:hover { transform:translateY(-2px); border-color:var(--th-line-b8cde0,#b8cde0); box-shadow:0 8px 20px rgba(23,58,96,.07); }
.sp-academic-section .sp-info-grid .sp-field label { margin-bottom:9px; font-size:10px; letter-spacing:.055em; text-transform:uppercase; }
.sp-academic-section .sp-view-value { font-size:14px; line-height:1.45; }
.sp-skill-list { display:flex; flex-wrap:wrap; align-items:center; gap:8px; white-space:normal; min-height:30px; }
.sp-skill-tag { display:inline-flex; align-items:center; min-height:30px; padding:5px 11px; border:1px solid #d8e5f1; border-radius:999px; background:#edf4fa; color:#244d73; font-size:12px; font-weight:650; line-height:1.25; transition:transform .18s ease,box-shadow .18s ease,background .18s ease; animation:sp-skill-in .32s both; }
.sp-skill-tag:nth-child(4n+2) { border-color:#d5e9e4; background:#edf7f3; color:#286657; }
.sp-skill-tag:nth-child(4n+3) { border-color:#e2dcf1; background:#f3f0fa; color:#5b4d80; }
.sp-skill-tag:nth-child(4n+4) { border-color:#eee1ce; background:#faf5eb; color:#78603b; }
.sp-skill-tag:hover { transform:translateY(-2px) scale(1.025); box-shadow:0 5px 12px rgba(23,58,96,.1); }
@keyframes sp-skill-in { from { opacity:0; transform:translateY(5px) scale(.97); } to { opacity:1; transform:translateY(0) scale(1); } }
@media(prefers-reduced-motion:reduce) { .sp-skill-tag { animation:none; transition:none; } .sp-academic-section .sp-info-grid .sp-field { transition:none; } }
/* Consistent type scale for the profile page */
body.uims-portal .uims-main-inner .sp-page { font-size:15px; line-height:1.55; }
body.uims-portal .uims-main-inner .sp-page .sp-heading h2 { font-size:34px; line-height:1.2; font-weight:750; }
body.uims-portal .uims-main-inner .sp-page .sp-section-title strong { font-size:16px; line-height:1.35; font-weight:700; }
body.uims-portal .uims-main-inner .sp-page .sp-section-title small { font-size:13px; line-height:1.45; }
body.uims-portal .uims-main-inner .sp-page .sp-person h3 { font-size:21px; line-height:1.3; }
body.uims-portal .uims-main-inner .sp-page .sp-person p { font-size:14px; line-height:1.5; }
body.uims-portal .uims-main-inner .sp-page .sp-role { font-size:12px; line-height:1.3; }
body.uims-portal .uims-main-inner .sp-page .sp-info-grid .sp-field label { font-size:12px; line-height:1.4; }
body.uims-portal .uims-main-inner .sp-page .sp-view-value { font-size:14px; line-height:1.5; }
body.uims-portal .uims-main-inner .sp-page .sp-help { font-size:12px; line-height:1.5; }
body.uims-portal .uims-main-inner .sp-page .sp-note { font-size:14px; line-height:1.55; }
body.uims-portal .uims-main-inner .sp-page .sp-resource-heading h3 { font-size:15px; line-height:1.4; }
body.uims-portal .uims-main-inner .sp-page .sp-resource-heading p { font-size:12px; line-height:1.55; }
body.uims-portal .uims-main-inner .sp-page .sp-resource-link { font-size:12px; line-height:1.35; }
body.uims-portal .uims-main-inner .sp-page .sp-resource-empty { font-size:12px; line-height:1.45; }
body.uims-portal .uims-main-inner .sp-page .sp-resource-url { font-size:11px; line-height:1.4; }
body.uims-portal .uims-main-inner .sp-page .sp-modal-head h3 { font-size:20px; line-height:1.3; }
body.uims-portal .uims-main-inner .sp-page .sp-modal-body .sp-field label { font-size:13px; line-height:1.4; }
body.uims-portal .uims-main-inner .sp-page .sp-modal-body .sp-input { font-size:14px; line-height:1.45; }
@media(max-width:700px) { body.uims-portal .uims-main-inner .sp-page .sp-heading h2 { font-size:29px; } }
/* Reduce above-the-fold scrolling on the student profile */
.sp-page { padding-top:0; }
.sp-heading { margin-bottom:12px; padding-bottom:10px; }
.sp-cover { height:100px; }
.sp-avatar-holder { margin-top:-64px; }
.sp-avatar { width:100px; height:100px; }
.sp-person { padding:8px 16px 12px; }
.sp-person p { margin-bottom:7px; }
@media(max-width:700px) {
    .sp-page { padding-top:0; }
    .sp-heading { margin-bottom:10px; padding-bottom:8px; }
    .sp-cover { height:88px; }
    .sp-avatar-holder { margin-top:-54px; }
    .sp-avatar { width:82px; height:82px; }
    .sp-person { padding:7px 12px 12px; }
}
</style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

<div class="sp-page" id="studentProfilePage">

    <div class="sp-heading">
        <h2><%: L.T("Student.DisplayEditProfile.MyProfile") %></h2>
    </div>

    <% if (!string.IsNullOrWhiteSpace(Notice) && NoticeIsError) { %>
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
                <%: StudentMajor %>
                <%: L.T("Student.Profile.GermanJordanianUniversity") %>
            </p>
            <span class="sp-role">
                <i class="bi bi-mortarboard" aria-hidden="true"></i>
                <%: L.T("Student.Profile.Student") %>
            </span>
        </div>

    </div>

    <!-- Profile Sections -->
    <div class="sp-sections">

        <!-- Personal Information -->
        <section class="sp-section">

            <div class="sp-section-toggle">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-person" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.PersonalInformation") %></strong>
                        <small><%: L.T("Student.Profile.UpdateYourPersonalAndContactInformation") %></small>
                    </span>
                </span>


            </div>

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
                        <label><%: L.T("Student.Profile.UniversityAccountEmail") %></label>
                        <div class="sp-view-value sp-account-value">
                            <i class="bi bi-envelope" aria-hidden="true"></i>
                            <span><%: StudentEmail %></span>
                        </div>
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
        <section class="sp-section sp-academic-section">

            <div class="sp-section-toggle">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-mortarboard" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.AcademicInformation") %></strong>
                        <small><%: L.T("Student.Profile.YourOfficialUniversityAndTrainingDetails") %></small>
                    </span>
                </span>
            </div>

            <div class="sp-section-body">

                <div class="sp-note">
                    <%: L.T("Student.Profile.AcademicDetailsAreManagedByThe") %>
                </div>

                <div class="sp-info-grid">

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.StudentID") %></label>
                        <div class="sp-view-value"><%: StudentNumber %></div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.University") %></label>
                        <div class="sp-view-value"><%: StudentUniversity %></div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.College") %></label>
                        <div class="sp-view-value"><%: StudentCollege %></div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.MajorSpecialization") %></label>
                        <div class="sp-view-value"><%: StudentMajor %></div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.RequiredTrainingHours") %></label>
                        <div class="sp-view-value"><%: RequiredHoursText %></div>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.ApprovedTrainingHours") %></label>
                        <div class="sp-view-value"><%: ApprovedHoursText %></div>
                    </div>

                </div>
            </div>
        </section>

        <!-- Skills -->
        <section class="sp-section">

            <div class="sp-section-toggle">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-code-slash" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.SkillsCompetencies") %></strong>
                        <small><%: L.T("Student.Profile.HighlightTheSkillsYouCanOffer") %></small>
                    </span>
                </span>


            </div>

            <div class="sp-section-body">
                <div class="sp-info-grid">

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.TechnicalSkills") %></label>
                        <div class="sp-view-value sp-view-multiline sp-skill-list" data-skill-list><%: FormValue("spTechnical", TechnicalSkills) %></div>
                        <span class="sp-help">
                            <%: L.T("Student.Profile.ProgrammingLanguagesFrameworksToolsAndTechnologies") %>
                        </span>
                    </div>

                    <div class="sp-field">
                        <label><%: L.T("Student.Profile.SoftSkills") %></label>
                        <div class="sp-view-value sp-view-multiline sp-skill-list" data-skill-list><%: FormValue("spSoft", SoftSkills) %></div>
                        <span class="sp-help">
                            <%: L.T("Student.Profile.CommunicationLeadershipProblemSolvingAndTeamwork") %>
                        </span>
                    </div>

                </div>
            </div>
        </section>

        <!-- CV & Portfolio -->
        <section class="sp-section">

            <div class="sp-section-toggle">

                <span class="sp-section-title">
                    <span class="sp-section-icon">
                        <i class="bi bi-file-earmark-text" aria-hidden="true"></i>
                    </span>
                    <span>
                        <strong><%: L.T("Student.Profile.CVProfessionalPortfolio") %></strong>
                        <small><%: L.T("Student.Profile.ManageYourProfessionalDocumentsAndOnline") %></small>
                    </span>
                </span>


            </div>

            <div class="sp-section-body">

                <div class="sp-note">
                    <%: L.T("Student.Profile.KeepYourCVAndPortfolioUp") %>
                </div>

                <div class="sp-resource-grid">
    <article class="sp-resource-card">
        <div class="sp-resource-heading">
            <span class="sp-resource-icon" aria-hidden="true"><i class="bi bi-file-earmark-person"></i></span>
            <div><h3><%: L.T("Student.Profile.CurriculumVitaeCV") %></h3><p><%: L.T("Student.Profile.UploadYourLatestCVReplaceAn") %></p></div>
        </div>
        <div class="sp-resource-actions">
            <% if (!string.IsNullOrWhiteSpace(CvUrl)) { %>
                <a class="sp-resource-link" href="<%: CvUrl %>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right" aria-hidden="true"></i><%: L.T("Student.Profile.OpenOnlineCV") %></a>
            <% } %>
            <% if (HasCvFile) { %>
                <a class="sp-resource-link sp-resource-link-secondary" href="<%: CvDownloadUrl %>"><i class="bi bi-download" aria-hidden="true"></i><%: L.T("Student.Profile.DownloadCurrentCV") %></a>
            <% } %>
            <% if (!HasCvFile && string.IsNullOrWhiteSpace(CvUrl)) { %>
                <span class="sp-resource-empty"><i class="bi bi-info-circle" aria-hidden="true"></i><%: L.T("Student.Profile.NoUploadedCVAvailable") %></span>
            <% } %>
        </div>
    </article>

    <article class="sp-resource-card">
        <div class="sp-resource-heading">
            <span class="sp-resource-icon" aria-hidden="true"><i class="bi bi-briefcase"></i></span>
            <div><h3><%: L.T("Student.Profile.ProjectPortfolio") %></h3><p><%: L.T("Student.Profile.ShowcaseYourAcademicProjectsPracticalWork") %></p></div>
        </div>
        <div class="sp-resource-actions">
            <% if (!string.IsNullOrWhiteSpace(PortfolioUrl)) { %>
                <a class="sp-resource-link" href="<%: PortfolioUrl %>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right" aria-hidden="true"></i><%: L.T("Student.Profile.OpenProjectPortfolio") %></a>
            <% } %>
            <% if (HasPortfolioFile) { %>
                <a class="sp-resource-link sp-resource-link-secondary" href="<%: PortfolioDownloadUrl %>"><i class="bi bi-download" aria-hidden="true"></i><%: L.T("Student.Profile.DownloadCurrentPortfolio") %></a>
            <% } %>
            <% if (!HasPortfolioFile && string.IsNullOrWhiteSpace(PortfolioUrl)) { %>
                <span class="sp-resource-empty"><i class="bi bi-info-circle" aria-hidden="true"></i><%: L.T("Student.Profile.NoUploadedPortfolioAvailable") %></span>
            <% } %>
        </div>
    </article>

    <article class="sp-resource-card sp-resource-card-linkedin">
        <div class="sp-resource-heading">
            <span class="sp-resource-icon sp-linkedin-icon" aria-hidden="true"><i class="bi bi-linkedin"></i></span>
            <div><h3><%: L.T("Student.Profile.LinkedInProfile") %></h3><p><%: L.T("Student.Profile.ProfessionalOnlinePresence") %></p></div>
        </div>
        <% if (!string.IsNullOrWhiteSpace(LinkedInUrl)) { %>
            <a class="sp-resource-link" href="<%: LinkedInUrl %>" target="_blank" rel="noopener noreferrer"><i class="bi bi-box-arrow-up-right" aria-hidden="true"></i><%: L.T("Student.Profile.OpenLinkedInProfile") %><span class="sp-resource-url"><%: LinkedInUrl %></span></a>
        <% } else { %>
            <span class="sp-resource-empty"><i class="bi bi-info-circle" aria-hidden="true"></i><%: L.T("Student.Profile.NoLinkedInProfileAvailable") %></span>
        <% } %>
    </article>
</div>

            </div>
        </section>

    </div>
</div>

<% if (!string.IsNullOrWhiteSpace(Notice) && !NoticeIsError) { %>
<div class="sp-result-modal" id="spSaveSuccess" role="dialog" aria-modal="true" aria-labelledby="spSaveSuccessTitle">
    <div class="sp-result-card">
        <div class="sp-success-mark" aria-hidden="true"><i class="bi bi-check-lg"></i></div>
        <h3 id="spSaveSuccessTitle"><%: L.T("Student.Profile.YourProfileHasBeenUpdatedSuccessfully") %></h3>
        <button type="button" class="sp-btn sp-success-close" id="spSuccessOkay" style="display:inline-flex!important;align-items:center;justify-content:center;min-width:140px;min-height:48px;padding:0 22px;border:0!important;border-radius:999px;background:#173a60!important;color:#fff!important;font-size:14px;font-weight:700;"> <i class="bi bi-check-lg" aria-hidden="true"></i><span><%: L.T("Student.Profile.Close") %></span></button>
    </div>
</div>
<% } %>
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

            <div class="sp-modal-divider">
                <strong><i class="bi bi-file-earmark-text" aria-hidden="true"></i> <%: L.T("Student.Profile.CVProfessionalPortfolio") %></strong>
                <span><%: L.T("Student.Profile.KeepYourCVAndPortfolioUp") %></span>
            </div>

            <div class="sp-field">
                <label for="spCvUrl"><%: L.T("Student.StudentCVPortfolio.CVLink") %></label>
                <input class="sp-input" id="spCvUrl" name="spCvUrl" type="url" maxlength="500" placeholder="https://..." value="<%: FormValue("spCvUrl", CvUrl) %>" />
                <span class="sp-help"><%: L.T("Student.StudentCVPortfolio.AddLinksToYourOnlineCV") %></span>
            </div>

            <div class="sp-field">
                <label for="spCvFile"><%: L.T("Student.StudentCVPortfolio.UploadCV") %></label>
                <input class="sp-input sp-file-input" id="spCvFile" name="spCvFile" type="file" accept=".pdf,application/pdf" />
                <span class="sp-help"><%: L.T("Student.StudentCVPortfolio.PDFFilesMustBe5MB") %></span>
            </div>

            <div class="sp-field">
                <label for="spPortfolioUrl"><%: L.T("Student.StudentCVPortfolio.PortfolioLink") %></label>
                <input class="sp-input" id="spPortfolioUrl" name="spPortfolioUrl" type="url" maxlength="500" placeholder="https://..." value="<%: FormValue("spPortfolioUrl", PortfolioUrl) %>" />
                <span class="sp-help"><%: L.T("Student.StudentCVPortfolio.GitHubBehanceOrAPersonalWebsite") %></span>
            </div>

            <div class="sp-field">
                <label for="spPortfolioFile"><%: L.T("Student.Profile.ProjectPortfolio") %></label>
                <input class="sp-input sp-file-input" id="spPortfolioFile" name="spPortfolioFile" type="file" accept=".pdf,application/pdf" />
                <span class="sp-help"><%: L.T("Student.StudentCVPortfolio.PDFFilesMustBe5MB") %></span>
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

        <div class="sp-modal-foot" style="display:flex;flex-direction:row;flex-wrap:nowrap;align-items:center;justify-content:flex-end;gap:12px;width:100%;min-height:76px;padding:12px 25px 20px;background:#fff;border-top:1px solid var(--sp-border);">

            <button type="button"
                    class="sp-btn sp-btn-light" style="display:inline-flex;align-items:center;justify-content:center;min-height:48px;"
                    id="spCancelEdit">
                <%: L.T("Student.Profile.Cancel") %>
            </button>

            <button class="sp-btn sp-save-button" style="display:inline-flex!important;align-items:center;justify-content:center;gap:8px;min-width:160px;min-height:48px;visibility:visible!important;opacity:1!important;background:#173a60!important;color:#fff!important;" type="submit"
                    name="spAction"
                    value="save"
                    data-ui-action="save"
                    data-ui-validation="none"
                    data-loading-label="<%: L.T("Shared.I18n.Saving") %>">
                <i class="bi bi-check-lg" aria-hidden="true"></i> <%: L.T("Student.DisplayEditProfile.SaveChanges") %>
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
        modal.querySelectorAll("input,textarea").forEach(function (field) {
            if (field.type === "file") field.value = "";
            else field.value = field.defaultValue;
        });
        closeModal();
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

    var successModal = document.getElementById("spSaveSuccess");
    var successOkay = document.getElementById("spSuccessOkay");
    if (successModal && successOkay) {
        document.body.style.overflow = "hidden";
        successOkay.focus();
        successOkay.addEventListener("click", function () {
            successModal.remove();
            document.body.style.overflow = "";
        });
        successModal.addEventListener("click", function (event) {
            if (event.target === successModal) {
                successModal.remove();
                document.body.style.overflow = "";
            }
        });
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape" && document.getElementById("spSaveSuccess")) {
                successModal.remove();
                document.body.style.overflow = "";
            }
        });
    }
    document.querySelectorAll("[data-skill-list]").forEach(function (list) {
        var label = list.parentElement.querySelector("label");
        var skills = list.textContent.split(/[,،;|\r\n]+/).map(function (skill) { return skill.trim(); }).filter(Boolean);
        if (!skills.length) return;
        list.replaceChildren();
        list.setAttribute("role", "list");
        if (label) list.setAttribute("aria-label", label.textContent.trim());
        skills.forEach(function (skill, index) {
            var tag = document.createElement("span");
            tag.className = "sp-skill-tag";
            tag.setAttribute("role", "listitem");
            tag.style.animationDelay = Math.min(index * 45, 360) + "ms";
            tag.textContent = skill;
            list.appendChild(tag);
        });
    });
    <% if (NoticeIsError) { %>
        openModal();
    <% } %>

})();
</script>

</asp:Content>
