<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Final Evaluation" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        .page-header-title { font-size: 1.75rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); }
        .score-input { width: 80px; text-align: center; background-color: var(--th-bg-f8fafc,#f8fafc); border: 1px solid var(--th-line-e3e8ee,#e3e8ee); border-radius: 6px; }
        .score-input:focus { border-color: var(--th-line-0f4c81,#0f4c81); outline: none; box-shadow: 0 0 0 2px rgba(15, 76, 129, 0.2); }
        .total-row { background-color: var(--th-bg-f0f4f8,#f0f4f8); border-radius: 8px; padding: 1rem; margin-top: 1rem; font-weight: 700; color: var(--th-fg-0f4c81,#0f4c81); }
        .student-avatar { width: 45px; height: 45px; border-radius: 50%; background-color: var(--th-bg-e8f0f7,#e8f0f7); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 700; font-size: 1.1rem; display: flex; align-items: center; justify-content: center; }

        .btn-action { background-color: var(--th-bg-f8fafc,#f8fafc); border: 1px solid var(--th-line-e3e8ee,#e3e8ee); color: var(--th-fg-0f4c81,#0f4c81); font-weight: 600; text-align: start; transition: all 0.2s; }
        .btn-action:hover { background-color: var(--th-bg-e8f0f7,#e8f0f7); border-color: var(--th-line-0f4c81,#0f4c81); }
        .btn-draft { background-color: var(--ui-surface,#ffffff); color: var(--th-fg-2b4560,#2b4560); border: 1px solid var(--th-line-c9d2db,#c9d2db); font-weight: 600; }
        .btn-draft:hover { background-color: var(--th-bg-f8fafc,#f8fafc); border-color: var(--th-line-2b4560,#2b4560); }
        .btn-preview { color: var(--th-fg-b8860b,#b8860b); font-weight: 700; background: none; border: none; transition: 0.2s; }
        .btn-preview:hover { color: #daa520; transform: scale(1.05); }

        .status-badge-green { background-color: var(--th-bg-e6f4ea,#e6f4ea); color: var(--th-fg-1e7e34,#1e7e34); padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }
        .status-badge-warning { background-color: var(--th-bg-fff3cd,#fff3cd); color: var(--th-fg-856404,#856404); padding: 4px 10px; border-radius: 20px; font-size: 0.75rem; font-weight: 600; }

        /* Certificate CSS */
        .cert-container { padding: 30px; background: var(--ui-surface,#fff); border: 12px double var(--th-line-0f4c81,#0f4c81); text-align: center; position: relative; font-family: 'Georgia', serif; background-image: radial-gradient(circle, rgba(15, 76, 129, 0.03) 0%, transparent 70%); }
        .cert-title { font-size: 2.2rem; font-weight: bold; color: var(--th-fg-0f4c81,#0f4c81); margin-bottom: 5px; text-transform: uppercase; letter-spacing: 2px; }
        .cert-subtitle { font-size: 1rem; color: var(--th-fg-666666,#666); letter-spacing: 4px; margin-bottom: 30px; text-transform: uppercase; }
        .cert-name { font-size: 2.5rem; font-style: italic; font-weight: bold; color: var(--th-fg-1d2733,#1d2733); margin: 15px 0; border-bottom: 2px solid var(--th-line-b8860b,#b8860b); display: inline-block; padding: 0 40px; }
        .cert-body { font-size: 1.1rem; color: var(--th-fg-444444,#444); line-height: 1.8; margin-bottom: 40px; padding: 0 20px; }
        .gold-seal { width: 110px; height: 110px; background: radial-gradient(circle, var(--th-bg-ffd700,#ffd700) 0%, var(--th-bg-daa520,#daa520) 100%); border-radius: 50%; border: 3px dashed var(--th-line-ffffff,#fff); box-shadow: 0 0 0 4px #b8860b, 0 5px 15px rgba(0,0,0,0.3); display: flex; align-items: center; justify-content: center; color: #fff; font-weight: bold; font-size: 0.75rem; text-align: center; position: absolute; bottom: 30px; inset-inline-end: 40px; text-transform: uppercase; transform: rotate(-5deg); z-index: 10; }
        .gold-seal::after, .gold-seal::before { content: ''; position: absolute; bottom: -30px; border-inline-start: 20px solid transparent; border-inline-end: 20px solid transparent; border-top: 40px solid var(--th-line-b8860b,#b8860b); z-index: -1; }
        .gold-seal::after { inset-inline-end: 20px; transform: rotate(-15deg); }
        .gold-seal::before { inset-inline-start: 20px; transform: rotate(15deg); }
        .cert-signature-area { display: flex; justify-content: space-between; align-items: flex-end; margin-top: 50px; padding: 0 30px; }
        .cert-signature-line { border-top: 1px solid var(--th-line-1d2733,#1d2733); width: 220px; padding-top: 8px; font-size: 0.9rem; font-style: italic; color: var(--th-fg-1d2733,#1d2733); }
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

        function generateCertificate() {
            try {
                var studentName = document.getElementById('jsStudentName').innerText;
                var role = document.getElementById('jsInternshipTitle').innerText;

                var hoursElement = document.getElementById('<%= txtActualHours.ClientID %>');
                var hours = (hoursElement && hoursElement.value) ? hoursElement.value : '___';

                var today = new Date().toLocaleDateString('en-GB', { day: 'numeric', month: 'long', year: 'numeric' });

                if (studentName === window.uimsT('SelectATrainee') || studentName === "") {
                    alert(window.uimsT('SelectTraineeForCertificate'));
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

        function downloadCertificatePDF() {
            var element = document.getElementById('certificatePrintArea');
            var studentName = document.getElementById('certStudentName').innerText || 'Certificate';
            var opt = {
                margin: 0.3,
                filename: 'GJU_Certificate_' + studentName.replace(/\s+/g, '_') + '.pdf',
                image: { type: 'jpeg', quality: 0.98 },
                html2canvas: { scale: 2, useCORS: true },
                jsPDF: { unit: 'in', format: 'a4', orientation: 'landscape' }
            };
            html2pdf().from(element).set(opt).save();
        }

        function sendCertificateToTrainee() {
            var studentName = document.getElementById('certStudentName').innerText;
            alert("Success! The official completion certificate has been successfully sent and assigned to " + studentName + "'s portal.");
        }

        function showOfficialReportModal() {
            var studentName = document.getElementById('jsStudentName').innerText || 'Student Name';
            var role = document.getElementById('jsInternshipTitle').innerText || 'Intern';
            var hours = document.getElementById('<%= txtActualHours.ClientID %>').value || '0';

            var tech = parseInt(document.getElementById('<%= txtTechSkills.ClientID %>').value) || 0;
            var work = parseInt(document.getElementById('<%= txtWorkQuality.ClientID %>').value) || 0;
            var prof = parseInt(document.getElementById('<%= txtProfessionalism.ClientID %>').value) || 0;
            var comm = parseInt(document.getElementById('<%= txtCommunication.ClientID %>').value) || 0;
            var total = tech + work + prof + comm;

            var perfElem = document.getElementById('<%= ddlPerformance.ClientID %>');
            var perfText = perfElem.options[perfElem.selectedIndex] ? perfElem.options[perfElem.selectedIndex].text : '-';

            var recElem = document.getElementById('<%= ddlRecommendation.ClientID %>');
            var recText = recElem.options[recElem.selectedIndex] ? recElem.options[recElem.selectedIndex].text : '-';

            var strengths = document.getElementById('<%= txtStrengths.ClientID %>').value || 'No strengths noted.';
            var improvements = document.getElementById('<%= txtImprovements.ClientID %>').value || 'No improvements noted.';

            document.getElementById('repStudentName').innerText = studentName;
            document.getElementById('repMajor').innerText = "Computer Engineering / GJU";
            document.getElementById('repRole').innerText = role;
            document.getElementById('repHours').innerText = hours;

            document.getElementById('repTech').innerText = tech + " / 40";
            document.getElementById('repWork').innerText = work + " / 25";
            document.getElementById('repProf').innerText = prof + " / 20";
            document.getElementById('repComm').innerText = comm + " / 15";
            document.getElementById('repTotalScore').innerText = total + " / 100";

            document.getElementById('repPerformance').innerText = perfText;
            document.getElementById('repRecommendation').innerText = recText;
            document.getElementById('repStrengths').innerText = strengths;
            document.getElementById('repImprovements').innerText = improvements;
            document.getElementById('repDate').innerText = new Date().toLocaleDateString('en-GB');

            var reportModal = new bootstrap.Modal(document.getElementById('officialReportModal'));
            reportModal.show();
        }

        function sendReportToAcademicSupervisor() {
            alert("Official evaluation report has been successfully transmitted and routed to the Academic Supervisor's dashboard!");
            var modalEl = document.getElementById('officialReportModal');
            var modal = bootstrap.Modal.getInstance(modalEl);
            modal.hide();
        }
    </script>
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="container-fluid px-4 py-4">

        <div class="d-flex justify-content-between align-items-end mb-4 border-bottom pb-3">
            <div>
                <h2 class="page-header-title mb-1"><%: L.T("Company.FinalEvaluation.FinalEvaluation") %></h2>
                <p class="text-muted mb-0"><%: L.T("Company.FinalEvaluation.SelectATraineeAndCompleteTheir") %></p>
            </div>
            <div>
                <asp:LinkButton ID="btnMyDrafts" runat="server" CssClass="btn btn-warning fw-bold rounded-pill px-4 shadow-sm" OnClick="BtnMyDrafts_Click">
                    <i class="bi bi-journal-bookmark me-2"></i><%: L.T("Company.FinalEvaluation.MyDrafts") %>
                </asp:LinkButton>
            </div>
        </div>

        <asp:Label ID="lblMessage" runat="server" EnableViewState="false" CssClass="d-block mb-3"></asp:Label>

        <div class="row">
            <div class="col-lg-8 mb-4">
                <div class="card border-0 shadow-sm rounded-4 border p-4 mb-4">
                    <h5 class="fw-bold mb-3" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.1SelectTrainee") %></h5>
                    <asp:DropDownList ID="ddlTrainees" runat="server" CssClass="form-select bg-light" AutoPostBack="true" OnSelectedIndexChanged="DdlTrainees_SelectedIndexChanged">
                        <asp:ListItem Text="<%$ Resources:Company, FinalEvaluation.SelectATraineeToEvaluate %>" Value=""></asp:ListItem>
                    </asp:DropDownList>
                </div>

                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-3" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.2EvaluationForms") %></h5>
                    <p class="text-muted small mb-4"><%: L.T("Company.FinalEvaluation.FillOutBothSectionsBelowAccording") %></p>

                    <div class="d-flex flex-column gap-3 mb-4">
                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#scoresModal">
                            <div><i class="bi bi-calculator me-2"></i> <%: L.T("Company.FinalEvaluation.NumericalScoresHoursGJUCriteria") %></div>
                            <i class="bi bi-chevron-right"></i>
                        </button>

                        <button type="button" class="btn btn-action rounded-3 p-3 d-flex justify-content-between align-items-center" data-bs-toggle="modal" data-bs-target="#feedbackModal">
                            <div><i class="bi bi-chat-text me-2"></i> <%: L.T("Company.FinalEvaluation.OverallFeedbackRecommendation") %></div>
                            <i class="bi bi-chevron-right"></i>
                        </button>
                    </div>

                    <div class="d-flex justify-content-end align-items-center gap-3 pt-3 border-top flex-wrap">
                        <!-- زر معاينة التقرير الرسمي للمشرف الأكاديمي -->
                        <button type="button" class="btn btn-outline-dark rounded-pill px-3 fw-semibold shadow-sm me-auto" onclick="showOfficialReportModal()">
                            <i class="bi bi-file-earmark-text-fill me-1 text-primary"></i> Review Official Report
                        </button>

                        <!-- زر معاينة الشهادة -->
                        <button type="button" class="btn-preview" onclick="generateCertificate()">
                            <i class="bi bi-award-fill me-1 fs-5"></i><%: L.T("Company.FinalEvaluation.PreviewCertificate") %>
                        </button>

                        <asp:Button ID="btnSaveDraft" runat="server" Text="<%$ Resources:Company, FinalEvaluation.SaveAsDraft %>" CssClass="btn btn-draft px-3 py-2 rounded-3" OnClick="BtnSaveDraft_Click" data-ui-action="save" data-loading-label="Saving…" />
                    </div>
                </div>
            </div>

            <div class="col-lg-4 mb-4">
                <div class="card border-0 shadow-sm rounded-4 border p-4">
                    <h5 class="fw-bold mb-4" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.TraineeDetails") %></h5>

                    <div class="d-flex align-items-center gap-3 mb-4 pb-4 border-bottom">
                        <div class="student-avatar border shadow-sm">
                            <asp:Literal ID="litStudentInitials" runat="server">--</asp:Literal>
                        </div>
                        <div>
                            <div class="fw-bold text-dark"><span id="jsStudentName"><asp:Literal ID="litStudentName" runat="server" Text="<%$ Resources:Company, FinalEvaluation.SelectATraineePlaceholder %>" /></span></div>
                            <div class="text-muted small"><asp:Literal ID="litStudentMajor" runat="server">-</asp:Literal></div>
                        </div>
                    </div>

                    <div class="mb-3">
                        <div class="text-muted small mb-1"><%: L.T("Company.FinalEvaluation.Internship") %></div>
                        <div class="fw-semibold text-dark small"><span id="jsInternshipTitle"><asp:Literal ID="litInternshipTitle" runat="server">-</asp:Literal></span></div>
                    </div>

                    <div>
                        <div class="text-muted small mb-2"><%: L.T("Company.FinalEvaluation.Status") %></div>
                        <asp:Literal ID="litStatusBadge" runat="server" Text="<%$ Resources:Company, FinalEvaluation.PendingBadge %>" />
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
          <div class="modal-header border-bottom-0 pb-0 justify-content-end pe-3 pt-3">
              <button type="button" class="btn-close bg-white rounded-circle p-2 shadow-sm" data-bs-dismiss="modal" aria-label="Close" style="opacity: 1;"></button>
          </div>
          <div class="modal-body p-0" id="certificatePrintArea">
              <div class="cert-container">
                  <div class="cert-title"><%: L.T("Company.FinalEvaluation.CertificateOfCompletion") %></div>
                  <div class="cert-subtitle"><%: L.T("Company.FinalEvaluation.InternshipProgram") %></div>
                  <div class="mt-4">
                      <span style="font-style: italic; color: var(--th-fg-666666,#666);"><%: L.T("Company.FinalEvaluation.ThisIsToProudlyCertifyThat") %></span><br />
                      <div class="cert-name" id="certStudentName"><%: L.T("Company.FinalEvaluation.StudentName") %></div><br />
                      <div class="cert-body">
                          <%: L.T("Company.FinalEvaluation.HasSuccessfullyCompleted") %> <strong id="certHours" style="color:var(--th-fg-0f4c81,#0f4c81);">___</strong> <%: L.T("Company.FinalEvaluation.HoursOfPracticalTraining") %><br />
                          <%: L.T("Company.FinalEvaluation.AsA") %> <strong><span id="certRole"><%: L.T("Company.FinalEvaluation.Trainee") %></span></strong>.<br />
                          <br />
                          <%: L.T("Company.FinalEvaluation.TheirDedicationTechnicalSkillsAndProfessionalism") %> <br /><%: L.T("Company.FinalFooter.HaveMetTheHighestStandardsOf") %>
                      </div>
                  </div>
                  <div class="cert-signature-area">
                      <div class="cert-signature-line">
                          <span id="certDate"><%: L.T("Company.FinalEvaluation.Date") %></span><br />
                          <span style="font-size: 0.75rem; color: var(--th-fg-888888,#888);"><%: L.T("Company.FinalEvaluation.DateOfIssue") %></span>
                      </div>
                      <div class="gold-seal"><%: L.T("Company.FinalEvaluation.Official") %><br/><%: L.T("Company.FinalEvaluation.Company") %><br/><%: L.T("Company.FinalEvaluation.Seal") %></div>
                      <div class="cert-signature-line">
                          <asp:Literal ID="litCompanySupervisorName" runat="server">Company Supervisor</asp:Literal><br />
                          <span style="font-size: 0.75rem; color: var(--th-fg-888888,#888);"><%: L.T("Company.FinalEvaluation.AuthorizedSignature") %></span>
                      </div>
                  </div>
              </div>
          </div>
          <div class="modal-footer bg-white border-top-0 rounded-bottom-4 d-flex justify-content-center align-items-center flex-wrap gap-2 py-3 px-4">
              <button type="button" class="btn btn-outline-primary px-3 rounded-pill fw-semibold" onclick="downloadCertificatePDF()">
                  <i class="bi bi-file-earmark-pdf me-1"></i> Download as PDF
              </button>
              <button type="button" class="btn btn-outline-primary px-3 rounded-pill fw-semibold" onclick="sendCertificateToTrainee()">
                  <i class="bi bi-send-check me-1"></i> Send to Trainee
              </button>
              <button type="button" class="btn btn-primary px-3 rounded-pill fw-semibold" style="background-color:var(--th-bg-0f4c81,#0f4c81);" onclick="window.print()">
                  <i class="bi bi-printer me-1"></i> Print
              </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Official Academic Evaluation Report Modal -->
    <div class="modal fade" id="officialReportModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 shadow-lg rounded-4">
          <div class="modal-header bg-light border-bottom-0 pt-4 px-4">
            <h5 class="modal-title fw-bold text-dark">
              <i class="bi bi-journal-check text-primary me-2"></i> Official Internship Evaluation Report
            </h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body p-4 p-md-5 bg-white" id="reportPrintArea">
              <div class="text-center border-bottom pb-4 mb-4">
                  <h4 class="fw-bold text-uppercase text-primary mb-1">German Jordanian University</h4>
                  <p class="text-muted small mb-0">Internship Management System (UIMS) - Official Academic Report</p>
                  <hr class="w-25 mx-auto my-3 border-primary">
                  <h5 class="fw-bold text-dark mt-2">Final Performance Evaluation & Grade Report</h5>
              </div>

              <div class="row mb-4 bg-light p-3 rounded-3 border g-2">
                  <div class="col-md-6">
                      <span class="text-muted small d-block">Trainee Student:</span>
                      <strong class="text-dark fs-6" id="repStudentName">--</strong>
                  </div>
                  <div class="col-md-6">
                      <span class="text-muted small d-block">Academic Major:</span>
                      <strong class="text-dark fs-6" id="repMajor">--</strong>
                  </div>
                  <div class="col-md-6 mt-2">
                      <span class="text-muted small d-block">Internship Position:</span>
                      <strong class="text-dark" id="repRole">--</strong>
                  </div>
                  <div class="col-md-6 mt-2">
                      <span class="text-muted small d-block">Actual Training Hours:</span>
                      <strong class="text-primary" id="repHours">--</strong> Hours
                  </div>
              </div>

              <div class="table-responsive mb-4">
                  <table class="table table-bordered align-middle">
                      <thead class="table-light">
                          <tr>
                              <th>Evaluation Criteria (GJU Standard)</th>
                              <th class="text-center" style="width: 120px;">Max Score</th>
                              <th class="text-center" style="width: 120px;">Awarded</th>
                          </tr>
                      </thead>
                      <tbody>
                          <tr>
                              <td><strong>Technical Skills & Application</strong></td>
                              <td class="text-center text-muted">40</td>
                              <td class="text-center fw-bold text-primary" id="repTech">0</td>
                          </tr>
                          <tr>
                              <td><strong>Quality of Work & Logic</strong></td>
                              <td class="text-center text-muted">25</td>
                              <td class="text-center fw-bold text-primary" id="repWork">0</td>
                          </tr>
                          <tr>
                              <td><strong>Professionalism & Ethics</strong></td>
                              <td class="text-center text-muted">20</td>
                              <td class="text-center fw-bold text-primary" id="repProf">0</td>
                          </tr>
                          <tr>
                              <td><strong>Communication & Teamwork</strong></td>
                              <td class="text-center text-muted">15</td>
                              <td class="text-center fw-bold text-primary" id="repComm">0</td>
                          </tr>
                          <tr class="table-primary">
                              <td><strong>Total Calculated Score</strong></td>
                              <td class="text-center"><strong>100</strong></td>
                              <td class="text-center fw-bold fs-5 text-dark" id="repTotalScore">-- / 100</td>
                          </tr>
                      </tbody>
                  </table>
              </div>

              <div class="mb-4">
                  <div class="row g-3">
                      <div class="col-md-6">
                          <div class="p-3 border rounded-3 bg-light h-100">
                              <span class="text-muted small d-block fw-bold mb-1">Performance Level:</span>
                              <span class="text-dark fw-semibold" id="repPerformance">-</span>
                          </div>
                      </div>
                      <div class="col-md-6">
                          <div class="p-3 border rounded-3 bg-light h-100">
                              <span class="text-muted small d-block fw-bold mb-1">Company Recommendation:</span>
                              <span class="text-primary fw-semibold" id="repRecommendation">-</span>
                          </div>
                      </div>
                  </div>
              </div>

              <div class="mb-4">
                  <span class="text-muted small d-block fw-bold mb-1">Key Strengths:</span>
                  <p class="p-3 border rounded-3 bg-light mb-2 text-dark small" id="repStrengths">-</p>
                  
                  <span class="text-muted small d-block fw-bold mb-1">Areas for Improvement:</span>
                  <p class="p-3 border rounded-3 bg-light mb-0 text-dark small" id="repImprovements">-</p>
              </div>

              <div class="d-flex justify-content-between align-items-end mt-5 pt-4 border-top">
                  <div>
                      <p class="text-muted small mb-1">Report Generated Date:</p>
                      <strong class="text-dark" id="repDate">--</strong>
                  </div>
                  <div class="text-end">
                      <div style="font-family: 'Georgia', serif; font-style: italic; font-size: 1.1rem; color: #0f4c81;" class="mb-1">
                          <asp:Literal ID="litReportSupervisorSig" runat="server">Company Supervisor</asp:Literal>
                      </div>
                      <div class="border-top border-dark pt-1" style="width: 200px;">
                          <span class="small text-muted text-uppercase fw-bold" style="font-size: 0.7rem;">Authorized Company Signature & Seal</span>
                      </div>
                  </div>
              </div>
          </div>

          <div class="modal-footer bg-light border-top-0 rounded-bottom-4 px-4 py-3 d-flex justify-content-between">
            <button type="button" class="btn btn-secondary px-4 rounded-pill" data-bs-dismiss="modal">Close</button>
            <div class="d-flex gap-2">
                <button type="button" class="btn btn-outline-primary px-3 rounded-pill" onclick="window.print()">
                    <i class="bi bi-printer me-1"></i> Print Report
                </button>
                <button type="button" class="btn btn-primary px-4 rounded-pill fw-semibold shadow-sm" style="background-color: var(--th-bg-0f4c81,#0f4c81);" onclick="sendReportToAcademicSupervisor()">
                    <i class="bi bi-send-fill me-2"></i> Send to Academic Supervisor
                </button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Scores & Hours Modal -->
    <div class="modal fade" id="scoresModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.ScoresAttendance") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
              <div class="mb-4 bg-light p-3 rounded-3 border">
                  <label class="form-label fw-bold text-dark mb-1"><%: L.T("Company.FinalEvaluation.ActualTrainingHours") %></label>
                  <p class="text-muted small mb-2"><%: L.T("Company.FinalEvaluation.EnterTheTotalHoursCompletedBy") %></p>
                  <asp:TextBox ID="txtActualHours" runat="server" CssClass="form-control fw-bold text-primary" TextMode="Number" min="0" placeholder="e.g. 150"></asp:TextBox>
              </div>

              <h6 class="fw-bold mb-3 text-muted"><%: L.T("Company.FinalEvaluation.EvaluationFormGJUCriteria") %></h6>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small"><%: L.T("Company.FinalEvaluation.TechSkillsApplication") %></span>
                  <div class="text-end"><div class="text-muted small">/ 40</div><asp:TextBox ID="txtTechSkills" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="40" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small"><%: L.T("Company.FinalEvaluation.QualityOfWorkLogic") %></span>
                  <div class="text-end"><div class="text-muted small">/ 25</div><asp:TextBox ID="txtWorkQuality" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="25" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center border-bottom pb-2 mb-2">
                  <span class="fw-semibold small"><%: L.T("Company.FinalEvaluation.ProfessionalismEthics") %></span>
                  <div class="text-end"><div class="text-muted small">/ 20</div><asp:TextBox ID="txtProfessionalism" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="20" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center">
                  <span class="fw-semibold small"><%: L.T("Company.FinalEvaluation.CommunicationTeamwork") %></span>
                  <div class="text-end"><div class="text-muted small">/ 15</div><asp:TextBox ID="txtCommunication" runat="server" CssClass="form-control score-input form-control-sm" TextMode="Number" min="0" max="15" oninput="calculateTotal()"></asp:TextBox></div>
              </div>
              <div class="d-flex justify-content-between align-items-center total-row">
                  <span><%: L.T("Company.FinalEvaluation.TotalScore") %></span><span id="spanTotalScore">-- / 100</span>
              </div>
          </div>
          <div class="modal-footer border-top-0 px-4 pb-4">
            <button type="button" class="btn w-100 text-white rounded-3" style="background-color: var(--th-bg-0f4c81,#0f4c81);" data-bs-dismiss="modal">Save Scores</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Feedback & Recommendation Modal -->
    <div class="modal fade" id="feedbackModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.FeedbackRecommendation") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small"><%: L.T("Company.FinalEvaluation.PerformanceLevel") %></label>
                        <asp:DropDownList ID="ddlPerformance" runat="server" CssClass="form-select bg-light">
                            <asp:ListItem Text="Select Performance Level" Value="" />
                            <asp:ListItem Text="Excellent (A)" Value="Excellent" />
                            <asp:ListItem Text="Very Good (B)" Value="VeryGood" />
                            <asp:ListItem Text="Good (C)" Value="Good" />
                            <asp:ListItem Text="Needs Improvement (D)" Value="NeedsImprovement" />
                        </asp:DropDownList>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label fw-semibold small text-primary"><%: L.T("Company.FinalEvaluation.CompanyRecommendation") %></label>
                        <asp:DropDownList ID="ddlRecommendation" runat="server" CssClass="form-select bg-light border-primary">
                            <asp:ListItem Text="Select Recommendation" Value="" />
                            <asp:ListItem Text="Highly Recommended for Hire" Value="HighlyRecommend" />
                            <asp:ListItem Text="Recommended" Value="Recommend" />
                            <asp:ListItem Text="Recommend with Reservations" Value="Reservations" />
                            <asp:ListItem Text="Do Not Recommend" Value="DoNotRecommend" />
                        </asp:DropDownList>
                    </div>
                </div>
                <div class="mb-4">
                    <label class="form-label fw-semibold small"><%: L.T("Company.FinalEvaluation.Strengths") %></label>
                    <asp:TextBox ID="txtStrengths" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe main strengths..."></asp:TextBox>
                </div>
                <div class="mb-2">
                    <label class="form-label fw-semibold small"><%: L.T("Company.FinalEvaluation.AreasForImprovement") %></label>
                    <asp:TextBox ID="txtImprovements" runat="server" CssClass="form-control bg-light" TextMode="MultiLine" Rows="3" placeholder="Describe areas to develop..."></asp:TextBox>
                </div>
          </div>
          <div class="modal-footer border-top-0 px-4 pb-4">
            <button type="button" class="btn px-4 text-white rounded-3" style="background-color: var(--th-bg-0f4c81,#0f4c81);" data-bs-dismiss="modal">Save Feedback</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Drafts Modal -->
    <div class="modal fade" id="draftsModal" tabindex="-1" aria-hidden="true">
      <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-4 border-0 shadow">
          <div class="modal-header border-bottom-0 pb-0 pt-4 px-4">
            <h5 class="modal-title fw-bold" style="color: var(--th-fg-0f4c81,#0f4c81);"><%: L.T("Company.FinalEvaluation.MySavedDrafts") %></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
          </div>
          <div class="modal-body p-4">
              <asp:GridView ID="gvDrafts" runat="server" CssClass="table table-hover align-middle mb-0" AutoGenerateColumns="False" EmptyDataText="You have no saved drafts." GridLines="None" OnRowCommand="GvDrafts_RowCommand">
                  <HeaderStyle CssClass="bg-light text-muted small text-uppercase" />
                  <Columns>
                      <asp:BoundField DataField="StudentName" HeaderText="Trainee Name" ItemStyle-CssClass="fw-bold text-dark" />
                      <asp:TemplateField HeaderText="Action">
                          <ItemTemplate>
                              <asp:LinkButton ID="btnLoadDraft" runat="server" CommandName="LoadDraft" CommandArgument='<%# Eval("Id") %>' CssClass="btn btn-sm btn-outline-primary rounded-pill px-3">Continue Draft</asp:LinkButton>
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
          <button type="button" class="btn btn-primary rounded-pill px-4 w-100" data-bs-dismiss="modal" style="background-color: var(--th-bg-0f4c81,#0f4c81); border: none;">Okay</button>
        </div>
      </div>
    </div>

    <!-- مكتبة html2pdf لتصدير الشهادات والتقارير -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</asp:Content>