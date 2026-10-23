<%@ Control Language="C#" %>
<%-- The active option is rendered by the server; both options stay as safe GET links through Localization.SwitchUrl. --%>
<script runat="server">
    public string Variant { get; set; }
    protected bool Inline { get { return string.Equals(Variant, "inline", StringComparison.OrdinalIgnoreCase); } }
</script>
<% var currentLang = L.IsArabic ? "ar" : "en"; %>
<% if (Inline) { %>
<div class="uims-lang-inline">
    <span class="uims-lang-inline-label" id="<%= ClientID %>_label"><%: L.T("Shared.Language.Label") %></span>
    <div class="uims-lang-control" role="group" aria-labelledby="<%= ClientID %>_label" data-current-lang="<%: currentLang %>">
<% } else { %>
<div class="uims-lang-control" role="group" aria-label="<%: L.T("Shared.Language.Label") %>" data-current-lang="<%: currentLang %>">
<% } %>
    <span class="uims-lang-indicator" aria-hidden="true"></span>
    <a class="uims-lang-option" href="<%: L.SwitchUrl("en") %>" lang="en" hreflang="en" data-lang-switch="en" title="<%: L.IsArabic ? L.T("Shared.Language.SwitchToEnglish") : L.T("Shared.Language.Label") %>" <%= !L.IsArabic ? "aria-current=\"page\"" : "" %>>EN</a>
    <a class="uims-lang-option" href="<%: L.SwitchUrl("ar") %>" lang="ar" hreflang="ar" data-lang-switch="ar" title="<%: L.IsArabic ? L.T("Shared.Language.Label") : L.T("Shared.Language.SwitchToArabic") %>" <%= L.IsArabic ? "aria-current=\"page\"" : "" %>>عربي</a>
</div>
<% if (Inline) { %>
</div>
<% } %>
