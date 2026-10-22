<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Final Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: #0f4c81; }
        .score-input { width: 80px; text-align: center; background-color: #f8fafc; border: 1px solid #e3e8ee; border-radius: 6px; }
        .score-input:focus { border-color: #0f4c81; outline: none; box-shadow: 0 0 0 2px rgba(15, 76, 129, 0.2); }
        .total-row { background-color: #f0f4f8; border-radius: 8px; padding: 1rem; margin-top: 1rem; font-weight: 700; color: #0f4c81; }
        .student-avatar { width: 45px; height: 45px; border-radius: 50%; background-color: #e8f0f7; color: #0f4c81; font-weight: 700; font-size: 1.1rem; display: flex; align-items: center; justify-content: center; }

        .btn-action { background-color: #f8fafc; border: 1px solid #e3e8ee; color: #0f4c81; font-weight: 600; text-align: left; transition: all 0.2s; }
        .btn-action:hover { background-color: #e8f0f7; border-color: #0f4c81; }
        .btn-send { background-color: #2b4560; color: white; border: none; font-weight: 600; }
        .btn-send:hover { background-color: #1a2e44; color: white; }
        .btn-draft { background-color: white; color: #2b4560; border: 1px solid #c9d2db; font-weight: 600; }
        .btn-draft:hover { background-color: #f8fafc; border-color: #2b4560; }
        .btn-preview { color: #b8860b; font-weight: 700; background: none; border: none; transition: 0.2s; }
        .btn-preview:hover { color: #daa520; transform: scale(1.05); }

        .status-badge-green { background-color: #e6f4ea; color: #1e7e34; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .status-badge-warning { background-color: #fff3cd; color: #856404; padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* Certificate CSS */
        .cert-container { padding: 30px; background: #fff; border: 12px double #0f4c81; text-align: center; position: relative; font-family: 'Georgia', serif; background-image: radial-gradient(circle, rgba(15, 76, 129, 0.03) 0%, transparent 70%); }
        .cert-title { font-size: 2.2rem; font-weight: bold; color: #0f4c81; margin-bottom: 5px; text-transform: uppercase; letter-spacing: 2px; }
        .cert-subtitle { font-size: 1rem; color: #666; letter-spacing: 4px; margin-bottom: 30px; text-transform: uppercase; }
        .cert-name { font-size: 2.5rem; font-style: italic; font-weight: bold; color: #1d2733; margin: 15px 0; border-bottom: 2px solid #b8860b; display: inline-block; padding: 0 40px; }
        .cert-body { font-size: 1.1rem; color: #444; line-height: 1.8; margin-bottom: 40px; padding: 0 20px; }
        .gold-seal { width: 110px; height: 110px; background: radial-gradient(circle, #ffd700 0%, #daa520 100%); border-radius: 50%; border: 3px dashed #fff; box-shadow: 0 0 0 4px #b8860b, 0 5px 15px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: bold; font-size: 0.75rem; text-align: center; position: absolute; bottom: 30px; right: 40px; text-transform: uppercase; transform: rotate(-5deg); z-index: 10; }
        .gold-seal::after, .gold-seal::before { content: ''; position: absolute; bottom: -30px; border-left: 20px solid transparent; border-right: 20px solid transparent; border-top: 40px solid #b8860b; z-index: -1; }
        .gold-seal::after { right: 20px; transform: rotate(-15deg); }
        .gold-seal::before { left: 20px; transform: rotate(15deg); }
        .cert-signature-area { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 50px; padding: 0 30px; }
        .cert-signature-line { border-top: 1px solid #1d2733; width: 220px; padding-top: 8px; font-size: 0.9rem; font-style: italic; color: #1d2733; }
    </style>

    <script type="text/javascript">
        // @ts-nocheck
        function calculateTotal() {
            var tech = parseInt(document.getElementById('<%= txtTechSkills.ClientID %>').value) || 0;
            var work = parseInt(document.getElementById('<%= txtWorkQuality.ClientID %>').value) || 0;
            var prof = parseInt(document.getElementById('<%= txtProfessionalism.ClientID %>').value) || 0;
            var comm = parseInt(document.getElementById('<%= txtCommunication.ClientID %>').value) || 0;

            var total = tech + work + prof + comm;
            var span = document.getElementById('spanTotalScore');
            if (span) { span.innerText = total + " / 100"; }
        }

        function showPreviewModal() {
            var tech = document.getElementById('<%= txtTechSkills.ClientID %>').value || '0';
            var work = document.getElementById('<%= txtWorkQuality.ClientID %>').value || '0';
            var prof = document.getElementById('<%= txtProfessionalism.ClientID %>').value || '0';
            var comm = document.getElementById('<%= txtCommunication.ClientID %>').value || '0';
            var total = (parseInt(tech) + parseInt(work) + parseInt(prof) + parseInt(comm)) || 0;

            document.getElementById('prevTech').innerText = tech;
            document.getElementById('prevWork').innerText = work;
            document.getElementById('prevProf').innerText = prof;
            document.getElementById('prevComm').innerText = comm;
            document.getElementById('prevTotal').innerText = total + " / 100";

            var previewModal = new bootstrap.Modal(document.getElementById('previewModal'));
            previewModal.show();
        }

        function generateCertificate() {
            try {
                // نستخدم الـ spans المضافة حديثاً للحصول على الأسماء
                var studentName = document.getElementById('jsStudentName').innerText;
                var role = document.getElementById('jsInternshipTitle').innerText;

                var hoursElement = document.getElementById('<%= txtActualHours.ClientID %>');
                var hours = (hoursElement && hoursElement.value) ? hoursElement.value : '___';

                var today = new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });

                if (studentName === "Select a trainee" || studentName === "") {
                    alert("Please select a trainee first to generate the certificate.");
                    return;
                }

                document.getElementById('certStudentName').innerText = studentName;
                document.getElementById('certRole').innerText = role;
                document.getElementById('certHours').innerText = hours;
                document.getElementById('certDate').innerText = today;

                var certModal = new bootstrap.Modal(document.getElementById('certificateModal'));
                certModal.show();
            } catch (e) {
                console.error("Certificate error: ", e);
            }
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
                    <h5 class="fw-bold mb-3" style="color: #0f4c81;">1. Select Trainee</h5>
                    <asp:DropDownList ID="ddlTrainees" runat="server" CssClass="form-select bg-light" AutoPostBack="true" OnSelectedIndexChanged="DdlTrainees_SelectedIndexChanged">
                        <asp:ListItem Text="-- Select a trainee to evaluate --" Value=""></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-3" style="color: #0f4c81;">2. Evaluation Forms</h5>
                    <p class="text-muted small mb-4">Fill out both sections below according to GJU criteria before sending the final evaluation.</p>

                    <div class="d-flex flex-column gap-3 mb-4">
                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#scoresModal">
                            <div><i class="bi bi-calculator me-2"></i> Numerical Scores & Hours (GJU Criteria)</div>
                            <i class="bi bi-chevron-right"></i>
                        </button>

                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                            <div><i class="bi bi-chat-text me-2"></i> Overall Feedback & Recommendation</div>
                            <i class="bi bi-chevron-right"></i>
                        </button>
                    </div>

                    <div class="d-flex justify-content-end align-items-center gap-3 pt-3 border-top">
                        <!-- Preview Evaluation Modal trigger -->
                        <button type="button" class="btn btn-link text-muted me-auto text-decoration-none" onclick="showPreviewModal()"><i class="bi bi-eye me-1"></i>Score Summary</button>

                        <!-- Certificate Preview Button -->
                        <button type="button" class="btn-preview" onclick="generateCertificate()">
                            <i class="bi bi-award-fill me-2 fs-5"></i>Preview Certificate
                        </button>

                        <asp:Button ID="btnSaveDraft" runat="server" Text="Save as draft" CssClass="btn btn-draft px-4 py-2 rounded-3" OnClick="BtnSaveDraft_Click" data-ui-action="save" data-loading-label="Saving…" />
                        <asp:Button ID="btnSendEvaluation" runat="server" Text="Send Evaluation & Approve" CssClass="btn btn-send px-4 py-2 rounded-3 shadow-sm" OnClick="BtnSendEvaluation_Click" data-ui-action="send" data-loading-label="Sending…" />
                    </div>
                </div>
            </div>

            <div class="col-lg-4 mb-4">
                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-4" style="color: #0f4c81;">Trainee Details</h5>

                    <div class="d-flex align-items-center gap-3 mb-4 pb-4 border-bottom">
                        <div class="student-avatar border shadow-sm">
                            <asp:Literal ID="litStudentInitials" runat="server">--</asp:Literal>
                        </div>
                        <div>
                            <!-- التغليف بالـ SPAN عشان الجافاسكريبت يقدر يقرأ الاسم -->
                            <div class="fw-bold text-dark"><span id="jsStudentName"><asp:Literal ID="litStudentName" runat="server">Select a trainee</asp:Literal></span></div>
                            <div class="text-muted small"><asp:Literal ID="litStudentMajor" runat="server">-</asp:Literal></div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <div class="text-muted small mb-1">Internship</div>
                        <!-- التغليف بالـ SPAN عشان الجافاسكريبت يقدر يقرأ التايتل -->
                        <div class="fw-semibold text-dark small"><span id="jsInternshipTitle"><asp:Literal ID="litInternshipTitle" runat="server">-</asp:Literal></span></div>
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
    <!-- Modals -->
    <!-- ========================================== -->

    <!-- Certificate Modal -->
    <div class="modal fade" id="certificateModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg" style="background: transparent;">
          <div class="modal-body p-0">
              <div class="cert-container">
                  <div class="cert-title">Certificate of Completion</div>
                  <div class="cert-subtitle">Internship Program</div>
                  <div class="mt-4">
                      <span style="font-style: italic; color: #666;">This is to proudly certify that</span><br />
                      <div class="cert-name" id="certStudentName">Student Name</div><br />
                      <div class="cert-body">
                          has successfully completed <strong id="certHours" style="color:#0f4c81;">___</strong> hours of practical training<br />
                          as a <strong><span id="certRole">Trainee</span></strong>.<br />
                          <br />
                          Their dedication, technical skills, and professionalism <br />have met the highest standards of our organization.
                      </div>
                  </div>
                  <div class="cert-signature-area">
                      <div class="cert-signature-line">
                          <span id="certDate">Date</span><br />
                          <span style="font-size: 0.75rem; color: #888;">Date of Issue</span>
                      </div>
                      <div class="gold-seal">Official<br/>Company<br/>Seal</div>
                      <div class="cert-signature-line">
                          <asp:Literal ID="litCompanySupervisorName" runat="server">Company Supervisor</asp:Literal><br />
                          <span style="font-size: 0.75rem; color: #888;">Authorized Signature</span>
                      </div>
                  </div>
              </div>
          </div>
          <div class="modal-footer bg-white border-top-0 rounded-bottom-4">
            <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Close</button>
            <button type="button" class="btn btn-primary px-4" style="background-color:#0f4c81;" onclick="window.print()"><i class="bi bi-printer me-2"></i>Print Certificate</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Evaluation Preview Modal -->
    <div class="modal fade" id="previewModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0">
            <h5 class="modal-title fw-bold" style="color: #0f4c81;">Score Summary</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body pt-4">
            <ul class="list-group list-group-flush mb-3">
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Tech. Skills & Application <span class="fw-bold" id="prevTech">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Quality of Work & Logic <span class="fw-bold" id="prevWork">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Professionalism & Ethics <span class="fw-bold" id="prevProf">0</span></li>
              <li class="list-group-item d-flex justify-content-between align-items-center px-0">Communication & Teamwork <span class="fw-bold" id="prevComm">0</span></li>
            </ul>
            <div class="p-3 rounded-3 mt-3 d-flex justify-content-between fw-bold" style="background-color: #f0f4f8; color: #0f4c81;">
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

    <!-- Scores & Hours Modal (GJU Criteria) -->
    <div class="modal fade" id="scoresModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: #0f4c81;">Scores & Attendance</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
              <div class="mb-4 bg-light p-3 rounded-3 border">
                  <label class="form-label fw-bold text-dark mb-1">Actual Training Hours</label>
                  <p class="text-muted small mb-2">Enter the total hours completed by the trainee.</p>
                  <asp:TextBox ID="txtActualHours" runat="server" CssClass="form-control fw-bold text-primary" TextMode="Number" min="0" placeholder="e.g. 150"></asp:TextBox>
              </div>

              <h6 class="fw-bold mb-3 text-muted">Evaluation Form (GJU Criteria)</h6>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small">Tech. Skills & Application</span>
                  <div class="text-end"><div class="text-muted small">/ 40</div><asp:TextBox ID="txtTechSkills" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="40" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small">Quality of Work & Logic</span>
                  <div class="text-end"><div class="text-muted small">/ 25</div><asp:TextBox ID="txtWorkQuality" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="25" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small">Professionalism & Ethics</span>
                  <div class="text-end"><div class="text-muted small">/ 20</div><asp:TextBox ID="txtProfessionalism" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="20" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                  <span class="fw-semibold small">Communication & Teamwork</span>
                  <div class="text-end"><div class="text-muted small">/ 15</div><asp:TextBox ID="txtCommunication" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="15" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center total-row">
                  <span>Total score</span><span id="spanTotalScore">-- / 100</span>
              </div>
          </div>
          <div class="modal-footer border-top-0 px-4 pb-4">
            <button type="button" class="btn w-100 text-white rounded-3" style="background-color: #0f4c81;" data-bs-dismiss="modal">Save Scores</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Feedback & Recommendation Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: #0f4c81;">Feedback & Recommendation</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small">Performance level</label>
                        <asp:DropDownList ID="ddlPerformance" runat="server" CssClass="form-select bg-light">
                            <asp:ListItem Text="Select performance level" Value="" />
                            <asp:ListItem Text="Excellent (A)" Value="Excellent" />
                            <asp:ListItem Text="Very Good (B)" Value="VeryGood" />
                            <asp:ListItem Text="Good (C)" Value="Good" />
                            <asp:ListItem Text="Needs Improvement (D)" Value="NeedsImprovement" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small text-primary">Company Recommendation</label>
                        <asp:DropDownList ID="ddlRecommendation" runat="server" CssClass="form-select bg-light border-primary">
                            <asp:ListItem Text="Select recommendation" Value="" />
                            <asp:ListItem Text="Highly Recommended for Hire" Value="HighlyRecommend" />
                            <asp:ListItem Text="Recommended" Value="Recommend" />
                            <asp:ListItem Text="Recommend with Reservations" Value="Reservations" />
                            <asp:ListItem Text="Do Not Recommend" Value="DoNotRecommend" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold small">Strengths</label>
                    <asp:TextBox ID="txtStrengths" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe the trainee's main strengths..."></asp:TextBox>
                </div>
                <div class="mb-2">
                    <label class="form-label fw-semibold small">Areas for improvement</label>
                    <asp:TextBox ID="txtImprovements" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe areas the trainee should develop..."></asp:TextBox>
                </div>
          </div>
          <div class="modal-footer border-top-0 px-4 pb-4">
            <button type="button" class="btn px-4 text-white rounded-3" style="background-color: #0f4c81;" data-bs-dismiss="modal">Save Feedback</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Drafts Modal -->
    <div class="modal fade" id="draftsModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: #0f4c81;">My Saved Drafts</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
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

    <!-- System Message Modal -->
    <div class="modal fade" id="serverMessageModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-sm">
        <div class="modal-content rounded-4 border-0 shadow text-center p-4">
          <div class="mb-3"><asp:Literal ID="litModalIcon" runat="server"></asp:Literal></div>
          <h5 class="fw-bold mb-2 text-dark"><asp:Literal ID="litModalTitle" runat="server"></asp:Literal></h5>
          <p class="text-muted small mb-4"><asp:Literal ID="litModalMessage" runat="server"></asp:Literal></p>
          <button type="button" class="btn btn-primary rounded-pill px-4 w-100" data-bs-dismiss="modal" style="background-color: #0f4c81; border: none;">Okay</button>
        </div>
      </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>