<%@ Page Language="C#" MasterPageFile="~/Layout/Academic.master" AutoEventWireup="true" CodeBehind="Dashboard.aspx.cs" Inherits="InternshipManagementSystem.Pages.AcademicArea.Dashboard" Title="Academic Dashboard" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>
<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <h2 class="mb-4">Academic Dashboard</h2>
        <div class="card shadow-sm"><div class="card-body p-4">
        <h4 class="mb-3">My assigned students</h4>
        <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert alert-danger d-block" role="alert" />
        <div class="table-responsive"><table class="table table-striped table-hover align-middle">
            <thead><tr><th scope="col">Name</th><th scope="col">Student number</th><th scope="col">Email</th><th scope="col">Major</th><th scope="col">Approved / required hours</th></tr></thead>
            <tbody><asp:Repeater ID="rptStudents" runat="server"><ItemTemplate>
                <tr><td><%#: Eval("FullName") %></td><td><%#: Eval("StudentNumber") %></td><td><%#: Eval("Email") %></td><td><%#: Eval("Major") %></td><td><%#: Eval("ApprovedHours") %> / <%#: Eval("RequiredHours") %></td></tr>
            </ItemTemplate></asp:Repeater></tbody>
        </table></div>
        <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="text-muted" Text="No students have been assigned to you yet." />
        </div></div>
    </div>
</asp:Content>
