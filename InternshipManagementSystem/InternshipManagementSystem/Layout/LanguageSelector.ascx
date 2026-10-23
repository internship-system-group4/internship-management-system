<%@ Control Language="C#" %>
<%-- English / العربية selector (Common/Localization.cs). Plain GET links to the same page with ?ui-lang=; Global.asax
     saves the choice and redirects back, so nothing is submitted and no POST is replayed. Assets/js/i18n.js asks for
     confirmation first when a form on the page has unsaved changes. Variant="link" shows the other language (navbar,
     portal header); Variant="inline" shows both (mobile navigation). Language names are written in their own language. --%>
<script runat="server">
    public string Variant { get; set; }
    protected bool Inline { get { return string.Equals(Variant, "inline", StringComparison.OrdinalIgnoreCase); } }
</script>
<% if (Inline) { %>
<div class="uims-lang-inline" role="group" aria-labelledby="<%= ClientID %>_label">
    <span class="uims-lang-inline-label" id="<%= ClientID %>_label"><%: L.T("Shared.Language.Label") %></span>
    <div>
        <a href="<%: L.SwitchUrl("en") %>" lang="en" hreflang="en" data-lang-switch="en" <%= L.IsArabic ? "" : "aria-current=\"true\"" %>>English</a>
        <a href="<%: L.SwitchUrl("ar") %>" lang="ar" hreflang="ar" data-lang-switch="ar" <%= L.IsArabic ? "aria-current=\"true\"" : "" %>>العربية</a>
    </div>
</div>
<% } else if (L.IsArabic) { %>
<a class="uims-lang-link" href="<%: L.SwitchUrl("en") %>" hreflang="en" data-lang-switch="en" title="<%: L.T("Shared.Language.SwitchToEnglish") %>"><span class="visually-hidden"><%: L.T("Shared.Language.Label") %>: </span><span lang="en">English</span></a>
<% } else { %>
<a class="uims-lang-link" href="<%: L.SwitchUrl("ar") %>" hreflang="ar" data-lang-switch="ar" title="<%: L.T("Shared.Language.SwitchToArabic") %>"><span class="visually-hidden"><%: L.T("Shared.Language.Label") %>: </span><span lang="ar">العربية</span></a>
<% } %>
