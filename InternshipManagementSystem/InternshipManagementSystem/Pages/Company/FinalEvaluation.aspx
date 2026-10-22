<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Final Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    
    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: var(--ui-primary); }
        .score-input { width: 80px; text-align: center; background-color: #f8fafc; border: 1px solid #e3e8ee; border-radius: 6px; }
        .score-input:focus { border-color: var(--ui-primary); outline: none; box-shadow: 0 0 0 2px rgba(15, 76, 129, 0.2); }
        .total-row { background-color: #f0f4f8; border-radius: 8px; padding: 1rem; margin-top: 1rem; font-weight: 700; color: var(--ui-primary); }
        .student-avatar { width: 45px; height: 45px; border-radius: 50%; background-color: #e8f0f7; color: var(--ui-primary); font-weight: 700; font-size: 1.1rem; display: flex; align-items: center; justify-content: center; }
        
        .btn-action { background-color: #f8fafc; border: 1px solid #e3e8ee; color: var(--ui-primary); font-weight: 600; text-align: left; transition: all 0.2s; }
        .btn-action:hover { background-color: #e8f0f7; border-color: var(--ui-primary); }
        .btn-send { background-color: #2b4560; color: white; border: none; font-weight: 600; }
        .btn-send:hover { background-color: #1a2e44; color: white; }
        .btn-draft { background-color: white; color: #2b4560; border: 1px solid #c9d2db; font-weight: 600; }
        .btn-draft:hover { background-color: #f8fafc; border-color: #2b4560; }
        .btn-preview { color: #2b4560; font-weight: 600; background: none; border: none; }
        .btn-preview:hover { color: var(--ui-primary); text-decoration: underline; }
        
        .status-badge-green { background-color: #e6f4ea; color: #1e7e34; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .status-badge-warning { background-color: #fff3cd; color: #856404; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
    </style>

    <script type="text/javascript">
        // @ts-nocheck
        function calculateTotal() {
            var tech = parseInt(document.getElementById('<%= txtTechSkills.ClientID %>').value) || 0;
            var work = parseInt(document.getElementById('<%= txtWorkQuality.ClientID %>').value) || 0;
            var comm = parseInt(document.getElementById('<%= txtCommunication.ClientID %>').value) || 0;
            var prof = parseInt(document.getElementById('<%= txtProfessionalism.ClientID %>').value) || 0;
            
            var total = tech + work + comm + prof;
            var span = document.getElementById('spanTotalScore');
            if (span) { span.innerText = total + " / 100"; }
        }

        // سكريبت لفتح نافذة المعاينة (Preview)
        function showPreviewModal() {
            var tech = document.getElementById('<%= txtTechSkills.ClientID %>').value || '0';
            var work = document.getElementById('<%= txtWorkQuality.ClientID %>').value || '0';
            var comm = document.getElementById('<%= txtCommunication.ClientID %>').value || '0';
            var prof = document.getElementById('<%= txtProfessionalism.ClientID %>').value || '0';
            var total = (parseInt(tech) + parseInt(work) + parseInt(comm) + parseInt(prof)) || 0;

            document.getElementById('prevTech').innerText = tech;
            document.getElementById('prevWork').innerText = work;
            document.getElementById('prevComm').innerText = comm;
            document.getElementById('prevProf').innerText = prof;
            document.getElementById('prevTotal').innerText = total + " / 100";
            
            var previewModal = new bootstrap.Modal(document.getElementById('previewModal'));
            previewModal.show();
        }
    </script>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">
        
        <div class="d-flex justify-content-between align-items-end mb-4 border-bottom pb-3">
            <div>
                <h2 class="page-header-title mb-1">Final evaluation</h2>
                <p class="text-muted mb-0">Select a trainee and complete their final internship assessment.</p>
            </div>
            <div>
                <asp:LinkButton ID="btnMyDrafts" runat="server" CssClass="btn btn-warning fw-bold rounded-pill px-4 shadow-sm" OnClick="BtnMyDrafts_Click">
                    <i class="bi bi-journal-bookmark me-2"></i>My Drafts
                </asp:LinkButton>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <div class="row">
            <div class="col-lg-8 mb-4">
                <div class="card border-0 shadow-sm rounded-4 border p-4 mb-4">
                    <h5 class="fw-bold mb-3" style="color: var(--ui-primary);">1. Select Trainee</h5>
                    <asp:DropDownList ID="ddlTrainees" runat="server" CssClass="form-select bg-light" AutoPostBack="true" OnSelectedIndexChanged="DdlTrainees_SelectedIndexChanged">
                        <asp:ListItem Text="-- Select a trainee to evaluate --" Value=""></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-3" style="color: var(--ui-primary);">2. Evaluation Forms</h5>
                    <p class="text-muted small mb-4">Fill out both sections below before sending the final evaluation.</p>
                    
                    <div class="d-flex flex-column gap-3 mb-4">
                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#scoresModal">
                            <div><i class="bi bi-calculator me-2"></i> Numerical Scores (Out of 100)</div>
                            <i class="bi bi-chevron-right"></i>
                        </button>

                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                            <div><i class="bi bi-chat-text me-2"></i> Overall Feedback & Performance</div>
                            <i class="bi bi-chevron-right"></i>
                        </button>
                    </div>

                    <div class="d-flex justify-content-end align-items-center gap-3 pt-3 border-top">
                        <!-- زر الـ Preview رجع مكانه -->
                        <button type="button" class="btn-preview" onclick="showPreviewModal()"><i class="bi bi-eye me-2"></i>Preview</button>
                        
                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save as draft" CssClass="btn btn-draft px-4 py-2 rounded-3" OnClick="BtnSaveDraft_Click"  data-ui-action="save" data-loading-label="Saving…"/>
                        <asp:Button ID="btnSendEvaluation" runat="server" Text="Send evaluation" CssClass="btn btn-send px-4 py-2 rounded-3 shadow-sm" OnClick="BtnSendEvaluation_Click"  data-ui-action="send" data-loading-label="Sending…"/>
                    </div>
                </div>
            </div>

            <div class="col-lg-4 mb-4">
                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-4" style="color: var(--ui-primary);">Trainee Details</h5>
                    
                    <div class="d-flex align-items-center gap-3 mb-4 pb-4 border-bottom">
                        <div class="student-avatar border shadow-sm">
                            <asp:Literal ID="litStudentInitials" runat="server">--</asp:Literal>
                        </div>
                        <div>
                            <div class="fw-bold text-dark"><asp:Literal ID="litStudentName" runat="server">Select a trainee</asp:Literal></div>
                            <div class="text-muted small"><asp:Literal ID="litStudentMajor" runat="server">-</asp:Literal></div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <div class="text-muted small mb-1">Internship</div>
                        <div class="fw-semibold text-dark small"><asp:Literal ID="litInternshipTitle" runat="server">-</asp:Literal></div>
                    </div>

                    <div>
                        <div class="text-muted small mb-2">Status</div>
                        <asp:Literal ID="litStatusBadge" runat="server"><span class="badge bg-secondary">Pending</span></asp:Literal>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ========================================== -->
    <!-- النوافذ المنبثقة (Pop-ups / Modals) -->
    <!-- ========================================== -->

    <!-- 1. نافذة المعاينة (Preview Modal) المضافة حديثاً -->
    <div class="modal fade" id="previewModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0">
            <h5 class="modal-title fw-bold" style="color: var(--ui-primary);">Evaluation Preview</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-4">
            <ul class="list-group list-group-flush mb-3">
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Technical skills <span class="fw-bold" id="prevTech">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Work quality <span class="fw-bold" id="prevWork">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Communication <span class="fw-bold" id="prevComm">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Professionalism <span class="fw-bold" id="prevProf">0</span></li>
            </ul>
            <div class="p-3 rounded-3 mt-3 d-flex justify-content-between fw-bold" style="background-color: #f0f4f8; color: var(--ui-primary);">
                <span>Calculated Total:</span>
                <span id="prevTotal">-- / 100</span>
            </div>
          </div>
          <div class="modal-footer border-top-0 pt-0">
            <button type="button" class="btn btn-secondary rounded-3 px-4" data-bs-dismiss="modal">Close</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 2. نافذة التقييم الرقمي (Scores) -->
    <div class="modal fade" id="scoresModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0">
            <h5 class="modal-title fw-bold" style="color: var(--ui-primary);">Numerical Scores</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-4">
              <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                  <span class="fw-semibold text-dark small">Technical skills</span>
                  <div class="text-end">
                      <div class="text-muted small mb-1">Score / 30</div>
                      <asp:TextBox ID="txtTechSkills" runat="server" CssClass="form-control score-input" TextMode="Number" min="0" max="30" oninput="calculateTotal()"></asp:TextBox>
                  </div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                  <span class="fw-semibold text-dark small">Work quality</span>
                  <div class="text-end">
                      <div class="text-muted small mb-1">Score / 25</div>
                      <asp:TextBox ID="txtWorkQuality" runat="server" CssClass="form-control score-input" TextMode="Number" min="0" max="25" oninput="calculateTotal()"></asp:TextBox>
                  </div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-3 mb-3">
                  <span class="fw-semibold text-dark small">Communication</span>
                  <div class="text-end">
                      <div class="text-muted small mb-1">Score / 20</div>
                      <asp:TextBox ID="txtCommunication" runat="server" CssClass="form-control score-input" TextMode="Number" min="0" max="20" oninput="calculateTotal()"></asp:TextBox>
                  </div>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                  <span class="fw-semibold text-dark small">Professionalism</span>
                  <div class="text-end">
                      <div class="text-muted small mb-1">Score / 25</div>
                      <asp:TextBox ID="txtProfessionalism" runat="server" CssClass="form-control score-input" TextMode="Number" min="0" max="25" oninput="calculateTotal()"></asp:TextBox>
                  </div>
              </div>
              <div class="d-flex justify-content-between align-items-center total-row">
                  <span>Total score</span>
                  <span id="spanTotalScore">-- / 100</span>
              </div>
          </div>
          <div class="modal-footer border-top-0">
            <button type="button" class="btn btn-primary rounded-3 px-4" data-bs-dismiss="modal" style="background-color: var(--ui-primary); border: none;">Done</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 3. نافذة التقييم الكتابي (Feedback) -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0">
            <h5 class="modal-title fw-bold" style="color: var(--ui-primary);">Overall Feedback</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-4">
                <div class="mb-4">
                    <label class="form-label fw-semibold text-dark small">Performance level</label>
                    <asp:DropDownList ID="ddlPerformance" runat="server" CssClass="form-select bg-light text-muted">
                        <asp:ListItem Text="Select performance level" Value="" />
                        <asp:ListItem Text="Excellent (A)" Value="Excellent" />
                        <asp:ListItem Text="Very Good (B)" Value="VeryGood" />
                        <asp:ListItem Text="Good (C)" Value="Good" />
                        <asp:ListItem Text="Needs Improvement (D)" Value="NeedsImprovement" />
                    </asp:DropDownList>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold text-dark small">Strengths</label>
                    <asp:TextBox ID="txtStrengths" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe the trainee's main strengths..."></asp:TextBox>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold text-dark small">Areas for improvement</label>
                    <asp:TextBox ID="txtImprovements" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe areas the trainee should develop..."></asp:TextBox>
                </div>
          </div>
          <div class="modal-footer border-top-0">
            <button type="button" class="btn btn-primary rounded-3 px-4" data-bs-dismiss="modal" style="background-color: var(--ui-primary); border: none;">Done</button>
          </div>
        </div>
      </div>
    </div>

    <!-- 4. نافذة مسوداتي (My Drafts) -->
    <div class="modal fade" id="draftsModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0">
            <h5 class="modal-title fw-bold" style="color: var(--ui-primary);">My Saved Drafts</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-4">
              <asp:GridView ID="gvDrafts" runat="server" CssClass="table table-hover align-middle mb-0" AutoGenerateColumns="False" EmptyDataText="You have no saved drafts." GridLines="None" OnRowCommand="GvDrafts_RowCommand">
                  <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                  <Columns>
                      <asp:BoundField DataField="StudentName" HeaderText="Trainee Name" ItemStyle-CssClass="fw-bold text-dark" />
                      <asp:TemplateField HeaderText="Action">
                          <ItemTemplate>
                              <asp:LinkButton ID="btnLoadDraft" runat="server" CommandName="LoadDraft" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-outline-primary rounded-pill px-3">Continue</asp:LinkButton>
                          </ItemTemplate>
                      </asp:TemplateField>
                  </Columns>
              </asp:GridView>
          </div>
        </div>
      </div>
    </div>

    <!-- 5. نافذة رسائل النظام -->
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