<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ManageStudents.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ManageStudents" Title="Manage students" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>
<%@ Register Src="StudentCreation.ascx" TagPrefix="uims" TagName="StudentCreation" %>
<%@ Import Namespace="InternshipManagementSystem.Common" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css?v=20261024-theme-7") %>" />
    <style>
        .sidebar, aside { display: flex; flex-direction: column; height: 100vh; }
        .sidebar-menu { flex-grow: 1; overflow-y: auto; }
        .logout-container, .logout-box { margin-top: auto !important; border-top: 1px solid var(--th-line-e3e8ee,#e3e8ee); padding-top: 1rem; }

        /* الألوان الموحدة مع الداشبورد */
        .text-brand { color: var(--th-fg-0f4c81,#0f4c81) !important; }
        .bg-brand { background-color: var(--th-bg-0f4c81,#0f4c81) !important; color: white; border: none; transition: 0.2s; }
        .bg-brand:hover { background-color: var(--th-bg-0a365c,#0a365c) !important; color: white; transform: translateY(-1px); }

        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 0.75rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--ui-muted); font-size: 0.7rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 0.75rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-334155,#334155); font-size: 0.8rem; font-weight: 500; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        .btn-table-action { background-color: var(--th-bg-f1f5f9,#f1f5f9); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 600; padding: 5px 12px; border-radius: 50px; border: 1px solid var(--th-line-e2e8f0,#e2e8f0); transition: 0.2s; text-decoration: none; display: inline-flex; align-items: center; justify-content: center; gap: 5px; font-size: 0.75rem; }
        .btn-table-action:hover { background-color: var(--th-bg-0f4c81,#0f4c81); color: white; border-color: var(--th-line-0f4c81,#0f4c81); }

        .view-label { font-size: 0.7rem; color: var(--ui-muted); text-transform: uppercase; font-weight: 700; margin-bottom: 0.2rem; }
        .view-value { font-size: 0.9rem; color: var(--th-fg-1e293b,#1e293b); font-weight: 600; margin-bottom: 1rem; border-bottom: 1px dashed var(--th-line-e2e8f0,#e2e8f0); padding-bottom: 0.4rem; word-wrap: break-word; overflow-wrap: break-word; }

        .filter-group .form-control, .filter-group .form-select { border-radius: 6px; font-size: 0.8rem; border-color: var(--th-line-e2e8f0,#e2e8f0); color: var(--th-fg-1d2733,#1d2733); padding: 0.4rem 0.75rem; }
        .filter-group .form-control:focus, .filter-group .form-select:focus { border-color: var(--th-bg-0f4c81,#0f4c81); box-shadow: none; }
        .filter-group .input-group-text { background-color: transparent; border-radius: 6px 0 0 6px; border-color: var(--th-line-e2e8f0,#e2e8f0); padding: 0.4rem 0.75rem; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <uims:StudentCreation ID="StudentCreator" runat="server" OnCreated="StudentCreator_Created" />
    <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" CssClass="alert alert-info d-block m-3" />

    <div class="container-fluid px-3 py-3 dir-page" data-dir>

        <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
            <div>
                <div class="text-muted small mb-1" style="font-size:0.75rem;"><%: L.T("Coordinator.ManageStudents.CoordinatorStudents") %> <span class="text-dark fw-semibold"><%: L.T("Coordinator.ManageStudents.ManageStudents") %></span></div>
                <h2 class="fw-bold text-brand mb-0 fs-4"><%: L.T("Coordinator.ManageStudents.ManageStudents") %></h2>
                <p class="text-muted small mt-1 mb-0" style="font-size:0.75rem;"><%: L.T("Coordinator.ManageStudents.DirectoryIntro") %></p>
            </div>
            <!-- زر الإضافة بلون الداشبورد الموحد -->
            <button type="button" class="btn bg-brand px-3 py-2 rounded-pill shadow-sm" style="font-size:0.85rem;" data-bs-toggle="modal" data-bs-target="#addStudentModal">
                <i class="bi bi-plus-lg me-2"></i><%: L.T("Coordinator.ManageStudents.AddStudent2") %>
            </button>
        </div>

        <div class="card border-0 shadow-sm rounded-4 p-3">
            <div class="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
                <div class="d-flex align-items-center gap-2">
                    <h5 class="fw-bold text-brand mb-0 fs-5"><%: L.T("Coordinator.ManageStudents.StudentDirectory") %></h5>
                    <span class="badge bg-light text-dark border rounded-pill text-muted px-2 py-1" data-dir-count><%: Rows.Count %></span>
                </div>
                <button type="button" id="btnToggleTable" class="btn btn-sm btn-light border rounded-pill px-3 fw-bold text-muted d-flex align-items-center" data-bs-toggle="collapse" data-bs-target="#tableCollapse" aria-expanded="true">
                    <i class="bi bi-eye-slash-fill me-1"></i><span class="toggle-text"><%: L.T("Coordinator.Companies.HideList") %></span>
                </button>
            </div>

            <div class="filter-group d-flex flex-wrap gap-2 mb-3 pb-3 border-bottom dir-filters">
                <div class="input-group" style="max-width: 220px;">
                    <span class="input-group-text border-end-0"><i class="bi bi-search text-muted"></i></span>
                    <input type="search" class="form-control border-start-0 ps-0" placeholder="<%: L.T("Coordinator.ManageStudents.SearchStudents") %>" data-dir-search autocomplete="off" />
                </div>
                
                <select class="form-select w-auto fw-medium" data-dir-filter="major">
                    <option value=""><%: L.T("Coordinator.ManageStudents.AllMajors") %></option>
                    <option value="Computer Science">Computer Science</option>
                    <option value="Computer Engineering">Computer Engineering</option>
                    <option value="Game Design and Media Informatics">Game Design and Media Informatics</option>
                </select>

                <select class="form-select w-auto fw-medium" data-dir-filter="status">
                    <option value=""><%: L.T("Coordinator.ManageStudents.AllStatuses") %></option>
                    <option value="active"><%: L.T("Coordinator.ManageStudents.StatusActive") %></option>
                    <option value="inactive"><%: L.T("Coordinator.ManageStudents.StatusInactive") %></option>
                </select>
            </div>

            <div class="collapse show" id="tableCollapse">
                <div class="table-responsive">
                    <table class="clean-table dir-table">
                        <thead>
                            <tr>
                                <th scope="col"><%: L.T("Coordinator.ManageStudents.Student") %></th>
                                <th scope="col"><%: L.T("Coordinator.ManageStudents.StudentNumber") %></th>
                                <th scope="col"><%: L.T("Coordinator.ManageStudents.Major") %></th>
                                <th scope="col"><%: L.T("Coordinator.ManageStudents.Status") %></th>
                                <th scope="col"><%: L.T("Coordinator.ManageStudents.Action") %></th>
                            </tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptStudents" runat="server">
                                <ItemTemplate>
                                    <tr data-dir-row data-search="<%#: ((StudentDirectoryRow)Container.DataItem).SearchText %>" data-major="<%#: ((StudentDirectoryRow)Container.DataItem).Major %>" data-status="<%# ((StudentDirectoryRow)Container.DataItem).IsActive ? "active" : "inactive" %>" style="--dir-i:<%# Container.ItemIndex %>">
                                        <td>
                                            <div class="d-flex align-items-center gap-3">
                                                <div class="bg-light text-brand fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 35px; height: 35px; font-size: 0.8rem;">
                                                    <%#: ((StudentDirectoryRow)Container.DataItem).Initials %>
                                                </div>
                                                <div>
                                                    <div class="text-dark fw-bold" style="font-size:0.8rem;"><%#: ((StudentDirectoryRow)Container.DataItem).FullName %></div>
                                                    <div class="text-muted fw-normal" style="font-size:0.7rem;"><%#: ((StudentDirectoryRow)Container.DataItem).Email %></div>
                                                </div>
                                            </div>
                                        </td>
                                        <td><div class="text-dark fw-bold"><%#: ((StudentDirectoryRow)Container.DataItem).StudentNumber %></div></td>
                                        <td><div class="text-dark fw-bold"><%#: ((StudentDirectoryRow)Container.DataItem).Major %></div></td>
                                        <td>
                                            <span class='<%# ((StudentDirectoryRow)Container.DataItem).IsActive ? "badge bg-success bg-opacity-10 text-success px-2 py-1 rounded-pill fw-bold" : "badge bg-danger bg-opacity-10 text-danger px-2 py-1 rounded-pill fw-bold" %>' style="font-size:0.7rem;">
                                                <i class='<%# ((StudentDirectoryRow)Container.DataItem).IsActive ? "bi bi-check-circle-fill me-1" : "bi bi-x-circle-fill me-1" %>'></i>
                                                <%#: ((StudentDirectoryRow)Container.DataItem).StatusText %>
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-2">
                                                <button type="button" class="btn-table-action" data-dir-view="<%# Container.ItemIndex %>" aria-haspopup="dialog">
                                                    <i class="bi bi-eye"></i> <%# L.T("Coordinator.ManageStudents.ViewDetails") %>
                                                </button>
                                                <asp:LinkButton ID="btnEdit" runat="server" CssClass="btn-table-action" CommandArgument='<%# ((StudentDirectoryRow)Container.DataItem).Id %>' OnClick="btnEdit_Click" CausesValidation="false">
                                                    <i class="bi bi-pencil"></i> <%# L.T("Coordinator.ManageStudents.Manage") %>
                                                </asp:LinkButton>
                                            </div>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </div>
            <p class="dir-empty text-center p-4 text-muted" data-dir-empty hidden><i class="bi bi-search d-block fs-3 mb-2"></i><%: L.T("Coordinator.ManageStudents.NoStudentsMatchYourSearch") %></p>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="dir-empty text-center d-block p-4 text-muted" />
            <script type="application/json" data-dir-data><%= RowsJson %></script>
        </div>

        <%-- View details Modal --%>
        <div class="modal fade dir-modal" id="studentViewModal" tabindex="-1" aria-labelledby="studentViewTitle" aria-hidden="true" data-dir-view-modal>
            <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable">
                <div class="modal-content rounded-4 border-0 shadow-lg">
                    <div class="modal-header border-bottom-0 pb-0 pt-4 px-4 d-flex justify-content-between align-items-center">
                        <div class="d-flex align-items-center gap-3">
                            <div class="bg-light text-brand fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 45px; height: 45px; font-size: 1rem;" data-field="Initials" aria-hidden="true"></div>
                            <div>
                                <h5 class="fw-bold text-brand mb-0 fs-5" id="studentViewTitle" data-field="FullName"></h5>
                                <div class="text-muted small mt-1" data-field="Email"></div>
                            </div>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ManageStudents.Close") %>"></button>
                    </div>
                    
                    <div class="modal-body p-4">
                        <h6 class="fw-bold text-muted mb-3 text-uppercase small letter-spacing-1"><i class="bi bi-person-badge text-brand me-2 fs-6"></i><%: L.T("Coordinator.ManageStudents.PersonalInformation") %></h6>
                        <div class="row">
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.ManageStudents.StudentID") %></div>
                                <div class="view-value" data-field="StudentNumber"></div>
                            </div>
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.ManageStudents.Phone") %></div>
                                <div class="view-value" data-field="Phone"></div>
                            </div>
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.ManageStudents.CreatedOn") %></div>
                                <div class="view-value" data-field="CreatedText"></div>
                            </div>
                            <div class="col-md-6">
                                <div class="view-label"><%: L.T("Coordinator.ManageStudents.Status") %></div>
                                <div class="view-value" data-field="StatusText" data-status-field="IsActive"></div>
                            </div>
                        </div>

                        <div class="bg-light rounded-4 p-4 mt-3 border border-light shadow-sm">
                            <h6 class="fw-bold text-muted mb-3 text-uppercase small letter-spacing-1"><i class="bi bi-mortarboard text-brand me-2 fs-6"></i><%: L.T("Coordinator.ManageStudents.AcademicInformation") %></h6>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="view-label"><%: L.T("Coordinator.ManageStudents.University") %></div>
                                    <div class="view-value border-0 mb-md-0"><span data-field="University"></span></div>
                                </div>
                                <div class="col-md-6">
                                    <div class="view-label"><%: L.T("Coordinator.ManageStudents.College") %></div>
                                    <div class="view-value border-0 mb-0"><span data-field="College"></span></div>
                                </div>
                                <div class="col-md-12 mt-3">
                                    <div class="view-label"><%: L.T("Coordinator.ManageStudents.Major") %></div>
                                    <div class="view-value border-0 mb-0"><span data-field="Major"></span></div>
                                </div>
                            </div>
                        </div>

                        <div class="bg-light rounded-4 p-4 mt-3 border border-light shadow-sm">
                            <h6 class="fw-bold text-muted mb-3 text-uppercase small letter-spacing-1"><i class="bi bi-briefcase text-brand me-2 fs-6"></i><%: L.T("Coordinator.ManageStudents.TrainingAndSupervision") %></h6>
                            <div class="row">
                                <div class="col-md-4"><div class="view-label"><%: L.T("Coordinator.ManageStudents.Group") %></div><div class="view-value border-0 mb-0" data-field="GroupName"></div></div>
                                <div class="col-md-4"><div class="view-label"><%: L.T("Coordinator.ManageStudents.AcademicSupervisor") %></div><div class="view-value border-0 mb-0" data-field="SupervisorName"></div></div>
                                <div class="col-md-4"><div class="view-label"><%: L.T("Coordinator.ManageStudents.Placement") %></div><div class="view-value border-0 mb-0" data-field="PlacementText"></div></div>
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light px-4 border-top-0 rounded-bottom-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 fw-bold me-auto" data-bs-dismiss="modal"><%: L.T("Coordinator.ManageStudents.Close") %></button>
                        <a class="btn bg-brand rounded-pill px-4 shadow-sm fw-bold" href="#" onclick="return false;"><i class="bi bi-person me-1"></i> <%: L.T("Coordinator.ManageStudents.ViewProfile") %></a>
                    </div>
                </div>
            </div>
        </div>

        <%-- Manage Modal (Server Side) --%>
        <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="modal fade dir-modal" ClientIDMode="Static" tabindex="-1" aria-labelledby="studentModalTitle" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable modal-lg">
                <div class="modal-content rounded-4 border-0 shadow-lg">
                    <div class="modal-header border-bottom-0 pb-0 pt-4 px-4 d-flex justify-content-between align-items-center">
                        <div class="d-flex align-items-center gap-3">
                            <div class="bg-light text-brand fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 45px; height: 45px; font-size: 1rem;"><asp:Literal ID="litInitials" runat="server" /></div>
                            <div>
                                <h5 class="fw-bold text-brand mb-0 fs-5" id="studentModalTitle"><asp:Label ID="lblStudentName" runat="server" /></h5>
                                <div class="text-muted small mt-1"><asp:Label ID="lblStudentEmail" runat="server" /></div>
                            </div>
                        </div>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Coordinator.ManageStudents.Close") %>"></button>
                    </div>
                    <div class="modal-body p-4">
                        <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" CssClass="alert alert-info d-block mb-4" />
                        
                        <h6 class="fw-bold text-brand mb-3 fs-6"><i class="bi bi-mortarboard me-2"></i><%: L.T("Coordinator.ManageStudents.AcademicInformation") %></h6>
                        <div class="row g-3">
                            <div class="col-md-12">
                                <label for="<%= txtEditStudentNumber.ClientID %>" class="form-label fw-semibold small"><%: L.T("Coordinator.ManageStudents.StudentID") %></label>
                                <asp:TextBox ID="txtEditStudentNumber" runat="server" CssClass="form-control bg-light" ReadOnly="true" />
                                <small class="text-muted"><%: L.T("Coordinator.ManageStudents.AssignedWhenTheAccountIsCreated") %></small>
                            </div>
                            <div class="col-md-6">
                                <label for="<%= txtEditUniversity.ClientID %>" class="form-label fw-semibold small"><%: L.T("Coordinator.ManageStudents.University") %></label>
                                <asp:TextBox ID="txtEditUniversity" runat="server" CssClass="form-control bg-light" MaxLength="120" />
                            </div>
                            <div class="col-md-6">
                                <label for="<%= txtEditCollege.ClientID %>" class="form-label fw-semibold small"><%: L.T("Coordinator.ManageStudents.College") %></label>
                                <asp:TextBox ID="txtEditCollege" runat="server" CssClass="form-control bg-light" MaxLength="120" />
                            </div>
                            <div class="col-md-12">
                                <label for="<%= ddlEditMajor.ClientID %>" class="form-label fw-semibold small"><%: L.T("Coordinator.ManageStudents.Major") %></label>
                                <asp:DropDownList ID="ddlEditMajor" runat="server" CssClass="form-select bg-light" />
                            </div>
                        </div>
                    </div>
                    <div class="modal-footer bg-light px-4 border-top-0 rounded-bottom-4">
                        <button type="button" class="btn btn-outline-secondary rounded-pill px-4 fw-bold me-auto" data-bs-dismiss="modal"><%: L.T("Coordinator.ManageStudents.Close") %></button>
                        <!-- زر حفظ التعديلات بلون الداشبورد -->
                        <asp:Button ID="btnSaveDetails" runat="server" Text="<%$ Resources:Coordinator, ManageStudents.SaveChanges %>" CssClass="btn bg-brand rounded-pill px-4 shadow-sm fw-bold" OnClick="btnSaveDetails_Click" data-ui-action="save" data-loading-label="Saving…"/>
                    </div>
                </div>
            </div>
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

            var tableCollapse = document.getElementById('tableCollapse');
            var toggleBtn = document.getElementById('btnToggleTable');

            if (tableCollapse && toggleBtn) {
                var showText = window.uimsT ? window.uimsT('ShowList') : 'Show List';
                var hideText = window.uimsT ? window.uimsT('HideList') : 'Hide List';

                tableCollapse.addEventListener('hidden.bs.collapse', function () {
                    toggleBtn.innerHTML = '<i class="bi bi-eye-fill me-1"></i><span class="toggle-text">' + showText + '</span>';
                });
                tableCollapse.addEventListener('shown.bs.collapse', function () {
                    toggleBtn.innerHTML = '<i class="bi bi-eye-slash-fill me-1"></i><span class="toggle-text">' + hideText + '</span>';
                });
            }
        });
    </script>
</asp:Content>