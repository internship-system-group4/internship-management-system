<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="AddStudent.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.AddStudent" Title="Add student" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"><link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css") %>" /></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro"><div><span class="students-eyebrow"><%: L.T("Coordinator.AddStudent.CoordinatorStudents") %></span><h2><%: L.T("Coordinator.AddStudent.AddStudent") %></h2><p><%: L.T("Coordinator.AddStudent.CreateAnAccountAndEnterThe") %></p></div></div>
        <nav class="students-tabs" aria-label="<%: L.T("Coordinator.AddStudent.StudentPages") %>">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>"><%: L.T("Coordinator.AddStudent.ViewRecords") %></a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/AddStudent.aspx") %>"><%: L.T("Coordinator.AddStudent.AddStudent") %></a>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ManageStudents.aspx") %>"><%: L.T("Coordinator.AddStudent.ManageStudents") %></a>
        </nav>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <section class="students-card" aria-labelledby="personal-heading">
            <div class="students-card-heading"><div><span class="students-step">01</span><h3 id="personal-heading"><%: L.T("Coordinator.AddStudent.PersonalInformation") %></h3><p><%: L.T("Coordinator.AddStudent.UseTheStudentSOfficialName") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtFullName.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.FullName") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><span class="form-label d-block"><%: L.T("Coordinator.AddStudent.StudentID") %></span><p class="form-control-plaintext text-muted mb-0"><%: L.T("Coordinator.AddStudent.GeneratedAutomaticallyWhenTheAccountIs") %></p></div>
                <div class="col-md-6"><label for="<%= txtEmail.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.LoginEmail") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" MaxLength="254" /></div>
                <div class="col-md-6"><label for="<%= txtPhone.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.PhoneNumber") %> <span class="text-muted"><%: L.T("Coordinator.AddStudent.Optional") %></span></label><asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40" /></div>
            </div>
        </section>
        <section class="students-card" aria-labelledby="academic-heading">
            <div class="students-card-heading"><div><span class="students-step">02</span><h3 id="academic-heading"><%: L.T("Coordinator.AddStudent.AcademicInformation") %></h3><p><%: L.T("Coordinator.AddStudent.TheseDetailsAppearInTheStudent") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtUniversity.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.University") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= txtCollege.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.College") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-6"><label for="<%= ddlMajor.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.Major") %> <span class="text-danger">*</span></label><asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select" /></div>
                <div class="col-md-6"><label for="<%= txtRequiredHours.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.RequiredTrainingHours") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
            </div>
        </section>
        <section class="students-card" aria-labelledby="access-heading">
            <div class="students-card-heading"><div><span class="students-step">03</span><h3 id="access-heading"><%: L.T("Coordinator.AddStudent.AccountAccess") %></h3><p><%: L.T("Coordinator.AddStudent.ShareTheEmailAndTemporaryPassword") %></p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.TemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
                <div class="col-md-6"><label for="<%= txtConfirmPassword.ClientID %>" class="form-label"><%: L.T("Coordinator.AddStudent.ConfirmTemporaryPassword") %> <span class="text-danger">*</span></label><asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128" /></div>
            </div>
        </section>
        <div class="students-actions"><asp:Button ID="btnCreate" runat="server" Text="<%$ Resources:Coordinator, AddStudent.CreateStudent %>" CssClass="btn btn-primary" OnClick="btnCreate_Click" /><a class="btn btn-outline-secondary" href="<%= ResolveUrl("~/Pages/Coordinator/Students.aspx") %>"><%: L.T("Coordinator.AddStudent.BackToRecords") %></a></div>
    </div>
</asp:Content>
