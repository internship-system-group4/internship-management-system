<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ManageStudents.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ManageStudents" Title="Manage Students" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <style>
        .sidebar, aside { display: flex; flex-direction: column; height: 100vh; }
        .sidebar-menu { flex-grow: 1; overflow-y: auto; }
        .logout-container, .logout-box { margin-top: auto !important; border-top: 1px solid var(--th-line-e3e8ee,#e3e8ee); padding-top: 1rem; }

        .text-brand { color: var(--th-fg-0f4c81,#0f4c81) !important; }
        .bg-brand { background-color: var(--th-bg-0f4c81,#0f4c81) !important; color: white; border: none; transition: 0.2s; }
        .bg-brand:hover { background-color: var(--th-bg-0a365c,#0a365c) !important; color: white; transform: translateY(-1px); }

        /* تصغير أحجام الخطوط في كامل الصفحة */
        .page-title { font-size: 1.25rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 0.2rem; }
        .page-subtitle { font-size: 0.7rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); text-transform: uppercase; letter-spacing: 0.5px; opacity: 0.9; margin-bottom: 0.2rem; }
        p.text-muted { font-size: 0.8rem !important; }

        /* تصغير خطوط الجدول */
        .clean-table { width: 100%; border-collapse: collapse; }
        .clean-table th { padding: 0.8rem 1rem; border-bottom: 2px solid var(--th-line-e2e8f0,#e2e8f0); color: var(--ui-muted, #6c757d); font-size: 0.7rem; text-transform: uppercase; font-weight: 700; text-align: start; letter-spacing: 0.5px; }
        .clean-table td { padding: 0.8rem 1rem; border-bottom: 1px solid var(--th-line-f1f5f9,#f1f5f9); color: var(--th-fg-1d2733,#1d2733); font-size: 0.8rem; font-weight: 600; vertical-align: middle; }
        .clean-table tr:hover td { background-color: var(--th-bg-f8fafc,#f8fafc); }

        /* تصغير خطوط الأزرار والنوافذ */
        .btn { font-size: 0.8rem; }
        .view-label { font-size: 0.7rem; color: var(--th-fg-0f4c81,#0f4c81); text-transform: uppercase; font-weight: 700; margin-bottom: 0.2rem; letter-spacing: 0.5px; opacity: 0.9; }
        .view-value { font-size: 0.8rem; color: var(--th-fg-1d2733,#1d2733); font-weight: 600; margin-bottom: 1.25rem; border-bottom: 1px dashed var(--th-line-e2e8f0,#e2e8f0); padding-bottom: 0.5rem; word-wrap: break-word; overflow-wrap: break-word; }
        .card-custom-header h6, h5 { font-size: 0.95rem !important; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); margin: 0; text-transform: none; }
        
        /* الفلاتر وشريط البحث */
        .filter-group .form-control, .filter-group .form-select { border-radius: 6px; font-size: 0.8rem; border-color: var(--th-line-e2e8f0,#e2e8f0); color: var(--th-fg-1d2733,#1d2733); padding: 0.4rem 0.75rem; }
        .filter-group .form-control:focus, .filter-group .form-select:focus { border-color: var(--th-bg-0f4c81,#0f4c81); box-shadow: none; }
        .filter-group .input-group-text { background-color: transparent; border-radius: 6px 0 0 6px; border-color: var(--th-line-e2e8f0,#e2e8f0); padding: 0.4rem 0.75rem; }
        
        /* زر Hide List المطابق للصورة */
        .btn-toggle-list { background-color: #f8fafc; color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; border: 1px solid var(--th-line-e2e8f0,#e2e8f0); border-radius: 50px; padding: 4px 16px; font-size: 0.8rem; transition: 0.2s; display: inline-flex; align-items: center; justify-content: center; gap: 6px; }
        .btn-toggle-list:hover { background-color: #e2e8f0; border-color: #cbd5e1; }
        .btn-toggle-list i { font-size: 1rem; }
    </style>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-3 px-md-4 py-4">

        <div class="d-flex justify-content-between align-items-center mb-4">
            <div>
                <div class="page-subtitle"><%: L.T("Coordinator.Students.CoordinatorWorkspace") ?? "Coordinator / Students" %></div>
                <h2 class="page-title"><%: L.T("Coordinator.Students.ManageStudents") ?? "Manage students" %></h2>
                <p class="text-muted" style="color: var(--th-fg-0f4c81,#0f4c81); opacity: 0.8;">Every student in the programme. Add students, view their details and profile, or update academic information and access.</p>
            </div>
            <button type="button" class="btn bg-brand px-4 py-2 rounded-pill shadow-sm fw-bold" data-bs-toggle="modal" data-bs-target="#addStudentModal" onclick="resetFormState()">
                <i class="bi bi-plus-lg me-2"></i><%: L.T("Coordinator.Students.AddStudent") ?? "Add student" %>
            </button>
        </div>

        <div class="card border-0 shadow-sm rounded-4 p-4">
            <!-- الهيدر الداخلي وزر الإخفاء (Hide List) -->
            <div class="d-flex justify-content-between align-items-center mb-3 pb-2">
                <div class="d-flex align-items-center gap-2">
                    <h5 class="fw-bold text-brand mb-0"><%: L.T("Coordinator.Students.StudentDirectory") ?? "Student directory" %></h5>
                    <span class="badge bg-light text-dark border rounded-pill text-muted" style="font-size: 0.7rem;">19</span>
                </div>
                <button type="button" class="btn-toggle-list shadow-sm" data-bs-toggle="collapse" data-bs-target="#tableCollapse" aria-expanded="true" onclick="toggleTableVisibility(this)">
                    <i class="bi bi-eye-slash"></i><span class="toggle-text">Hide List</span>
                </button>
            </div>

            <!-- الفلاتر المطابقة للصورة -->
            <div class="filter-group d-flex flex-wrap gap-2 mb-4 pb-3 border-bottom">
                <div class="input-group" style="max-width: 220px;">
                    <span class="input-group-text border-end-0"><i class="bi bi-search text-muted" style="font-size: 0.8rem;"></i></span>
                    <input type="text" class="form-control border-start-0 ps-0" placeholder="Search students" id="searchInput" onkeyup="filterGridView()">
                </div>
                
                <asp:DropDownList ID="ddlMajorFilter" runat="server" CssClass="form-select w-auto fw-medium" onchange="filterGridView()">
                    <asp:ListItem Text="All majors" Value="" />
                    <asp:ListItem Text="Computer Science" Value="Computer Science" />
                    <asp:ListItem Text="Computer Engineering" Value="Computer Engineering" />
                    <asp:ListItem Text="Major not recorded" Value="NotRecorded" />
                    <asp:ListItem Text="Unrecognized major" Value="Unrecognized" />
                </asp:DropDownList>

                <asp:DropDownList ID="ddlStatusFilter" runat="server" CssClass="form-select w-auto fw-medium" onchange="filterGridView()">
                    <asp:ListItem Text="All statuses" Value="" />
                    <asp:ListItem Text="Active" Value="Active" />
                    <asp:ListItem Text="Inactive" Value="Inactive" />
                </asp:DropDownList>
            </div>

            <div class="collapse show" id="tableCollapse">
                <div class="table-responsive">
                    <asp:GridView ID="gvStudents" runat="server" CssClass="clean-table" AutoGenerateColumns="False"  DataKeyNames="Id" GridLines="None">
                        <Columns>
                            <asp:TemplateField HeaderText="Student">
                                <ItemTemplate>
                                    <div class="d-flex align-items-center gap-3 student-row-data">
                                        <div class="bg-light text-brand fw-bold rounded-circle d-flex align-items-center justify-content-center border shadow-sm" style="width: 35px; height: 35px; font-size: 0.8rem;">
                                            AH
                                        </div>
                                        <div>
                                            <div class="text-dark fw-bold student-name" style="font-size: 0.8rem;"><%# Eval("FullName") %></div>
                                            <div class="text-muted fw-normal" style="font-size: 0.7rem;"><%# Eval("Email") %></div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Student Number">
                                <ItemTemplate>
                                    <div class="text-muted fw-normal" style="font-size: 0.8rem;">12</div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Major">
                                <ItemTemplate>
                                    <div class="text-dark fw-bold student-major" style="font-size: 0.8rem;"><%# Eval("Major") %></div>
                                </ItemTemplate>
                            </asp:TemplateField>
                            
                            <asp:TemplateField HeaderText="Training Hours">
                                <ItemTemplate>
                                    <div class="text-muted fw-normal" style="font-size: 0.8rem;">0 / 168 h</div>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Status">
                                <ItemTemplate>
                                    <span class="student-status" style="font-size: 0.75rem; color: #1e7e34; font-weight: 600;">
                                        <i class="bi bi-circle-fill me-1" style="font-size: 0.35rem; vertical-align: middle;"></i> Active
                                    </span>
                                </ItemTemplate>
                            </asp:TemplateField>

                            <asp:TemplateField HeaderText="Action">
                                <ItemTemplate>
                                    <div class="d-flex flex-column gap-1 align-items-end">
                                        <asp:LinkButton ID="btnView" runat="server" CommandName="ViewDetails" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-light border-0 text-brand fw-bold py-0" style="font-size: 0.75rem; background: transparent;" CausesValidation="false">
                                            <i class="bi bi-eye me-1"></i> View details
                                        </asp:LinkButton>
                                        <asp:LinkButton ID="btnToggle" runat="server" CssClass="btn btn-sm btn-light border-0 text-brand fw-bold py-0" style="font-size: 0.75rem; background: transparent;" CausesValidation="false" OnClientClick='<%# "return openConfirmModal(\"" + Eval("Id") + "\");" %>'>
                                            <i class="bi bi-pencil me-1"></i> Manage
                                        </asp:LinkButton>
                                    </div>
                                </ItemTemplate>
                            </asp:TemplateField>
                        </Columns>
                    </asp:GridView>
                </div>
            </div>
        </div>
    </div>

    <!-- Hidden Field والمودلز -->
    <asp:HiddenField ID="hfToggleStudentId" runat="server" />

    <div class="modal fade" id="addStudentModal" data-bs-backdrop="static" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-scrollable">
            <div class="modal-content rounded-4 border-0 shadow-lg">
                <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
                    <div>
                        <h5 class="fw-bold text-brand mb-1">Add New Student</h5>
                        <p class="text-muted mb-0">Create a student account and set academic requirements.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" onclick="resetFormState()"></button>
                </div>
                <div class="modal-body p-4">
                    <div class="mb-4">
                        <h6 class="fw-bold text-brand mb-3">Personal Information</h6>
                        <div class="row g-3">
                            <div class="col-md-6"><label class="view-label">Full Name</label><asp:TextBox ID="txtStudentName" runat="server" CssClass="form-control bg-light" placeholder="e.g. Sara Mohmmad"></asp:TextBox></div>
                            <div class="col-md-6"><label class="view-label">Student ID (University ID)</label><asp:TextBox ID="txtUniversityID" runat="server" CssClass="form-control bg-light" placeholder="e.g. 202310123"></asp:TextBox></div>
                            <div class="col-md-6"><label class="view-label">Email Address</label><asp:TextBox ID="txtStudentEmail" runat="server" CssClass="form-control bg-light" TextMode="Email" placeholder="student@university.edu"></asp:TextBox></div>
                            <div class="col-md-6"><label class="view-label">Phone Number</label><asp:TextBox ID="txtStudentPhone" runat="server" CssClass="form-control bg-light" placeholder="+962..."></asp:TextBox></div>
                        </div>
                    </div>
                    <hr class="my-4" />
                    <div class="mb-4">
                        <h6 class="fw-bold text-brand mb-3">Academic Information</h6>
                        <div class="row g-3">
                            <div class="col-md-12"><label class="view-label">College / Faculty</label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control bg-light" placeholder="e.g. Faculty of Information Technology"></asp:TextBox></div>
                            <div class="col-md-8"><label class="view-label">Academic Major</label><asp:TextBox ID="txtMajor" runat="server" CssClass="form-control bg-light" placeholder="e.g. Computer Science"></asp:TextBox></div>
                            <div class="col-md-4"><label class="view-label">Required Training Hours</label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control bg-light" TextMode="Number" placeholder="e.g. 160"></asp:TextBox></div>
                        </div>
                    </div>
                    <hr class="my-4" />
                    <div>
                        <h6 class="fw-bold text-brand mb-3">Account Access</h6>
                        <div class="row g-3">
                            <div class="col-md-6">
                                <label class="view-label">Temporary Password</label>
                                <asp:TextBox ID="txtTempPassword" runat="server" CssClass="form-control bg-light" TextMode="Password" placeholder="Minimum 6 characters"></asp:TextBox>
                            </div>
                            <div class="col-md-6">
                                <label class="view-label">Account Role</label>
                                <div class="input-group">
                                    <span class="input-group-text bg-light border-end-0"><i class="bi bi-shield-lock text-muted"></i></span>
                                    <input type="text" class="form-control bg-light border-start-0 text-muted" value="Student (Trainee)" readonly="readonly" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="modal-footer bg-light px-4 border-top-0 rounded-bottom-4">
                    <button type="button" class="btn btn-outline-secondary rounded-pill px-4 fw-bold" data-bs-dismiss="modal" onclick="resetFormState()">Cancel</button>
                    <asp:Button ID="btnSaveStudent" runat="server" Text="Create Account" CssClass="btn bg-brand rounded-pill px-4 shadow-sm fw-bold" OnClientClick="return validateForm();" OnClick="btnSaveStudent_Click" CausesValidation="false" />
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="confirmToggleModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow-lg text-center p-4">
          <div class="mb-3"><i class='bi bi-question-circle-fill text-warning' style='font-size: 3.5rem;'></i></div>
          <h5 class="fw-bold mb-2 text-dark">Confirm Action</h5>
          <p class="text-muted mb-4">Are you sure you want to change this student's account status?</p>
          <div class="d-flex gap-2 justify-content-center">
              <button type="button" class="btn btn-light rounded-pill px-4 fw-bold" data-bs-dismiss="modal">Cancel</button>
              <asp:Button ID="btnConfirmToggle" runat="server" Text="Yes, I'm sure" CssClass="btn btn-danger rounded-pill px-4 fw-bold" OnClick="btnConfirmToggle_Click" CausesValidation="false" />
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="serverMessageModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow-lg text-center p-4">
          <div class="mb-3"><asp:Literal ID="litModalIcon" runat="server"></asp:Literal></div>
          <h5 class="fw-bold mb-2 text-dark"><asp:Literal ID="litModalTitle" runat="server"></asp:Literal></h5>
          <p class="text-muted mb-4"><asp:Literal ID="litModalMessage" runat="server"></asp:Literal></p>
          <button type="button" class="btn bg-brand rounded-pill px-4 w-100 fw-bold" data-bs-dismiss="modal">Okay</button>
        </div>
      </div>
    </div>

    <script>
        function toggleTableVisibility(btn) {
            setTimeout(function () {
                var isExpanded = btn.getAttribute('aria-expanded') === 'true';
                var icon = btn.querySelector('i');
                var text = btn.querySelector('.toggle-text');

                if (isExpanded) {
                    icon.className = 'bi bi-eye-slash';
                    text.innerText = 'Hide List';
                } else {
                    icon.className = 'bi bi-eye';
                    text.innerText = 'Show List';
                }
            }, 50);
        }

        function filterGridView() {
            var searchInput = document.getElementById('searchInput').value.toLowerCase();
            var majorFilter = document.getElementById('<%= ddlMajorFilter.ClientID %>').value.toLowerCase();
            var statusFilter = document.getElementById('<%= ddlStatusFilter.ClientID %>').value.toLowerCase();

            var table = document.getElementById('<%= gvStudents.ClientID %>');
            if(!table) return;
            var trs = table.getElementsByTagName("tr");

            for (var i = 1; i < trs.length; i++) {
                var nameCell = trs[i].querySelector('.student-name');
                var majorCell = trs[i].querySelector('.student-major');
                var statusCell = trs[i].querySelector('.student-status');
                
                if (nameCell && majorCell && statusCell) {
                    var nameText = nameCell.textContent || nameCell.innerText;
                    var majorText = majorCell.textContent || majorCell.innerText;
                    var statusText = statusCell.textContent || statusCell.innerText;

                    var matchSearch = nameText.toLowerCase().indexOf(searchInput) > -1;
                    var matchMajor = majorFilter === "" || majorText.toLowerCase().indexOf(majorFilter) > -1;
                    var matchStatus = statusFilter === "" || statusText.toLowerCase().indexOf(statusFilter) > -1;

                    if (matchSearch && matchMajor && matchStatus) {
                        trs[i].style.display = "";
                    } else {
                        trs[i].style.display = "none";
                    }
                }
            }
        }

        function openSystemModal(modalId) {
            setTimeout(function() {
                var el = document.getElementById(modalId);
                if (el) { var m = new bootstrap.Modal(el); m.show(); }
            }, 100);
        }

        function hideSystemModal(modalId) {
            var el = document.getElementById(modalId);
            if (el) {
                var m = bootstrap.Modal.getInstance(el);
                if (m) { m.hide(); }
            }
        }

        function resetFormState() {
            document.getElementById('<%= txtStudentName.ClientID %>').value = '';
            document.getElementById('<%= txtUniversityID.ClientID %>').value = '';
            document.getElementById('<%= txtStudentEmail.ClientID %>').value = '';
            document.getElementById('<%= txtStudentPhone.ClientID %>').value = '';
            document.getElementById('<%= txtCollege.ClientID %>').value = '';
            document.getElementById('<%= txtMajor.ClientID %>').value = '';
            document.getElementById('<%= txtRequiredHours.ClientID %>').value = '';
            document.getElementById('<%= txtTempPassword.ClientID %>').value = '';
        }

        function validateForm() {
            let name = document.getElementById('<%= txtStudentName.ClientID %>').value;
            let email = document.getElementById('<%= txtStudentEmail.ClientID %>').value;
            if (name.trim() === "" || email.trim() === "") {
                alert("Please fill in all required fields.");
                return false;
            }
            return true;
        }

        function openConfirmModal(studentId) {
            document.getElementById('<%= hfToggleStudentId.ClientID %>').value = studentId;
            openSystemModal('confirmToggleModal');
            return false;
        }
    </script>
</asp:Content>