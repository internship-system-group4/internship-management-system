<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="FinalEvaluation.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.FinalEvaluation" Title="Company Final Evaluation" %>
<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server" />
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
<section class="uims-card"><h2>Company Final Evaluation</h2><p>This final evaluation is confidential. Students cannot view it. Enter the score on the assessment's own scale; no official GJU scoring rubric is assumed.</p>
<asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
<asp:Label runat="server" AssociatedControlID="ddlPlacement" Text="Assigned internship" /><asp:DropDownList ID="ddlPlacement" runat="server" CssClass="form-select mb-3" AutoPostBack="true" OnSelectedIndexChanged="ddlPlacement_SelectedIndexChanged" />
<asp:Literal ID="litCompanyEvidence" runat="server" />
<asp:Panel ID="pnlForm" runat="server" Visible="false">
<asp:Label runat="server" AssociatedControlID="txtScore" Text="Total score (optional for evidence-only reviews)" /><asp:TextBox ID="txtScore" runat="server" CssClass="form-control mb-2" MaxLength="30" />
<asp:Label runat="server" AssociatedControlID="txtMaximum" Text="Maximum score on the assessment scale" /><asp:TextBox ID="txtMaximum" runat="server" CssClass="form-control mb-2" MaxLength="30" />
<asp:Label runat="server" AssociatedControlID="txtComments" Text="Confidential supervisor comments" /><asp:TextBox ID="txtComments" runat="server" TextMode="MultiLine" Rows="5" CssClass="form-control mb-3" MaxLength="4000" />
<asp:Button ID="btnSubmit" runat="server" Text="Submit final evaluation to academic supervisor" CssClass="btn btn-brand" OnClick="btnSubmit_Click" OnClientClick="return confirm('Submit this confidential final evaluation? Submitted evaluations are read-only.');" />
</asp:Panel><p><asp:Literal ID="litStatus" runat="server" /></p></section>
</asp:Content>
