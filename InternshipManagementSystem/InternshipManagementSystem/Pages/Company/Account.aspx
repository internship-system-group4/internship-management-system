<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Account" Title="My Account" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: var(--ui-primary); }
        
        .profile-card { border: none; border-radius: 1.25rem; box-shadow: 0 4px 20px rgba(0,0,0,0.05); overflow: hidden; background: #fff; }
        .profile-cover { background: linear-gradient(135deg, var(--ui-primary) 0%, #2b4560 100%); height: 140px; position: relative; }
        
        .profile-avatar-wrapper { position: relative; margin-top: -70px; text-align: center; }
        .profile-avatar { width: 140px; height: 140px; border-radius: 50%; border: 5px solid #fff; background-color: #e8f0f7; color: var(--ui-primary); font-size: 2.5rem; font-weight: bold; display: inline-flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1); object-fit: cover; }
        
        .info-group { margin-bottom: 1.5rem; text-align: left; background: #f8fafc; padding: 1rem 1.5rem; border-radius: 12px; border: 1px solid #e3e8ee; }
        .info-label { font-size: 0.75rem; color: #6b7786; text-transform: uppercase; font-weight: 700; margin-bottom: 0.25rem; letter-spacing: 0.5px; }
        .info-value { font-size: 1rem; color: #1d2733; font-weight: 600; margin: 0; }
        
        .btn-edit { background-color: white; color: var(--ui-primary); border: 1px solid var(--ui-primary); font-weight: 600; padding: 0.5rem 1.5rem; border-radius: 50rem; transition: all 0.2s; position: absolute; top: 1rem; right: 1rem; }
        .btn-edit:hover { background-color: #f0f4f8; }
        .btn-save { background-color: var(--ui-primary); color: white; border: none; font-weight: 600; }
        .btn-save:hover { background-color: #0a365c; }
        
        .file-upload-wrapper { position: relative; overflow: hidden; display: inline-block; cursor: pointer; }
        .file-upload-wrapper input[type=file] { font-size: 100px; position: absolute; left: 0; top: 0; opacity: 0; cursor: pointer; }
        .upload-btn { background: #f8fafc; border: 1px dashed var(--ui-primary); color: var(--ui-primary); padding: 1rem; border-radius: 12px; font-weight: 600; display: block; text-align: center; transition: all 0.2s; }
        .upload-btn:hover { background: #e8f0f7; }
    </style>

    <script type="text/javascript">
        // @ts-nocheck
        function updateFileName(input) {
            if (input && input.files && input.files[0]) {
                var displayElement = document.getElementById('fileNameDisplay');
                if (displayElement) {
                    displayElement.innerText = input.files[0].name;
                }
            }
        }
    </script>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <div class="mb-4 border-bottom pb-3">
            <h2 class="page-header-title mb-1">My Account</h2>
            <p class="text-muted mb-0">Manage your personal profile and view your system associations.</p>
        </div>

        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="profile-card">
                    <div class="profile-cover">
                        <button type="button" class="btn btn-edit shadow-sm" data-bs-toggle="modal" data-bs-target="#editProfileModal">
                            <i class="bi bi-pencil-square me-2"></i>Edit Profile
                        </button>
                    </div>
                    
                    <div class="profile-avatar-wrapper">
                        <asp:Image ID="imgAvatar" runat="server" CssClass="profile-avatar" Visible="false" />
                        <div id="divInitials" runat="server" class="profile-avatar">
                            <asp:Literal ID="litInitials" runat="server">SU</asp:Literal>
                        </div>
                    </div>

                    <div class="text-center mt-3 mb-5 px-4">
                        <h3 class="fw-bold mb-1" style="color: var(--ui-primary);"><asp:Literal ID="litDisplayName" runat="server">Supervisor Name</asp:Literal></h3>
                        <span class="badge bg-primary bg-opacity-10 text-primary rounded-pill px-3 py-2 mb-4">Company Supervisor</span>
                        
                        <div class="row g-3 text-start">
                            <div class="col-md-6">
                                <div class="info-group">
                                    <div class="info-label">Email Address (Read-Only)</div>
                                    <div class="info-value"><i class="bi bi-envelope text-primary me-2"></i><asp:Literal ID="litEmail" runat="server">email@example.com</asp:Literal></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-group">
                                    <div class="info-label">Company Association (Read-Only)</div>
                                    <div class="info-value"><i class="bi bi-building text-primary me-2"></i><asp:Literal ID="litCompany" runat="server">Associated Company</asp:Literal></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-group">
                                    <div class="info-label">Phone Number</div>
                                    <div class="info-value"><i class="bi bi-telephone text-primary me-2"></i><asp:Literal ID="litPhone" runat="server">Not provided</asp:Literal></div>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="info-group">
                                    <div class="info-label">Job Title / Department</div>
                                    <div class="info-value"><i class="bi bi-briefcase text-primary me-2"></i><asp:Literal ID="litJobTitle" runat="server">Not provided</asp:Literal></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="modal fade" id="editProfileModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: var(--ui-primary);">Update Profile</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-4">
              
              <div class="mb-4 text-center">
                  <label class="form-label fw-semibold text-start w-100 mb-2">Profile Picture</label>
                  <div class="file-upload-wrapper w-100">
                      <span class="upload-btn">
                          <i class="bi bi-camera me-2"></i>Choose a new photo
                          <div id="fileNameDisplay" class="small text-muted mt-1 fw-normal">JPG or PNG allowed</div>
                      </span>
                      <asp:FileUpload ID="fuProfileImage" runat="server" accept=".png,.jpg,.jpeg" onchange="updateFileName(this)" />
                  </div>
              </div>

              <div class="mb-3">
                  <label class="form-label fw-semibold small">Full Name</label>
                  <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control rounded-3 py-2 bg-light"></asp:TextBox>
              </div>

              <div class="mb-3">
                  <label class="form-label fw-semibold small">Phone Number</label>
                  <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control rounded-3 py-2 bg-light" placeholder="e.g. +962 7..."></asp:TextBox>
              </div>

              <div class="mb-4">
                  <label class="form-label fw-semibold small">Job Title / Department</label>
                  <asp:TextBox ID="txtJobTitle" runat="server" CssClass="form-control rounded-3 py-2 bg-light" placeholder="e.g. HR Manager"></asp:TextBox>
              </div>

          </div>
          <div class="modal-footer border-top-0 pt-0 px-4 pb-4">
            <button type="button" class="btn btn-light rounded-pill px-4 fw-semibold" data-bs-dismiss="modal">Cancel</button>
            <asp:Button ID="btnSaveChanges" runat="server" Text="Save Changes" CssClass="btn btn-save px-4 py-2 rounded-pill shadow-sm" OnClick="BtnSaveChanges_Click"  data-ui-action="save" data-loading-label="Saving…"/>
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="serverMessageModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow text-center p-4">
          <div class="mb-3"><asp:Literal ID="litModalIcon" runat="server"></asp:Literal></div>
          <h5 class="fw-bold mb-2 text-dark"><asp:Literal ID="litModalTitle" runat="server"></asp:Literal></h5>
          <p class="text-muted small mb-4"><asp:Literal ID="litModalMessage" runat="server"></asp:Literal></p>
          <button type="button" class="btn btn-primary rounded-pill px-4 w-100" data-bs-dismiss="modal" style="background-color: var(--ui-primary); border: none;">Okay</button>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>