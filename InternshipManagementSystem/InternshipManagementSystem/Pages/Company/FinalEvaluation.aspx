<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Company Final Evaluation" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server" />
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<section class="uims-card"><h2><%: L.T("Company.FinalEvaluation.CompanyFinalEvaluation") %></h2><p><%: L.T("Company.FinalEvaluation.ThisFinalEvaluationIsConfidentialStudents") %></p>
<asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
<asp:Label runat="server" AssociatedControlID="ddlPlacement" Text="<%$ Resources:Company, FinalEvaluation.AssignedInternship %>" /><asp:DropDownList ID="ddlPlacement" runat="server" CssClass="form-select mb-3" AutoPostBack="true" OnSelectedIndexChanged="ddlPlacement_SelectedIndexChanged" />
<asp:Literal ID="litCompanyEvidence" runat="server" />
<asp:Panel ID="pnlForm" runat="server" Visible="false">
<asp:Label runat="server" AssociatedControlID="txtScore" Text="<%$ Resources:Company, FinalEvaluation.TotalScoreOptionalForEvidenceOnly %>" /><asp:TextBox ID="txtScore" runat="server" CssClass="form-control mb-2" MaxLength="30" />
<asp:Label runat="server" AssociatedControlID="txtMaximum" Text="<%$ Resources:Company, FinalEvaluation.MaximumScoreOnTheAssessmentScale %>" /><asp:TextBox ID="txtMaximum" runat="server" CssClass="form-control mb-2" MaxLength="30" />
<asp:Label runat="server" AssociatedControlID="txtComments" Text="<%$ Resources:Company, FinalEvaluation.ConfidentialSupervisorComments %>" /><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control mb-3" MaxLength="4000" />
<asp:Button ID="btnSubmit" runat="server" Text="<%$ Resources:Company, FinalEvaluation.SubmitFinalEvaluationToAcademicSupervisor %>" CssClass="btn btn-brand" OnClick="btnSubmit_Click" data-i18n-confirm="<%$ Resources:Shared, I18n.SubmitthisconfidentialfinalevaluationSubmittedevaluations %>" OnClientClick="return confirm(this.getAttribute('data-i18n-confirm'));" />
</asp:Panel><p><asp:Literal ID="litStatus" runat="server" /></p></section>
<p class="mt-3"><a class="btn btn-outline-primary" href="<%= ResolveUrl("~/Pages/Company/EvaluationReport.aspx") %>"><%: L.T("Company.FinalEvaluation.CompanyEvaluationReportAndCertificateTools") %></a></p>
</asp:Content>
