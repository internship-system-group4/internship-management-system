<%@ Control Language="C#" %>
<%-- Light/Dark controls share the existing saved theme and circular reveal. Buttons never submit the Web Forms form. --%>
<script runat="server">
    public string Variant { get; set; }
    protected bool Inline { get { return string.Equals(Variant, "inline", StringComparison.OrdinalIgnoreCase); } }
</script>
<% if (Inline) { %>
<div class="uims-theme-inline" data-theme-control="inline" hidden>
    <span class="uims-theme-inline-label" id="<%= ClientID %>_label"><%: L.T("Shared.ThemeSelector.Theme") %></span>
    <div role="radiogroup" aria-labelledby="<%= ClientID %>_label">
        <button type="button" role="radio" aria-checked="false" data-theme-value="light"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4" /><path d="M12 2.5v2M12 19.5v2M4.6 4.6l1.4 1.4M18 18l1.4 1.4M2.5 12h2M19.5 12h2M4.6 19.4 6 18M18 6l1.4-1.4" /></svg><%: L.T("Shared.ThemeSelector.Light") %></button>
        <button type="button" role="radio" aria-checked="false" data-theme-value="dark"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg><%: L.T("Shared.ThemeSelector.Dark") %></button>
    </div>
</div>
<% } else { %>
<div class="uims-theme" data-theme-control="toggle" hidden>
    <button type="button" class="uims-theme-button" aria-pressed="false" aria-label="<%: L.T("Shared.ThemeSelector.Dark") %>" title="<%: L.T("Shared.ThemeSelector.ColourTheme") %>" data-theme-toggle>
        <svg data-theme-icon="light" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4" /><path d="M12 2.5v2M12 19.5v2M4.6 4.6l1.4 1.4M18 18l1.4 1.4M2.5 12h2M19.5 12h2M4.6 19.4 6 18M18 6l1.4-1.4" /></svg>
        <svg data-theme-icon="dark" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg>
    </button>
</div>
<% } %>
