<%@ Page Title="Final Evaluation" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.FinalEvaluation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .back-link {
            text-decoration: none;
            color: var(--muted);
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            margin-bottom: 1rem;
        }
        .back-link:hover { color: var(--brand); }
        .score-box {
            background-color: var(--canvas);
            border: 1px solid var(--line);
            border-radius: var(--radius);
            padding: 1rem;
            text-align: center;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- Back Navigation -->
    <a href="Dashboard.aspx" class="back-link">
        <span>&larr;</span> Back to Dashboard
    </a>

    <div class="uims-topbar mb-4" style="border-radius: var(--radius);">
        <h1 class="uims-page-title">Final Academic Evaluation</h1>
        <div class="text-muted">Student: <strong style="color: var(--brand-dark);"><asp:Literal ID="litStudentName" runat="server"></asp:Literal></strong></div>
    </div>

    <!-- Section 1: Company Evaluation Summary (Read-Only) -->
    <div class="uims-card mb-4" style="border-top: 4px solid var(--accent);">
        <h3 style="color: var(--brand-dark);">1. Company Supervisor Evaluation</h3>
        
        <asp:Panel ID="pnlCompanyEvalExists" runat="server" Visible="false">
            <div class="row mt-3">
                <div class="col-md-3">
                    <div class="score-box">
                        <div class="text-muted" style="font-size: 0.85rem; font-weight: 600;">Total Score</div>
                        <h2 style="color: var(--brand); margin: 0;">
                            <asp:Literal ID="litCompanyScore" runat="server"></asp:Literal> / <asp:Literal ID="litCompanyMaxScore" runat="server"></asp:Literal>
                        </h2>
                    </div>
                </div>
                <div class="col-md-9">
                    <div class="mb-2">
                        <strong class="text-muted">Strengths:</strong>
                        <p><asp:Literal ID="litStrengths" runat="server"></asp:Literal></p>
                    </div>
                    <div class="mb-2">
                        <strong class="text-muted">Areas for Improvement:</strong>
                        <p><asp:Literal ID="litImprovements" runat="server"></asp:Literal></p>
                    </div>
                    <div>
                        <strong class="text-muted">Overall Comment:</strong>
                        <p><asp:Literal ID="litCompanyComment" runat="server"></asp:Literal></p>
                    </div>
                </div>
            </div>
        </asp:Panel>
        
        <!-- Warning if company hasn't submitted yet -->
        <asp:Panel ID="pnlNoCompanyEval" runat="server" Visible="true">
            <div class="alert alert-warning mt-3 mb-0" role="alert">
                The company supervisor has not submitted their final evaluation yet. You may want to wait before completing the academic evaluation.
            </div>
        </asp:Panel>
    </div>

    <!-- Section 2: Academic Evaluation Form (Tasks S05 & S06) -->
    <div class="uims-card mb-4" style="border-top: 4px solid var(--brand);">
        <h3 style="color: var(--brand-dark);">2. Academic Final Grading</h3>
        <p class="text-muted mb-4">Please grade the student based on the university's evaluation criteria. Once submitted, this will be sent to the Coordinator.</p>
        
        <div class="row mb-3">
            <!-- Criteria 1 -->
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 600;">Company Evaluation Score (out of 40)</label>
                <asp:TextBox ID="txtCompanyComponent" runat="server" CssClass="form-control" type="number" min="0" max="40" step="0.5" required="true"></asp:TextBox>
            </div>
            <!-- Criteria 2 -->
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 600;">Final Report Score (out of 40)</label>
                <asp:TextBox ID="txtReportComponent" runat="server" CssClass="form-control" type="number" min="0" max="40" step="0.5" required="true"></asp:TextBox>
            </div>
            <!-- Criteria 3 -->
            <div class="col-md-4 mb-3">
                <label class="form-label" style="font-weight: 600;">Discussion / Follow-up (out of 20)</label>
                <asp:TextBox ID="txtDiscussionComponent" runat="server" CssClass="form-control" type="number" min="0" max="20" step="0.5" required="true"></asp:TextBox>
            </div>
        </div>

        <div class="mb-4">
            <label class="form-label" style="font-weight: 600;">Academic Comments & Remarks</label>
            <asp:TextBox ID="txtAcademicComments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="4" placeholder="Write your final remarks regarding the student's performance..."></asp:TextBox>
        </div>

        <!-- Submission Actions -->
        <asp:Panel ID="pnlSubmission" runat="server" CssClass="text-end border-top pt-3">
            <asp:Label ID="lblStatusMessage" runat="server" CssClass="me-3" style="font-weight: 600;" Visible="false"></asp:Label>
            <asp:Button ID="btnSubmitEvaluation" runat="server" Text="Submit to Coordinator" CssClass="btn btn-brand" OnClick="btnSubmitEvaluation_Click" OnClientClick="return confirm('Are you sure you want to submit this evaluation? It cannot be changed later.');" />
        </asp:Panel>
    </div>

</asp:Content>
