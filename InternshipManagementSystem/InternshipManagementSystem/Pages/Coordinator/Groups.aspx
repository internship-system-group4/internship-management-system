<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Groups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Groups" Title="Groups & Assignments" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro">
            <div><span class="students-eyebrow">Coordinator / Groups</span><h2><asp:Label ID="lblEditorTitle" runat="server" Text="Create group" /></h2><p>Choose a supervisor and assign available students.</p></div>
        </div>
        <nav class="students-tabs" aria-label="Group pages">
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>">Create / edit group</a>
            <a href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>">Configured groups</a>
        </nav>

        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <section class="students-card" aria-labelledby="group-details-heading">
            <div class="students-card-heading"><div><h3 id="group-details-heading">Group details</h3><p>Each student can belong to one group at a time.</p></div></div>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtName.ClientID %>" class="form-label">Group name</label><asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-3"><label for="<%= txtAcademicYear.ClientID %>" class="form-label">Academic year (optional)</label><asp:TextBox ID="txtAcademicYear" runat="server" CssClass="form-control" MaxLength="30" /></div>
                <div class="col-md-3"><label for="<%= txtSemester.ClientID %>" class="form-label">Semester (optional)</label><asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" MaxLength="40" /></div>
                <div class="col-md-6"><label for="<%= ddlSupervisor.ClientID %>" class="form-label">Academic supervisor</label><asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select" /></div>
                <div class="col-12">
                    <span class="form-label d-block">Students</span>
                    <p class="small text-muted mb-2">Only unassigned students are available. When editing a group, its current students are also shown.</p>
                    <asp:CheckBoxList ID="cblStudents" runat="server" CssClass="d-block" RepeatLayout="Flow" />
                    <asp:Label ID="lblNoAvailableStudents" runat="server" CssClass="text-muted" Visible="false" Text="No available students." />
                </div>
                <div class="col-12 d-flex gap-2">
                    <asp:Button ID="btnSave" runat="server" Text="Create group" CssClass="btn btn-primary" OnClick="btnSave_Click"  data-ui-action="create" data-loading-label="Creating…"/>
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel edit" CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" CausesValidation="false" Visible="false" />
                </div>
            </div>
        </section>
    </div>
</asp:Content>
