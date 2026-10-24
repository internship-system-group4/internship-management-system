<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AddStudent" Title="Add student" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro"><div><span class="students-eyebrow">Coordinator / Students</span><h2>Add student</h2><p>Create an account and enter the student's academic information.</p></div></div>
        <nav class="students-tabs" aria-label="Student pages">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>">View records</a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/AddStudent.aspx") %>">Add student</a>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>">Manage students</a>
        </nav>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <section class="students-card" aria-labelledby="personal-heading">
            <div class="students-card-heading"><div><span class="students-step">01</span><h3 id="personal-heading">Personal information</h3><p>Use the student's official name and login email.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label">Full name <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><span class="form-label d-block">Student ID</span><p class="form-control-plaintext text-muted mb-0">Generated automatically when the account is created.</p></div>
                <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label">Login email <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
                <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label">Phone number <span class="text-muted">(optional)</span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
            </div>
        </section>
        <section class="students-card" aria-labelledby="academic-heading">
            <div class="students-card-heading"><div><span class="students-step">02</span><h3 id="academic-heading">Academic information</h3><p>These details appear in the student's record.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtUniversity.ClientID %>" class="form-label">University <span class="text-danger">*</span></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= txtCollege.ClientID %>" class="form-label">College <span class="text-danger">*</span></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= ddlMajor.ClientID %>" class="form-label">Major <span class="text-danger">*</span></label><asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select" /></div>
                <div class="col-md-6"><label for="<%= txtRequiredHours.ClientID %>" class="form-label">Required training hours <span class="text-danger">*</span></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
            </div>
        </section>
        <section class="students-card" aria-labelledby="access-heading">
            <div class="students-card-heading"><div><span class="students-step">03</span><h3 id="access-heading">Account access</h3><p>Share the email and temporary password privately. The student must change the password after signing in.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
                <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label">Confirm temporary password <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
            </div>
        </section>
        <div class="students-actions"><asp:Button ID="btnCreate" runat="server" Text="Create student" CssClass="btn btn-primary" OnClick="btnCreate_Click" /><a class="btn btn-outline-secondary" href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>">Back to records</a></div>
    </div>
</asp:Content>
