<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Groups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Groups" Title="Groups & Assignments" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <h2 class="mb-4">Groups &amp; Assignments</h2>
        <p class="text-muted">Create a group, choose its academic supervisor, and select its students. Edit a group to change its supervisor or membership.</p>
        <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
        <div class="card shadow-sm mb-4"><div class="card-body p-4">
            <h4 class="mb-3"><asp:Label ID="lblEditorTitle" runat="server" Text="Create group" /></h4>
            <div class="row g-3">
                <div class="col-md-6"><label for="<%= txtName.ClientID %>" class="form-label">Group name</label><asp:TextBox ID="txtName" runat="server" CssClass="form-control" MaxLength="120" /></div>
                <div class="col-md-3"><label for="<%= txtAcademicYear.ClientID %>" class="form-label">Academic year (optional)</label><asp:TextBox ID="txtAcademicYear" runat="server" CssClass="form-control" MaxLength="30" /></div>
                <div class="col-md-3"><label for="<%= txtSemester.ClientID %>" class="form-label">Semester (optional)</label><asp:TextBox ID="txtSemester" runat="server" CssClass="form-control" MaxLength="40" /></div>
                <div class="col-md-6"><label for="<%= ddlSupervisor.ClientID %>" class="form-label">Academic supervisor</label><asp:DropDownList ID="ddlSupervisor" runat="server" CssClass="form-select" /></div>
                <div class="col-12">
                    <span class="form-label d-block">Students</span>
                    <p class="small text-muted mb-2">Selecting a student from another group moves them here when you save. Their former group is updated at the same time.</p>
                    <asp:CheckBoxList ID="cblStudents" runat="server" CssClass="d-block" RepeatLayout="Flow" />
                    <asp:Label ID="lblNoAvailableStudents" runat="server" CssClass="text-muted" Visible="false" Text="No available students." />
                </div>
                <div class="col-12 d-flex gap-2">
                    <asp:Button ID="btnSave" runat="server" Text="Create group" CssClass="btn btn-primary" OnClick="btnSave_Click" />
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel edit" CssClass="btn btn-outline-secondary" OnClick="btnCancel_Click" CausesValidation="false" Visible="false" />
                </div>
            </div>
        </div></div>
        <div class="card shadow-sm"><div class="card-body p-4">
        <h4 class="mb-3">Configured groups</h4>
        <div class="table-responsive"><table class="table table-striped table-hover align-middle">
            <thead><tr><th scope="col">Group</th><th scope="col">Academic year</th><th scope="col">Semester</th><th scope="col">Supervisor</th><th scope="col">Students</th><th scope="col"></th></tr></thead>
            <tbody><asp:Repeater ID="rptGroups" runat="server"><ItemTemplate>
                <tr>
                    <td><%#: Eval("Name") %></td><td><%#: Eval("AcademicYear") %></td><td><%#: Eval("Semester") %></td><td><%#: Eval("AcademicSupervisorName") %></td>
                    <td><%#: ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds == null ? 0 : ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds.Count %></td>
                    <td><asp:LinkButton ID="btnEdit" runat="server" Text="Edit" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                </tr>
            </ItemTemplate></asp:Repeater></tbody>
        </table></div>
        <asp:Label ID="lblNoGroups" runat="server" CssClass="text-muted" Visible="false" Text="No groups have been created yet." />
        </div></div>
    </div>
</asp:Content>
