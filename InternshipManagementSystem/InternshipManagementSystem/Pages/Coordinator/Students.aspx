<%@ Page Language="C#" MasterPageFile="~/Layout/Coordinator.master" AutoEventWireup="true" CodeBehind="Students.aspx.cs" Inherits="InternshipManagementSystem.Pages.CoordinatorArea.Students" Title="Manage Students" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-4">
        <h2 class="mb-0">Manage Students</h2>
        <a href="#student-records" class="btn btn-outline-primary">View student records</a>
    </div>

    <div class="card shadow-sm">
        <div class="card-body p-4">

            <h4 class="mb-3">Create Student Account</h4>

            <!-- Success or error message from the server -->
            <asp:Label ID="lblMessage" runat="server" Visible="false"></asp:Label>

            <div class="row g-3">

                <!-- Personal information -->
                <div class="col-md-6">
                    <label for="<%= txtFullName.ClientID %>" class="form-label">Full name *</label>
                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" MaxLength="120"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtStudentNumber.ClientID %>" class="form-label">Student number *</label>
                    <asp:TextBox ID="txtStudentNumber" runat="server" CssClass="form-control" MaxLength="40"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtEmail.ClientID %>" class="form-label">Email *</label>
                    <asp:TextBox ID="txtEmail" runat="server" TextMode="Email" CssClass="form-control" MaxLength="254"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtPhone.ClientID %>" class="form-label">Phone number</label>
                    <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" TextMode="Phone" MaxLength="40"></asp:TextBox>
                </div>

                <!-- Academic information -->
                <div class="col-md-6">
                    <label for="<%= txtUniversity.ClientID %>" class="form-label">University *</label>
                    <asp:TextBox ID="txtUniversity" runat="server" CssClass="form-control" MaxLength="120"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtCollege.ClientID %>" class="form-label">College *</label>
                    <asp:TextBox ID="txtCollege" runat="server" CssClass="form-control" MaxLength="120"></asp:TextBox>
                </div>

                <div class="col-md-6">
                    <label for="<%= ddlMajor.ClientID %>" class="form-label">Major *</label>
                    <asp:DropDownList ID="ddlMajor" runat="server" CssClass="form-select"></asp:DropDownList>
                </div>

                <div class="col-md-6">
                    <label for="<%= txtRequiredHours.ClientID %>" class="form-label">Required training hours *</label>
                    <asp:TextBox ID="txtRequiredHours" runat="server" TextMode="Number" CssClass="form-control" min="1"></asp:TextBox>
                </div>

                <!-- Login credentials -->
                <div class="col-md-6">
                    <label for="<%= txtPassword.ClientID %>" class="form-label">Temporary password *</label>
                    <asp:TextBox ID="txtPassword" runat="server" CssClass="form-control" TextMode="Password" MaxLength="128"></asp:TextBox>
                    <small class="text-muted">At least 6 characters. The student must change it at first login.</small>
                </div>

            </div>

            <asp:Button ID="btnCreate" runat="server"
                Text="Create Student"
                CssClass="btn btn-primary mt-4"
                OnClick="btnCreate_Click" />

        </div>
    </div>

    <div id="student-records" class="card shadow-sm mt-4">
        <div class="card-body p-4">
            <h4 class="mb-3">Student records</h4>
            <asp:Label ID="lblListMessage" runat="server" Visible="false" role="alert" />
            <div class="row g-2 mb-3">
                <div class="col-md-6">
                    <label for="<%= txtSearch.ClientID %>" class="form-label">Search by name, student number, email, university, college, or major</label>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" MaxLength="120" />
                </div>
                <div class="col-md-auto align-self-end"><asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-outline-primary" OnClick="btnSearch_Click" CausesValidation="false" /></div>
                <div class="col-md-auto align-self-end"><asp:Button ID="btnClearSearch" runat="server" Text="Clear" CssClass="btn btn-outline-secondary" OnClick="btnClearSearch_Click" CausesValidation="false" /></div>
            </div>
            <div class="table-responsive">
                <table class="table table-striped table-hover align-middle">
                    <thead><tr><th scope="col">Name</th><th scope="col">Student number</th><th scope="col">Email</th><th scope="col">University</th><th scope="col">College</th><th scope="col">Major</th><th scope="col">Required hours</th><th scope="col"></th></tr></thead>
                    <tbody>
                        <asp:Repeater ID="rptStudents" runat="server"><ItemTemplate>
                            <tr>
                                <td><%#: Eval("FullName") %></td><td><%#: Eval("StudentNumber") %></td><td><%#: Eval("Email") %></td>
                                <td><%#: Eval("University") %></td><td><%#: Eval("College") %></td><td><%#: Eval("Major") %></td><td><%#: Eval("RequiredHours") %></td>
                                <td><asp:LinkButton ID="btnEdit" runat="server" Text="Details / Edit" CssClass="btn btn-sm btn-outline-primary" CommandArgument='<%# Eval("Id") %>' OnClick="btnEdit_Click" CausesValidation="false" /></td>
                            </tr>
                        </ItemTemplate></asp:Repeater>
                    </tbody>
                </table>
            </div>
            <asp:Label ID="lblNoStudents" runat="server" Visible="false" CssClass="text-muted" />

            <asp:Panel ID="pnlDetails" runat="server" Visible="false" CssClass="card mt-4">
                <div class="card-body p-4">
                    <h4 class="mb-3">Student details</h4>
                    <asp:Label ID="lblDetailsMessage" runat="server" Visible="false" role="alert" />
                    <p class="mb-1"><strong>Name:</strong> <asp:Label ID="lblStudentName" runat="server" /></p>
                    <p class="mb-1"><strong>Login email:</strong> <asp:Label ID="lblStudentEmail" runat="server" /></p>
                    <p class="mb-1"><strong>Phone:</strong> <asp:Label ID="lblStudentPhone" runat="server" /></p>
                    <p class="mb-3"><strong>Approved hours:</strong> <asp:Label ID="lblApprovedHours" runat="server" /></p>
                    <div class="row g-3">
                        <div class="col-md-6"><label for="<%= txtEditStudentNumber.ClientID %>" class="form-label">Student number</label><asp:TextBox ID="txtEditStudentNumber" runat="server" CssClass="form-control" MaxLength="40" /></div>
                        <div class="col-md-6"><label for="<%= txtEditUniversity.ClientID %>" class="form-label">University</label><asp:TextBox ID="txtEditUniversity" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditCollege.ClientID %>" class="form-label">College</label><asp:TextBox ID="txtEditCollege" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditMajor.ClientID %>" class="form-label">Major</label><asp:TextBox ID="txtEditMajor" runat="server" CssClass="form-control" MaxLength="120" /></div>
                        <div class="col-md-6"><label for="<%= txtEditRequiredHours.ClientID %>" class="form-label">Required training hours</label><asp:TextBox ID="txtEditRequiredHours" runat="server" CssClass="form-control" TextMode="Number" /></div>
                        <div class="col-12"><asp:Button ID="btnSaveDetails" runat="server" Text="Save changes" CssClass="btn btn-primary" OnClick="btnSaveDetails_Click" CausesValidation="false" /></div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </div>

</asp:Content>
