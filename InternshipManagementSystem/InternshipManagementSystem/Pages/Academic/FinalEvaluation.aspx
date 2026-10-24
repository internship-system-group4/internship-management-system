<%@ Page Title="Final Evaluation" Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.Academic.FinalEvaluation" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .score-box { background-color: var(--canvas); border: 1px solid var(--line); border-radius: var(--radius); padding: 1rem; text-align: center; }
        .btn-outline-brand { border: 1px solid var(--brand); color: var(--brand-text,var(--brand)); background: transparent; font-weight: 600; padding: 0.4rem 1rem; border-radius: 6px; }
        .btn-outline-brand:hover { background-color: var(--brand-light); color: var(--brand-text,var(--brand-dark)); }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
    
    <!-- التنسيق الجديد للعنوان الرئيسي -->
    <div class="mb-4">
        <h1 class="mb-1" style="color: var(--brand-text,var(--brand-dark, #1a365d)); font-weight: 700; font-size: 2rem;"><%: L.T("Academic.FinalEvaluation.FinalAcademicEvaluation") %></h1>
        <p class="text-muted"><%: L.T("Academic.FinalEvaluation.SelectAStudentToCompleteTheir") %></p>
    </div>

    <!-- Success Message Panel -->
    <asp:Panel ID="pnlSuccessMessage" runat="server" Visible="false" CssClass="alert alert-success mb-4">
        <asp:Literal ID="litSuccessMessage" runat="server"></asp:Literal>
    </asp:Panel>

    <!-- Students Table -->
    <div class="uims-card">
        
        <!-- التنسيق الجديد: عنوان الكارد + شريط البحث والفلتر -->
        <div class="p-4 border-bottom">
            <h4 style="color: var(--brand-text,var(--brand-dark, #1a365d)); font-weight: 700; margin-bottom: 0.25rem;"><%: L.T("Academic.FinalEvaluation.StudentRecords") %></h4>
            <p class="text-muted mb-4" style="font-size: 0.9rem;"><%: L.T("Academic.FinalEvaluation.SearchAndViewStudentEvaluationAssignments") %></p>
            
            <div class="d-flex flex-wrap gap-3">
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="<%$ Resources:Academic, FinalEvaluation.SearchNameOrID %>" style="border-radius: 6px; flex-grow: 1;"></asp:TextBox>
                <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Academic, FinalEvaluation.Search %>" CssClass="btn btn-brand" OnClick="btnSearch_Click" style="border-radius: 6px; padding: 0.4rem 1.5rem; font-weight: 600;" />
                
                <asp:DropDownList ID="ddlMajorFilter" runat="server" CssClass="form-select" AutoPostBack="true" OnSelectedIndexChanged="ddlMajorFilter_SelectedIndexChanged" style="border-radius: 6px; border-color: var(--th-line-d1d5db,#d1d5db); font-weight: 500; min-width: 200px; max-width: 250px;">
                    <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.AllMajors %>" Value="All"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.ComputerScience %>" Value="Computer Science"></asp:ListItem>
                    <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.ComputerEngineering %>" Value="Computer Engineering"></asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <div class="table-responsive">
            <table class="uims-table align-middle mb-0">
                <thead>
                    <tr>
                        <th><%: L.T("Academic.FinalEvaluation.StudentName") %></th>
                        <th><%: L.T("Academic.FinalEvaluation.UniversityID") %></th>
                        <th><%: L.T("Academic.FinalEvaluation.Major") %></th>
                        <th class="text-end"><%: L.T("Academic.FinalEvaluation.Action") %></th>
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
                                    <asp:LinkButton ID="btnOpenModal" runat="server" CssClass="btn btn-sm btn-outline-brand" 
                                        CommandArgument='<%# Eval("Id") %>' OnClick="btnOpenModal_Click" CausesValidation="false" formnovalidate="true">
                                        <%# L.T("Academic.FinalEvaluation.ViewAndEvaluate") %>
                                    </asp:LinkButton>
                                </td>
                            </tr>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <asp:PlaceHolder ID="litNoData" runat="server" Visible="false">
                        <tr><td colspan="4" class="text-center text-muted py-5"><%: L.T("Academic.FinalEvaluation.NoStudentsAssigned") %></td></tr>
                    </asp:PlaceHolder>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Bootstrap Modal (Popup) for Evaluation -->
    <div class="modal fade" id="evaluationModal" tabindex="-1" aria-labelledby="evaluationModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header" style="background-color: var(--brand-light);">
                    <h5 class="modal-title" id="evaluationModalLabel" style="color: var(--brand-text,var(--brand-dark)); font-weight: 700;">
                        <%: L.T("Academic.FinalEvaluation.Evaluate") %> <asp:Literal ID="litModalStudentName" runat="server"></asp:Literal>
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="<%: L.T("Academic.FinalEvaluation.Close") %>"></button>
                </div>
                
                <div class="modal-body">
                    <asp:HiddenField ID="hfSelectedStudentId" runat="server" />

                    <!-- 1. Company Evaluation -->
                    <h5 style="color: var(--brand-text,var(--brand-dark)); font-weight: 600; border-bottom: 2px solid var(--line); padding-bottom: 0.5rem;"><%: L.T("Academic.FinalEvaluation.1CompanySupervisorEvaluation") %></h5>
                    
                    <asp:Panel ID="pnlCompanyEvalExists" runat="server" Visible="false" CssClass="mb-4">
                        <div class="row mt-3">
                            <div class="col-md-3">
                                <div class="score-box">
                                    <div class="text-muted" style="font-size: 0.85rem; font-weight: 600;"><%: L.T("Academic.FinalEvaluation.TotalScore") %></div>
                                    <h3 style="color: var(--brand-text,var(--brand)); margin: 0;">
                                        <asp:Literal ID="litCompanyScore" runat="server"></asp:Literal> / <asp:Literal ID="litCompanyMaxScore" runat="server"></asp:Literal>
                                    </h3>
                                </div>
                            </div>
                            <div class="col-md-9">
                                <p class="mb-1"><strong class="text-muted"><%: L.T("Academic.FinalEvaluation.Strengths") %></strong> <asp:Literal ID="litStrengths" runat="server"></asp:Literal></p>
                                <p class="mb-1"><strong class="text-muted"><%: L.T("Academic.FinalEvaluation.AreasForImprovement") %></strong> <asp:Literal ID="litImprovements" runat="server"></asp:Literal></p>
                                <p class="mb-0"><strong class="text-muted"><%: L.T("Academic.FinalEvaluation.OverallComment") %></strong> <asp:Literal ID="litCompanyComment" runat="server"></asp:Literal></p>
                            </div>
                        </div>
                    </asp:Panel>
                    
                    <asp:Panel ID="pnlNoCompanyEval" runat="server" Visible="true" CssClass="mb-4">
                        <div class="alert alert-warning mt-3 mb-0" style="padding: 0.75rem;"><%: L.T("Academic.FinalEvaluation.TheCompanySupervisorHasNotSubmitted") %></div>
                    </asp:Panel>

                    <!-- 2. Academic Evaluation Form -->
                    <h5 style="color: var(--brand-text,var(--brand-dark)); font-weight: 600; border-bottom: 2px solid var(--line); padding-bottom: 0.5rem;"><%: L.T("Academic.FinalEvaluation.2AcademicFinalDecision") %></h5>
                    <p class="text-muted mb-3" style="font-size: 0.9rem;"><%: L.T("Academic.FinalEvaluation.SubmitYourFinalDecisionOnceSubmitted") %></p>
                    
                    <div class="row mb-3">
                        <div class="col-md-6 mb-3">
                            <label class="form-label" style="font-weight: 600;"><%: L.T("Academic.FinalEvaluation.FinalDecision") %></label>
                            <asp:DropDownList ID="ddlPassFail" runat="server" CssClass="form-select">
                                <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.SelectDecision %>" Value="" />
                                <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.Pass %>" Value="100" />
                                <asp:ListItem Text="<%$ Resources:Academic, FinalEvaluation.Fail %>" Value="0" />
                            </asp:DropDownList>
                        </div>
                    </div>

                    <div class="mb-2">
                        <label class="form-label" style="font-weight: 600;"><%: L.T("Academic.FinalEvaluation.AcademicCommentsRemarks") %></label>
                        <asp:TextBox ID="txtAcademicComments" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3"></asp:TextBox>
                    </div>

                    <asp:Panel ID="pnlAlreadySubmitted" runat="server" Visible="false" CssClass="alert alert-success mt-3 mb-0">
                        <asp:Literal ID="litAlreadySubmittedText" runat="server"></asp:Literal>
                    </asp:Panel>

                </div>
                
                <div class="modal-footer">
                    <button type="button" class="btn btn-light" data-bs-dismiss="modal"><%: L.T("Academic.FinalEvaluation.Close") %></button>
                    <asp:Button ID="btnSubmitEvaluation" runat="server" Text="<%$ Resources:Academic, FinalEvaluation.SubmitToCoordinator %>" CssClass="btn btn-brand" OnClick="btnSubmitEvaluation_Click" data-i18n-confirm="<%$ Resources:Shared, I18n.Areyousureyouwanttosubmit %>" OnClientClick="return confirm(this.getAttribute('data-i18n-confirm'));"  data-ui-action="submit" data-loading-label="<%$ Resources:Shared, I18n.Submitting %>"/>
                </div>
            </div>
        </div>
    </div>
</asp:Content>