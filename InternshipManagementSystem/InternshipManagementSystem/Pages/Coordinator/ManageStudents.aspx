<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ManageStudents.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ManageStudents" Title="Manage students" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>
<%@ Register Src="StudentCreation.ascx" TagPrefix="uims" TagName="StudentCreation" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261024-perf") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div>
                <div class="dir-crumb"><%: L.T("Coordinator.ManageStudents.CoordinatorStudents") %></div>
                <h2><%: L.T("Coordinator.ManageStudents.ManageStudents") %></h2>
                <p><%: L.T("Coordinator.ManageStudents.DirectoryIntro") %></p>
            </div>
            <button type="button" class="btn btn-brand dir-add" data-bs-toggle="modal" data-bs-target="#addStudentModal"><span data-ui-icon="plus" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.AddStudent2") %></button>
        </header>
        <uims:StudentCreation ID="StudentCreator" runat="server" OnCreated="StudentCreator_Created" />
        <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />

        <section class="dir-card" aria-labelledby="dirHeading" data-dir>
            <div class="dir-toolbar">
                <div class="dir-title"><h3 id="dirHeading"><%: L.T("Coordinator.ManageStudents.StudentDirectory") %> <span class="dir-count" data-dir-count><%: Rows.Count %></span></h3><p><%: L.T("Coordinator.ManageStudents.DirectoryHelp") %></p></div>
                <div class="dir-filters">
                    <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.ManageStudents.SearchStudentsToManage") %></span><span data-ui-icon="search" aria-hidden="true"></span><input type="search" class="form-control" data-dir-search autocomplete="off" placeholder="<%: L.T("Coordinator.ManageStudents.SearchStudents") %>" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ManageStudents.Major") %></span><select class="form-select" data-dir-filter="major">
                        <option value=""><%: L.T("Coordinator.ManageStudents.AllMajors") %></option>
                        <% foreach (var program in AcademicPrograms.All) { %><option value="<%: program.Key %>"<%= MajorFilter == program.Key ? " selected" : "" %>><%: program.Name %></option><% } %>
                        <option value="<%: AcademicPrograms.MissingKey %>"<%= MajorFilter == AcademicPrograms.MissingKey ? " selected" : "" %>><%: L.T("Coordinator.ManageStudents.FilterMissingMajor") %></option>
                        <option value="<%: AcademicPrograms.UnrecognizedKey %>"<%= MajorFilter == AcademicPrograms.UnrecognizedKey ? " selected" : "" %>><%: L.T("Coordinator.ManageStudents.FilterUnrecognizedMajor") %></option>
                    </select></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ManageStudents.Status") %></span><select class="form-select" data-dir-filter="status">
                        <option value=""><%: L.T("Coordinator.ManageStudents.AllStatuses") %></option>
                        <option value="active"><%: L.T("Coordinator.ManageStudents.StatusActive") %></option>
                        <option value="inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></option>
                    </select></label>
                </div>
            </div>

            <div class="table-responsive">
                <table class="dir-table">
                    <thead><tr><th scope="col"><%: L.T("Coordinator.ManageStudents.Student") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.StudentNumber") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.Major") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.TrainingHours") %></th><th scope="col"><%: L.T("Coordinator.ManageStudents.Status") %></th><th scope="col" class="dir-actions-col"><%: L.T("Coordinator.ManageStudents.Action") %></th></tr></thead>
                    <tbody><asp:Repeater ID="rptStudents" runat="server"><ItemTemplate>
                        <tr data-dir-row data-search="<%#: ((StudentDirectoryRow)Container.DataItem).SearchText %>" data-major="<%#: ((StudentDirectoryRow)Container.DataItem).MajorKey %>" data-status="<%# ((StudentDirectoryRow)Container.DataItem).IsActive ? "active" : "inactive" %>" style="--dir-i:<%# Container.ItemIndex %>">
                            <td><div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: ((StudentDirectoryRow)Container.DataItem).Initials %></span><div><strong><%#: ((StudentDirectoryRow)Container.DataItem).FullName %></strong><small><%#: ((StudentDirectoryRow)Container.DataItem).Email %></small></div></div></td>
                            <td><span class="dir-id" title="<%#: ((StudentDirectoryRow)Container.DataItem).StudentNumber %>"><%#: ((StudentDirectoryRow)Container.DataItem).StudentNumber %></span></td>
                            <td><%#: ((StudentDirectoryRow)Container.DataItem).Major %></td>
                            <td><div class="dir-hours"><div class="dir-progress" aria-hidden="true"><span style="--dir-p:<%# ((StudentDirectoryRow)Container.DataItem).HoursPercent %>%"></span></div><small><%#: ((StudentDirectoryRow)Container.DataItem).HoursText %></small></div></td>
                            <td><span class='<%# ((StudentDirectoryRow)Container.DataItem).IsActive ? "dir-status is-active" : "dir-status is-inactive" %>'><%#: ((StudentDirectoryRow)Container.DataItem).StatusText %></span></td>
                            <td><div class="dir-actions">
                                <button type="button" class="dir-btn" data-dir-view="<%# Container.ItemIndex %>" aria-haspopup="dialog"><span data-ui-icon="eye" aria-hidden="true"></span> <%# L.T("Coordinator.ManageStudents.ViewDetails") %><span class="visually-hidden">: <%#: ((StudentDirectoryRow)Container.DataItem).FullName %></span></button>
                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="dir-btn dir-btn-primary" CommandArgument='<%# ((StudentDirectoryRow)Container.DataItem).Id %>' OnClick="btnEdit_Click" CausesValidation="false"><span data-ui-icon="edit" aria-hidden="true"></span> <%# L.T("Coordinator.ManageStudents.Manage") %></asp:LinkButton>
                            </div></td>
                        </tr>
                    </ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <p class="dir-empty" data-dir-empty hidden><span data-ui-icon="search" aria-hidden="true"></span><%: L.T("Coordinator.ManageStudents.NoStudentsMatchYourSearch") %></p>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="dir-empty" />
            <script type="application/json" data-dir-data><%= RowsJson %></script>
        </section>

        <%-- View details: filled in the browser from the row data, no postback. --%>
        <div class="modal fade dir-modal" id="studentViewModal" tabindex="-1" aria-labelledby="studentViewTitle" aria-hidden="true" data-dir-view-modal>
            <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable"><div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" data-field="Initials" aria-hidden="true"></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.ManageStudents.StudentDetails") %></span><h3 class="modal-title" id="studentViewTitle" data-field="FullName"></h3><p><span data-field="Email"></span> <span class="dir-status" data-field="StatusText" data-status-field="IsActive"></span></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ManageStudents.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <div class="dir-hours-card">
                        <div><span class="dir-label"><%: L.T("Coordinator.ManageStudents.TrainingHours") %></span><strong data-field="HoursText"></strong></div>
                        <div class="dir-progress dir-progress-lg" aria-hidden="true"><span data-field-progress="HoursPercent"></span></div>
                    </div>
                    <div class="dir-info-grid">
                        <section><h4><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.ManageStudents.PersonalInformation") %></h4><dl>
                            <div><dt><%: L.T("Coordinator.ManageStudents.StudentID") %></dt><dd class="dir-id" data-field="StudentNumber"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.LoginEmail") %></dt><dd data-field="Email"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.Phone") %></dt><dd data-field="Phone"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.CreatedOn") %></dt><dd data-field="CreatedText"></dd></div>
                        </dl></section>
                        <section><h4><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.ManageStudents.AcademicInformation") %></h4><dl>
                            <div><dt><%: L.T("Coordinator.ManageStudents.University") %></dt><dd data-field="University"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.College") %></dt><dd data-field="College"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.Major") %></dt><dd data-field="Major"></dd></div>
                        </dl></section>
                        <section class="dir-info-wide"><h4><span data-ui-icon="briefcase" aria-hidden="true"></span><%: L.T("Coordinator.ManageStudents.TrainingAndSupervision") %></h4><dl class="dir-dl-3">
                            <div><dt><%: L.T("Coordinator.ManageStudents.Group") %></dt><dd data-field="GroupName"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.AcademicSupervisor") %></dt><dd data-field="SupervisorName"></dd></div>
                            <div><dt><%: L.T("Coordinator.ManageStudents.Placement") %></dt><dd data-field="PlacementText"></dd></div>
                        </dl></section>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.ManageStudents.Close") %></button>
                    <a class="btn btn-brand" data-field-href="ProfileUrl" href="#"><span data-ui-icon="person" aria-hidden="true"></span> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></a>
                </div>
            </div></div>
        </div>

        <%-- Manage: edit academic details and account access (server side). --%>
        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade dir-modal" ClientIDMode="Static" tabindex="-1" aria-labelledby="studentModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg"><div class="modal-content">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><asp:Literal ID="litInitials" runat="server" /></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.ManageStudents.ManageStudent") %></span><h3 class="modal-title" id="studentModalTitle"><asp:Label ID="lblStudentName" runat="server" /></h3><p><asp:Label ID="lblStudentEmail" runat="server" /></p></div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ManageStudents.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <h4 class="dir-form-title"><span data-ui-icon="study" aria-hidden="true"></span><%: L.T("Coordinator.ManageStudents.AcademicInformation") %></h4>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditStudentNumber.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.StudentID") %></label><asp:TextBox ID="txtEditStudentNumber" runat="server" CssClass="form-control" ReadOnly="true" /><small class="text-muted"><%: L.T("Coordinator.ManageStudents.AssignedWhenTheAccountIsCreated") %></small></div>
                        <div class="col-md-6"><label for="<%= txtEditRequiredHours.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.RequiredTrainingHours") %></label><asp:TextBox ID="txtEditRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
                        <div class="col-md-6"><label for="<%= txtEditUniversity.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.University") %></label><asp:TextBox ID="txtEditUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditCollege.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.College") %></label><asp:TextBox ID="txtEditCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= ddlEditMajor.ClientID %>" class="form-label"><%: L.T("Coordinator.ManageStudents.Major") %></label><asp:DropDownList ID="ddlEditMajor" runat="server" CssClass="form-select" /></div>
                    </div>
                    <div class="dir-access"><div><h4><%: L.T("Coordinator.ManageStudents.AccountAccess") %></h4><p><asp:Label ID="lblAccessDescription" runat="server" /></p></div><asp:Button ID="btnToggleAccess" runat="server" CausesValidation="false" OnClick="btnToggleAccess_Click"  data-ui-action="update" data-loading-label="Updating…" data-ui-validation="none"/></div>
                </div>
                <div class="modal-footer"><asp:HyperLink ID="lnkRecord" runat="server" CssClass="btn btn-outline-primary me-auto" /><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal"><%: L.T("Coordinator.ManageStudents.Close") %></button><asp:Button ID="btnSaveDetails" runat="server" Text="<%$ Resources:Coordinator, ManageStudents.SaveChanges %>" CssClass="btn btn-brand" OnClick="btnSaveDetails_Click"  data-ui-action="save" data-loading-label="Saving…"/></div>
            </div></div>
        </asp:Panel>
    </div>
</asp:Content>
<asp:Content ID="Scripts" ContentPlaceHolderID="scripts" runat="server">
    <script src="<%= ResolveUrl("~/Assets/js/directory.js?v=20261024-1") %>" defer></script>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            var modal = document.getElementById('pnlDetails');
            var creating = document.querySelector('.creation-modal[data-open-on-load="true"]');
            if (modal && window.bootstrap && !creating) new bootstrap.Modal(modal).show();
        });
    </script>
</asp:Content>
