<%@ Page Language="C#" AutoEventWireup="false" EnableSessionState="false" EnableViewState="false" CodeBehind="NotFound.aspx.cs" Inherits="InternshipManagementSystem.Pages.PublicArea.NotFound" %>
<%@ Register Src="~/Layout/LanguageSelector.ascx" TagPrefix="uims" TagName="LanguageSelector" %>
<%@ Register Src="~/Layout/ThemeSelector.ascx" TagPrefix="uims" TagName="ThemeSelector" %>
<!DOCTYPE html>
<html lang="<%: L.Lang %>" dir="<%: L.Dir %>" class="uims-public">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="robots" content="noindex" />
    <meta name="referrer" content="same-origin" />
    <script>(function(r){var p='light';try{var s=localStorage.getItem('uims-theme');if(s==='dark')p=s;else if(s==='system'){p=window.matchMedia&&matchMedia('(prefers-color-scheme: dark)').matches?'dark':'light';localStorage.setItem('uims-theme',p);}}catch(e){}r.setAttribute('data-theme-preference',p);r.setAttribute('data-theme',p);r.setAttribute('data-bs-theme',p);r.style.colorScheme=p;}(document.documentElement));</script>
    <title></title>
    <link rel="icon" href="~/Assets/images/gju-logo.png" runat="server" />
    <%-- Minimal readable fallback if any stylesheet fails. The message never depends on animation. --%>
    <style>body{margin:0;font-family:Arial,sans-serif}main{padding:32px;text-align:center}[hidden]{display:none!important}</style>
    <link rel="stylesheet" href="~/Assets/css/ui-tokens.css?v=20261023-5" runat="server" />
    <link rel="stylesheet" href="~/Assets/css/theme.css?v=20261024-theme-8" runat="server" />
    <link rel="stylesheet" href="~/Assets/css/ui-system.css?v=20261023-5" runat="server" />
    <link rel="stylesheet" href="~/Assets/css/i18n.css?v=20261023-9" runat="server" />
    <link rel="stylesheet" href="~/Assets/css/not-found.css?v=20261023-1" runat="server" />
    <script>window.UIMS_I18N=<%= L.ScriptDictionary() %>;window.uimsT=function(k){var d=window.UIMS_I18N,t=Object.prototype.hasOwnProperty.call(d,k)?d[k]:k,a=arguments;return t.replace(/\{(\d+)\}/g,function(m,i){var v=a[+i+1];return v===undefined?m:String(v);});};</script>
</head>
<body class="uims-public nf-page">
<form id="mainForm" runat="server">
    <a class="nf-skip" href="#not-found"><%: L.T("Shared.Public.SkipToContent") %></a>
    <div class="nf-scene" data-not-found>
        <div class="nf-decor" aria-hidden="true">
            <div class="nf-circle nf-circle-one"></div><div class="nf-circle nf-circle-two"></div><div class="nf-circle nf-circle-three"></div>
            <%-- Original local SVG artwork, with no external asset or canvas dependency. --%>
            <svg class="nf-symbols" width="0" height="0" focusable="false"><defs><symbol id="nf-student" viewBox="0 0 80 100"><g fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><circle cx="42" cy="21" r="8" /><path d="m30 12 13-6 14 6-14 5-13-5m25 1v11M42 30l-6 30m4-22L22 49l-9-8m26-1 14 15 13-4M36 60l-8 19-15 6m23-25 15 12 2 19" /><path class="nf-backpack" d="m45 34 9 5-4 17-9-5z" /></g></symbol></defs></svg>
            <svg class="nf-figure nf-figure-one" width="72" height="90" viewBox="0 0 80 100" focusable="false"><use href="#nf-student" /></svg>
            <svg class="nf-figure nf-figure-two" width="72" height="90" viewBox="0 0 80 100" focusable="false"><use href="#nf-student" /></svg>
            <svg class="nf-figure nf-figure-three" width="72" height="90" viewBox="0 0 80 100" focusable="false"><use href="#nf-student" /></svg>
            <svg class="nf-route" width="260" height="100" viewBox="0 0 260 100" focusable="false"><path d="M8 82C40 20 96 99 136 42S224 12 250 30" /><circle cx="8" cy="82" r="5" /><circle cx="250" cy="30" r="5" /></svg>
        </div>
        <header class="nf-header">
            <a class="nf-brand" href="<%: ResolveUrl("~/Default.aspx") %>" aria-label="<%: L.T("Shared.Public.UIMSHome") %>">
                <img src="<%: ResolveUrl("~/Assets/images/gju-logo.png") %>" alt="" width="44" height="36" />
                <span><strong>UIMS</strong><small><%: L.T("Shared.Public.GermanJordanianUniversity") %></small></span>
            </a>
            <div class="nf-controls"><uims:LanguageSelector runat="server" /><uims:ThemeSelector runat="server" /></div>
        </header>
        <main id="not-found" class="nf-main" tabindex="-1">
            <div class="nf-message">
                <div class="nf-number" dir="ltr" aria-hidden="true">404<span class="nf-stop"></span></div>
                <span class="nf-visually-hidden"><%: L.T("Public.NotFound.Code") %></span>
                <h1><%: L.T("Public.NotFound.Heading") %></h1>
                <p class="nf-description"><%: L.T("Public.NotFound.Description") %></p>
                <div class="nf-actions">
                    <a class="public-button nf-action nf-home" href="<%: ResolveUrl("~/Default.aspx") %>"><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="m3 10 9-7 9 7M5 9v11h14V9M9 20v-7h6v7" /></svg><%: L.T("Public.NotFound.Home") %></a>
                    <a class="public-button nf-action nf-back" href="<%: ResolveUrl("~/Pages/Public/Contact.aspx") %>" data-nf-back data-home="<%: ResolveUrl("~/Default.aspx") %>" data-back-label="<%: L.T("Public.NotFound.Back") %>"><svg width="20" height="20" viewBox="0 0 24 24" aria-hidden="true"><path d="m10 5-7 7 7 7M3 12h18" /></svg><span><%: L.T("Public.NotFound.Contact") %></span></a>
                </div>
            </div>
        </main>
    </div>
</form>
<script src="<%: ResolveUrl("~/Assets/js/i18n.js?v=20261023-2") %>"></script>
<script src="<%: ResolveUrl("~/Assets/js/theme.js?v=20261023-4") %>"></script>
<script src="<%: ResolveUrl("~/Assets/js/not-found.js?v=20261023-1") %>"></script>
</body>
</html>
