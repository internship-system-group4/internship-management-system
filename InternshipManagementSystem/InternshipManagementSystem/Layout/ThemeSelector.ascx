<%@ Control Language="C#" %>
<%-- Light / Dark / System selector (Assets/js/theme.js). Plain buttons with type="button", so it never submits the
     Web Forms form. Variant="menu": an icon button with a menu of three radio items (navbar, portal header).
     Variant="inline": a labelled radio group of three choices (mobile navigation). Without JavaScript it stays hidden
     and the site keeps the default Light theme. --%>
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
        <button type="button" role="radio" aria-checked="false" data-theme-value="system"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="4" width="18" height="12" rx="2" /><path d="M8 20h8M12 16v4" /></svg><%: L.T("Shared.ThemeSelector.System") %></button>
    </div>
</div>
<% } else { %>
<div class="uims-theme" data-theme-control="menu" hidden>
    <button type="button" class="uims-theme-button" aria-haspopup="menu" aria-expanded="false" aria-controls="<%= ClientID %>_menu" aria-label="<%: L.T("Shared.ThemeSelector.ColourThemeLight") %>" title="<%: L.T("Shared.ThemeSelector.ColourTheme") %>" data-theme-toggle>
        <svg data-theme-icon="light" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4" /><path d="M12 2.5v2M12 19.5v2M4.6 4.6l1.4 1.4M18 18l1.4 1.4M2.5 12h2M19.5 12h2M4.6 19.4 6 18M18 6l1.4-1.4" /></svg>
        <svg data-theme-icon="dark" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg>
        <svg data-theme-icon="system" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="4" width="18" height="12" rx="2" /><path d="M8 20h8M12 16v4" /></svg>
    </button>
    <ul class="uims-theme-menu" id="<%= ClientID %>_menu" role="menu" aria-label="<%: L.T("Shared.ThemeSelector.ColourTheme") %>" hidden>
        <li role="none"><button type="button" class="uims-theme-option" role="menuitemradio" aria-checked="false" tabindex="-1" data-theme-value="light"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><circle cx="12" cy="12" r="4" /><path d="M12 2.5v2M12 19.5v2M4.6 4.6l1.4 1.4M18 18l1.4 1.4M2.5 12h2M19.5 12h2M4.6 19.4 6 18M18 6l1.4-1.4" /></svg><%: L.T("Shared.ThemeSelector.Light") %><svg class="uims-theme-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg></button></li>
        <li role="none"><button type="button" class="uims-theme-option" role="menuitemradio" aria-checked="false" tabindex="-1" data-theme-value="dark"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="M20 14.5A8 8 0 0 1 9.5 4a8 8 0 1 0 10.5 10.5z" /></svg><%: L.T("Shared.ThemeSelector.Dark") %><svg class="uims-theme-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg></button></li>
        <li role="none"><button type="button" class="uims-theme-option" role="menuitemradio" aria-checked="false" tabindex="-1" data-theme-value="system"><svg viewBox="0 0 24 24" aria-hidden="true" focusable="false"><rect x="3" y="4" width="18" height="12" rx="2" /><path d="M8 20h8M12 16v4" /></svg><%: L.T("Shared.ThemeSelector.System") %><svg class="uims-theme-check" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path d="m5 12.5 4.5 4.5L19 7.5" /></svg></button></li>
    </ul>
</div>
<% } %>
