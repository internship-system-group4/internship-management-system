<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Manage Students" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- Manage Students - Owner: Ahmad - Cards: A05 (create student), A06 (list and edit, not built yet) --%>

    <h2 class="mb-4">Manage Students</h2>

    <div class="card shadow-sm">
        <div class="card-body p-4">

            <h4 class="mb-3">Create Student Account</h4>

            <!-- Success or error message from the server -->
            <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

            <div class="row g-3">

                <!-- Personal information -->
                <div class="col-md-6">
                    <label for="<%= txtFullName.ClientID %>" class="form-label">Full name *</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtStudentNumber.ClientID %>" class="form-label">Student number *</label>
                    <asp:TextBox ID="txtStudentNumber" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtEmail.ClientID %>" class="form-label">Email *</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" required="required"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtPhone.ClientID %>" class="form-label">Phone number</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                </div>

                <!-- Academic information -->
                <div class="col-md-6">
                    <label for="<%= txtUniversity.ClientID %>" class="form-label">University *</label>
                    <asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtCollege.ClientID %>" class="form-label">College *</label>
                    <asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" required="required"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= ddlMajor.ClientID %>" class="form-label">Major *</label>
                    <asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select" required="required"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtRequiredHours.ClientID %>" class="form-label">Required training hours *</label>
                    <asp:TextBox ID="txtRequiredHours" runat="server" TextMode="Number" CssClass="form-control" min="1" required="required"></asp:TextBox>
                </div>

                <!-- Login credentials -->
                <div class="col-md-6">
                    <label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password *</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" minlength="6" required="required"></asp:TextBox>
                    <small class="text-muted">At least 6 characters. The student must change it at first login.</small>
                </div>

            </div>

            <asp:Button ID="btnCreate" runat="server"
                Text="Create Student"
                CssClass="btn btn-primary mt-4"
                OnClick="btnCreate_Click" />

        </div>
    </div>

</asp:Content>
