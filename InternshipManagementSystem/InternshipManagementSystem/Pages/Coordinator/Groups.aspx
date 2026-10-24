<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Groups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Groups" Title="Groups & Assignments" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div><div class="dir-crumb"><%: L.T("Coordinator.Groups.CoordinatorGroups") %></div><h2><asp:Label ID="lblEditorTitle" runat="server" Text="<%$ Resources:Coordinator, Groups.CreateGroup %>" /></h2><p><%: L.T("Coordinator.Groups.ChooseASupervisorAndAssignAvailable") %></p></div>
        </header>
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.Groups.GroupPages") %>">
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>"><%: L.T("Coordinator.Groups.CreateEditGroup") %></a>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>"><%: L.T("Coordinator.Groups.ConfiguredGroups") %></a>
        </nav>

        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <section class="dir-card" aria-labelledby="group-details-heading">
            <h3 class="dir-form-title" id="group-details-heading"><span data-ui-icon="people" aria-hidden="true"></span><%: L.T("Coordinator.Groups.GroupDetails") %></h3>
            <p class="dir-muted mb-3"><%: L.T("Coordinator.Groups.EachStudentCanBelongToOne") %></p>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtName.ClientID %>" class="form-label"><%: L.T("Coordinator.Groups.GroupName") %></label><asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-3"><label for="<%= txtAcademicYear.ClientID %>" class="form-label"><%: L.T("Coordinator.Groups.AcademicYearOptional") %></label><asp:TextBox ID="txtAcademicYear" runat="server" CssClass="form-control" MaxLength="30" /></div>
                <div class="col-md-3"><label for="<%= txtSemester.ClientID %>" class="form-label"><%: L.T("Coordinator.Groups.SemesterOptional") %></label><asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" MaxLength="40" /></div>
                <div class="col-12">
                    <span id="supervisorPickerLabel" class="form-label d-block"><%: L.T("Coordinator.Groups.AcademicSupervisor") %></span>
                    <div class="sp" data-supervisor-picker data-search-label="<%: L.T("Coordinator.AcademicSupervisors.SearchSupervisors") %>" data-empty-label="<%: L.T("Coordinator.AcademicSupervisors.NoSupervisorsMatchYourSearch") %>" data-clear-label="<%: L.T("Coordinator.Groups.ClearSelection") %>" data-done-label="<%: L.T("Coordinator.Groups.Done") %>">
                        <asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select" aria-labelledby="supervisorPickerLabel" />
                    </div>
                </div>

                <div class="col-12">
                    <span class="form-label d-block" id="spLabel"><%: L.T("Coordinator.Groups.Students") %></span>
                    <p class="small text-muted mb-2"><%: L.T("Coordinator.Groups.PickerHelp") %></p>
                    <% if (Choices.Count == 0) { %>
                    <p class="dir-muted"><%: L.T("Coordinator.Groups.NoAvailableStudents") %></p>
                    <% } else { %>
                    <div class="sp" data-student-picker>
                        <button type="button" class="sp-toggle" aria-expanded="false" aria-controls="spPanel" aria-labelledby="spLabel spSummary">
                            <span data-ui-icon="people" aria-hidden="true"></span>
                            <span class="sp-summary" id="spSummary" data-sp-summary><%: L.T("Coordinator.Groups.SelectStudents") %></span>
                            <span class="sp-badge" data-sp-count>0</span>
                            <span class="sp-caret" aria-hidden="true"></span>
                        </button>
                        <div class="sp-panel" id="spPanel" hidden>
                            <div class="sp-tools">
                                <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.Groups.SearchStudents") %></span><span data-ui-icon="search" aria-hidden="true"></span><input type="search" class="form-control" data-sp-search autocomplete="off" placeholder="<%: L.T("Coordinator.Groups.SearchStudents") %>" /></label>
                                <label><span class="visually-hidden"><%: L.T("Coordinator.ManageStudents.Major") %></span><select class="form-select" data-sp-filter="major">
                                    <option value=""><%: L.T("Coordinator.ManageStudents.AllMajors") %></option>
                                    <% foreach (var program in AcademicPrograms.All) { %><option value="<%: program.Key %>"><%: program.Name %></option><% } %>
                                    <option value="<%: AcademicPrograms.MissingKey %>"><%: L.T("Coordinator.ManageStudents.FilterMissingMajor") %></option>
                                    <option value="<%: AcademicPrograms.UnrecognizedKey %>"><%: L.T("Coordinator.ManageStudents.FilterUnrecognizedMajor") %></option>
                                </select></label>
                                <label><span class="visually-hidden"><%: L.T("Coordinator.ManageStudents.Status") %></span><select class="form-select" data-sp-filter="status">
                                    <option value=""><%: L.T("Coordinator.ManageStudents.AllStatuses") %></option>
                                    <option value="active"><%: L.T("Coordinator.ManageStudents.StatusActive") %></option>
                                    <option value="inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></option>
                                </select></label>
                            </div>
                            <div class="sp-bulk">
                                <label class="sp-all"><input type="checkbox" class="form-check-input" data-sp-all /> <span><%: L.T("Coordinator.Groups.SelectAllShown") %></span> <span class="sp-shown">(<span data-sp-shown><%: Choices.Count %></span>)</span></label>
                                <button type="button" class="sp-link" data-sp-clear><%: L.T("Coordinator.Groups.ClearSelection") %></button>
                            </div>
                            <ul class="sp-list">
                                <% foreach (var c in Choices) { %>
                                <li data-sp-item data-search="<%: c.SearchText %>" data-major="<%: c.MajorKey %>" data-status="<%: c.IsActive ? "active" : "inactive" %>">
                                    <label>
                                        <input type="checkbox" class="form-check-input" name="groupStudents" value="<%: c.Id %>" data-name="<%: c.FullName %>"<%= c.Selected ? " checked" : "" %> />
                                        <span class="dir-avatar" aria-hidden="true"><%: c.Initials %></span>
                                        <span class="sp-name"><strong><%: c.FullName %></strong><small><span class="dir-id" title="<%: c.StudentNumber %>"><%: L.T("Coordinator.Groups.IdLabel") %> <%: c.StudentNumber %></span> <%: c.Email %> · <%: c.Major %></small></span>
                                        <% if (!c.IsActive) { %><span class="dir-status is-inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></span><% } %>
                                    </label>
                                </li>
                                <% } %>
                            </ul>
                            <p class="sp-empty" data-sp-empty hidden><%: L.T("Coordinator.ManageStudents.NoStudentsMatchYourSearch") %></p>
                            <div class="sp-foot"><button type="button" class="btn btn-brand btn-sm" data-sp-done><%: L.T("Coordinator.Groups.Done") %></button></div>
                        </div>
                        <ul class="sp-chips" data-sp-chips aria-live="polite"></ul>
                    </div>
                    <% } %>
                </div>

                <div class="col-12 d-flex gap-2 pt-2">
                    <asp:Button ID="btnSave" runat="server" Text="<%$ Resources:Coordinator, Groups.CreateGroup %>" CssClass="btn btn-brand" OnClick="btnSave_Click"  data-ui-action="create" data-loading-label="Creating…"/>
                    <asp:Button ID="btnCancel" runat="server" Text="<%$ Resources:Coordinator, Groups.CancelEdit %>" CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" CausesValidation="false" Visible="false" />
                </div>
            </div>
        </section>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script>
        // Enhance the server dropdown with the same visual components as the student picker.
        // Its original select still owns the posted value, validation and edit selection.
        document.addEventListener('DOMContentLoaded', function () {
            var picker = document.querySelector('[data-supervisor-picker]');
            if (!picker) return;
            var select = picker.querySelector('select');
            var placeholder = select.options[0].textContent;
            var t = window.uimsT || function (key) { return key; };
            function make(tag, className, text) {
                var node = document.createElement(tag);
                node.className = className || '';
                if (text !== undefined) node.textContent = text;
                return node;
            }
            function button(className, text) {
                var node = make('button', className, text);
                node.type = 'button';
                return node;
            }
            var toggle = button('sp-toggle');
            toggle.setAttribute('aria-expanded', 'false');
            toggle.setAttribute('aria-controls', 'supervisorPickerPanel');
            toggle.setAttribute('aria-labelledby', 'supervisorPickerLabel supervisorPickerSummary');
            var icon = make('span');
            icon.dataset.uiIcon = 'people';
            icon.setAttribute('aria-hidden', 'true');
            var summary = make('span', 'sp-summary', placeholder);
            summary.id = 'supervisorPickerSummary';
            var count = make('span', 'sp-badge', '0');
            var caret = make('span', 'sp-caret');
            caret.setAttribute('aria-hidden', 'true');
            toggle.append(icon, summary, count, caret);
            var panel = make('div', 'sp-panel');
            panel.id = 'supervisorPickerPanel';
            panel.hidden = true;
            var tools = make('div', 'sp-tools');
            var searchLabel = make('label', 'dir-search');
            var search = make('input', 'form-control');
            search.type = 'search';
            search.autocomplete = 'off';
            search.placeholder = picker.dataset.searchLabel;
            searchLabel.append(make('span', 'visually-hidden', picker.dataset.searchLabel), search);
            tools.append(searchLabel);
            var bulk = make('div', 'sp-bulk');
            var clear = button('sp-link', picker.dataset.clearLabel);
            bulk.append(clear);
            var list = make('ul', 'sp-list');
            list.setAttribute('role', 'radiogroup');
            list.setAttribute('aria-labelledby', 'supervisorPickerLabel');
            var items = Array.prototype.slice.call(select.options).filter(function (option) { return option.value; }).map(function (option) {
                var item = make('li'), label = make('label');
                var split = option.textContent.lastIndexOf(' (');
                var name = split >= 0 ? option.textContent.slice(0, split) : option.textContent;
                var email = split >= 0 ? option.textContent.slice(split + 2, -1) : '';
                var radio = make('input', 'form-check-input');
                radio.type = 'radio';
                radio.name = 'supervisorPickerChoice';
                radio.value = option.value;
                var initials = name.trim().split(/\s+/).slice(0, 2).map(function (part) { return part.charAt(0); }).join('').toUpperCase();
                var avatar = make('span', 'dir-avatar', initials);
                avatar.setAttribute('aria-hidden', 'true');
                var text = make('span', 'sp-name');
                text.append(make('strong', '', name), make('small', '', email));
                label.append(radio, avatar, text);
                item.append(label);
                list.append(item);
                radio.addEventListener('change', function () {
                    select.value = option.value;
                    select.dispatchEvent(new Event('change', {bubbles: true}));
                    open(false);
                    toggle.focus();
                });
                return {node:item, radio:radio, value:option.value, name:name, search:option.textContent.toLowerCase()};
            });
            var empty = make('p', 'sp-empty', picker.dataset.emptyLabel);
            empty.setAttribute('role', 'status');
            var footer = make('div', 'sp-foot');
            var done = button('btn btn-brand btn-sm', picker.dataset.doneLabel);
            footer.append(done);
            panel.append(tools, bulk, list, empty, footer);
            var chips = make('ul', 'sp-chips');
            chips.setAttribute('aria-live', 'polite');
            function open(state) {
                panel.hidden = !state;
                toggle.setAttribute('aria-expanded', String(state));
                picker.classList.toggle('is-open', state);
                if (state) { search.value = ''; filter(); search.focus(); }
            }
            function filter() {
                var query = search.value.trim().toLowerCase();
                items.forEach(function (item) { item.node.hidden = !!query && item.search.indexOf(query) < 0; });
                empty.hidden = items.some(function (item) { return !item.node.hidden; });
            }
            function sync() {
                var selected = items.find(function (item) { return item.value === select.value; });
                items.forEach(function (item) { item.radio.checked = item === selected; });
                summary.textContent = selected ? selected.name : placeholder;
                count.textContent = selected ? '1' : '0';
                picker.classList.toggle('has-selection', !!selected);
                chips.replaceChildren();
                if (selected) {
                    var chip = make('li', '', selected.name), remove = button('', '×');
                    remove.setAttribute('aria-label', t('GroupPickerRemove', selected.name));
                    remove.addEventListener('click', function () { clearSelection(); toggle.focus(); });
                    chip.append(remove);
                    chips.append(chip);
                }
            }
            function clearSelection() { select.value = ''; select.dispatchEvent(new Event('change', {bubbles:true})); }
            toggle.addEventListener('click', function () { open(panel.hidden); });
            clear.addEventListener('click', clearSelection);
            done.addEventListener('click', function () { open(false); toggle.focus(); });
            search.addEventListener('input', filter);
            search.addEventListener('keydown', function (event) { if (event.key === 'Enter') event.preventDefault(); });
            select.addEventListener('change', sync);
            document.addEventListener('click', function (event) { if (!panel.hidden && !picker.contains(event.target)) open(false); });
            document.addEventListener('keydown', function (event) { if (event.key === 'Escape' && !panel.hidden) { open(false); toggle.focus(); } });
            picker.append(toggle, panel, chips);
            select.hidden = true;
            filter();
            sync();
            if (window.UimsUI) window.UimsUI.refresh(picker);
        });
        /* Student picker: a drop-down list with search, filters, select all and chips. */
        document.addEventListener('DOMContentLoaded', function () {
            var picker = document.querySelector('[data-student-picker]');
            if (!picker) return;
            var toggle = picker.querySelector('.sp-toggle'), panel = picker.querySelector('.sp-panel');
            var search = picker.querySelector('[data-sp-search]'), filters = picker.querySelectorAll('[data-sp-filter]');
            var items = Array.prototype.slice.call(picker.querySelectorAll('[data-sp-item]'));
            var all = picker.querySelector('[data-sp-all]'), chips = picker.querySelector('[data-sp-chips]');
            var summary = picker.querySelector('[data-sp-summary]'), count = picker.querySelector('[data-sp-count]');
            var shownLabel = picker.querySelector('[data-sp-shown]'), empty = picker.querySelector('[data-sp-empty]');
            var t = window.uimsT || function (k) { return k; };
            var placeholder = summary.textContent;

            function box(item) { return item.querySelector('input[type="checkbox"]'); }
            function visible() { return items.filter(function (i) { return !i.hidden; }); }

            function open(state) {
                panel.hidden = !state;
                toggle.setAttribute('aria-expanded', state ? 'true' : 'false');
                picker.classList.toggle('is-open', state);
                if (state) search.focus();
            }

            function filter() {
                var q = search.value.trim().toLowerCase();
                items.forEach(function (item) {
                    var match = !q || item.dataset.search.indexOf(q) >= 0;
                    filters.forEach(function (f) { if (match && f.value && item.dataset[f.dataset.spFilter] !== f.value) match = false; });
                    item.hidden = !match;
                });
                var shown = visible();
                shownLabel.textContent = shown.length;
                empty.hidden = shown.length > 0;
                sync();
            }

            function sync() {
                var selected = items.filter(function (i) { return box(i).checked; });
                count.textContent = selected.length;
                picker.classList.toggle('has-selection', selected.length > 0);
                summary.textContent = selected.length === 0 ? placeholder
                    : selected.length === 1 ? box(selected[0]).dataset.name
                    : t('GroupPickerSelected', selected.length);
                var shown = visible(), checked = shown.filter(function (i) { return box(i).checked; }).length;
                all.checked = shown.length > 0 && checked === shown.length;
                all.indeterminate = checked > 0 && checked < shown.length;
                chips.replaceChildren();
                selected.forEach(function (item) {
                    var input = box(item), li = document.createElement('li'), remove = document.createElement('button');
                    li.textContent = input.dataset.name;
                    remove.type = 'button';
                    remove.setAttribute('aria-label', t('GroupPickerRemove', input.dataset.name));
                    remove.textContent = '×';
                    remove.addEventListener('click', function () { input.checked = false; sync(); });
                    li.append(remove);
                    chips.append(li);
                });
            }

            toggle.addEventListener('click', function () { open(panel.hidden); });
            picker.querySelector('[data-sp-done]').addEventListener('click', function () { open(false); toggle.focus(); });
            picker.querySelector('[data-sp-clear]').addEventListener('click', function () { items.forEach(function (i) { box(i).checked = false; }); sync(); });
            all.addEventListener('change', function () { visible().forEach(function (i) { box(i).checked = all.checked; }); sync(); });
            items.forEach(function (i) { box(i).addEventListener('change', sync); });
            search.addEventListener('input', filter);
            filters.forEach(function (f) { f.addEventListener('change', filter); });
            // Enter in the search box must not submit the form.
            search.addEventListener('keydown', function (e) { if (e.key === 'Enter') e.preventDefault(); });
            document.addEventListener('click', function (e) { if (!panel.hidden && !picker.contains(e.target)) open(false); });
            document.addEventListener('keydown', function (e) { if (e.key === 'Escape' && !panel.hidden) { open(false); toggle.focus(); } });
            filter();
        });
    </script>
</asp:Content>
