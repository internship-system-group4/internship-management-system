<%@ Control Language="C#" %>
<%-- Direct language toggle: preserve the existing safe server GET and unsaved-input guard. --%>
<script runat="server">
    public string Variant { get; set; }
    protected bool Inline { get { return string.Equals(Variant, "inline", StringComparison.OrdinalIgnoreCase); } }
</script>
<% var targetLang = L.IsArabic ? "en" : "ar";
   var switchLabel = L.T(L.IsArabic ? "Shared.Language.SwitchToEnglish" : "Shared.Language.SwitchToArabic"); %>
<% if (Inline) { %>
<div class="uims-lang-inline">
    <span class="uims-lang-inline-label"><%: L.T("Shared.Language.Label") %></span>
<% } %>
<a class="uims-lang-control" href="<%: L.SwitchUrl(targetLang) %>" data-current-lang="<%: L.Lang %>" lang="<%: targetLang %>" hreflang="<%: targetLang %>" data-lang-switch="<%: targetLang %>" aria-label="<%: switchLabel %>" title="<%: switchLabel %>"><%: L.IsArabic ? "EN" : "AR" %></a>
<% if (Inline) { %>
</div>
<% } %>
