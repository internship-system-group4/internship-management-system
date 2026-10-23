<%@ Page Title="Final Evaluation" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.FinalEvaluation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .score-box { background-color: var(--canvas); border: 1px solid var(--line); border-radius: var(--radius); padding: 1rem; text-align: center; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <div class="uims-topbar mb-4" style="border-radius: var(--radius);">
        <h1 class="uims-page-title">Final Academic Evaluation</h1>
        <div class="text-muted">Select a student to complete their final evaluation.</div>
    </div>

    <!-- Success Message Panel -->
    <asp:Panel ID="pnlSuccessMessage" runat="server" Visible="false" CssClass="alert alert-success mb-4">
        <asp:Literal ID="litSuccessMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Students Table -->
    <div class="uims-card">
        <div class="table-responsive">
            <table class="uims-table align-middle">
                <thead>
                    <tr>
                        <th>Student Name</th>
                        <th>University ID</th>
                        <th>Major</th>
                        <th class="text-end">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <asp:Repeater ID="rptStudents" runat="server">
                        <ItemTemplate>
                            <tr>
                                <td><strong><%# Eval("FullName") %></strong></td>
                                <td>#<%# Eval("StudentNumber") %></td>
                                <td><%# Eval("Major") %></td>
                                <td class="text-end">
                                    <!-- LinkButton triggers server-side click to open the modal -->
                                   <asp:LinkButton ID="btnOpenModal" runat="server" CssClass="btn btn-sm btn-brand" 
    CommandArgument='<%# Eval("Id") %>' OnClick="btnOpenModal_Click" CausesValidation="false" formnovalidate="true">
    View & Evaluate
</asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:Literal ID="litNoData" runat="server" Visible="false">
                        <tr><td colspan="4" class="text-center text-muted py-4">No students are currently assigned to you.</td></tr>
                    </asp:Literal>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bootstrap Modal (Popup) for Evaluation -->
    <div class="modal fade" id="evaluationModal" tabindex="-1" aria-labelledby="evaluationModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header" style="background-color: var(--brand-light);">
                    <h5 class="modal-title" id="evaluationModalLabel" style="color: var(--brand-dark); font-weight: 700;">
                        Evaluate: <asp:Literal ID="litModalStudentName" runat="server"></asp:Literal>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                
                <div class="modal-body">
                    <!-- Hidden field to store the student ID being evaluated -->
                    <asp:HiddenField ID="hfSelectedStudentId" runat="server" />

                    <!-- 1. Company Evaluation (Read-Only) -->
                    <h5 style="color: var(--brand-dark); font-weight: 600; border-bottom: 2px solid var(--line); padding-bottom: 0.5rem;">1. Company Supervisor Evaluation</h5>
                    
                    <asp:Panel ID="pnlCompanyEvalExists" runat="server" Visible="false" CssClass="mb-4">
                        <div class="row mt-3">
                            <div class="col-md-3">
                                <div class="score-box">
                                    <div class="text-muted" style="font-size: 0.85rem; font-weight: 600;">Total Score</div>
                                    <h3 style="color: var(--brand); margin: 0;">
                                        <asp:Literal ID="litCompanyScore" runat="server"></asp:Literal> / <asp:Literal ID="litCompanyMaxScore" runat="server"></asp:Literal>
                                    </h3>
                                </div>
                            </div>
                            <div class="col-md-9">
                                <p class="mb-1"><strong class="text-muted">Strengths:</strong> <asp:Literal ID="litStrengths" runat="server"></asp:Literal></p>
                                <p class="mb-1"><strong class="text-muted">Areas for Improvement:</strong> <asp:Literal ID="litImprovements" runat="server"></asp:Literal></p>
                                <p class="mb-0"><strong class="text-muted">Overall Comment:</strong> <asp:Literal ID="litCompanyComment" runat="server"></asp:Literal></p>
                            </div>
                        </div>
                    </asp:Panel>
                    
                    <asp:Panel ID="pnlNoCompanyEval" runat="server" Visible="true" CssClass="mb-4">
                        <div class="alert alert-warning mt-3 mb-0" style="padding: 0.75rem;">The company supervisor has not submitted their final evaluation yet.</div>
                    </asp:Panel>

                    <!-- 2. Academic Evaluation Form (Pass/Fail) -->
                    <h5 style="color: var(--brand-dark); font-weight: 600; border-bottom: 2px solid var(--line); padding-bottom: 0.5rem;">2. Academic Final Decision</h5>
                    <p class="text-muted mb-3" style="font-size: 0.9rem;">Submit your final decision. Once submitted, it will be sent to the Coordinator.</p>
                    
                    <div class="row mb-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight: 600;">Final Decision</label>
                            <asp:DropDownList ID="ddlPassFail" runat="server" CssClass="form-select">
                                <asp:ListItem Text="-- Select Decision --" Value="" />
                                <asp:ListItem Text="Pass" Value="100" />
                                <asp:ListItem Text="Fail" Value="0" />
                            </asp:DropDownList>
                        </div>
                    </div>
                    <!-- Smart Recommendation Chips -->
<div class="mb-2">
    <label class="form-label text-muted" style="font-size: 0.85rem; font-weight: 600;">Quick Academic Templates:</label>
    <div class="d-flex flex-wrap gap-2 mb-2">
        <button type="button" class="btn btn-sm btn-outline-success" onclick="setRemark('Excellent performance and outstanding commitment to training tasks and required hours.')">
            🟢 Excellent
        </button>
        <button type="button" class="btn btn-sm btn-outline-warning text-dark" onclick="setRemark('Minimum hours completed, periodic reports and follow-up are required.')">
            🟡 Complete Requirements
        </button>
        <button type="button" class="btn btn-sm btn-outline-danger" onclick="setRemark('Training requirements and core competencies were not sufficiently met.')">
            🔴 Re-evaluation Needed
        </button>
    </div>
</div>
                    <div class="mb-2">
                        <label class="form-label" style="font-weight: 600;">Academic Comments & Remarks</label>
                        <asp:TextBox ID="txtAcademicComments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>

                    <asp:Panel ID="pnlAlreadySubmitted" runat="server" Visible="false" CssClass="alert alert-success mt-3 mb-0">
                        <asp:Literal ID="litAlreadySubmittedText" runat="server"></asp:Literal>
                    </asp:Panel>

                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal">Close</button>
                    <asp:Button ID="btnSubmitEvaluation" runat="server" Text="Submit to Coordinator" CssClass="btn btn-brand" OnClick="btnSubmitEvaluation_Click" OnClientClick="return confirm('Are you sure you want to submit this evaluation? It cannot be changed later.');" />
                </div>
            </div>
        </div>
    </div>
    <!-- نهاية محتوى الصفحة -->
    <script type="text/javascript">
        function setRemark(text) {
            var txtBox = document.getElementById('<%= txtAcademicComments.ClientID %>');
            if (txtBox) {
                txtBox.value = text;
            }
        }
    </script>

</asp:Content>
