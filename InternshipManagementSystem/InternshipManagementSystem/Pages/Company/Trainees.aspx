<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Trainees.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Trainees" Title="My Trainees" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         My Trainees
         Owner : Nada
         Cards : N06
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <div class="uims-stub">
        <span class="uims-stub-badge">N06</span>
        <h2>My Trainees</h2>
        <p>Students with a confirmed placement at this company. Read placements through PlacementRepository.GetByCompany; each placement Id is its student UID.</p>
        <p class="uims-stub-owner">Assigned to <strong>Nada</strong></p>
    </div>

</asp:Content>
