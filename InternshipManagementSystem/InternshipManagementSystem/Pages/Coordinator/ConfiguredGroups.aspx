<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="ConfiguredGroups.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.ConfiguredGroups" Title="Configured groups" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="<%= ResolveUrl("~/Assets/css/students.css") %>" />
</asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page">
        <div class="students-intro">
            <div><span class="students-eyebrow">Coordinator / Groups</span><h2>Configured groups</h2><p>Review group membership and supervisor assignments.</p></div>
            <a class="btn btn-primary" href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>">+ Create group</a>
        </div>
        <nav class="students-tabs" aria-label="Group pages">
            <a href="<%= ResolveUrl("~/Pages/Coordinator/Groups.aspx") %>">Create / edit group</a>
            <a class="active" aria-current="page" href="<%= ResolveUrl("~/Pages/Coordinator/ConfiguredGroups.aspx") %>">Configured groups</a>
        </nav>

        <section class="students-card" aria-labelledby="groups-heading">
            <div class="students-card-heading"><div><h3 id="groups-heading">Groups</h3><p>Search by group name, academic year, semester, or supervisor.</p></div></div>
            <asp:Label ID="lblMessage" runat="server" Visible="false" role="alert" />
            <div class="students-search">
                <label for="<%= txtSearch.ClientID %>" class="visually-hidden">Search configured groups</label>
                <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" placeholder="Search configured groups" />
                <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-primary" OnClick="btnSearch_Click" CausesValidation="false" />
                <asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" />
            </div>
            <div class="table-responsive">
                <table class="table students-table align-middle">
                    <thead><tr><th scope="col">Group</th><th scope="col">Academic year</th><th scope="col">Semester</th><th scope="col">Supervisor</th><th scope="col">Students</th><th scope="col">Action</th></tr></thead>
                    <tbody><asp:Repeater ID="rptGroups" runat="server"><ItemTemplate><tr>
                        <td><strong><%#: Eval("Name") %></strong></td>
                        <td><%#: Eval("AcademicYear") %></td>
                        <td><%#: Eval("Semester") %></td>
                        <td><%#: Eval("AcademicSupervisorName") %></td>
                        <td><%#: ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds == null ? 0 : ((InternshipManagementSystem.Models.StudentGroup)Container.DataItem).StudentIds.Count %></td>
                        <td><asp:LinkButton ID="btnEdit" runat="server" Text="Edit group" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                    </tr></ItemTemplate></asp:Repeater></tbody>
                </table>
            </div>
            <asp:Label ID="lblNoGroups" runat="server" CssClass="students-empty" Visible="false" />
        </section>
    </div>
</asp:Content>
