
<%@ Page Language="C#" AutoEventWireup="true" Async="true"
    CodeBehind="CoordinatorContactMessages.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CoordinatorContactMessages" %>

<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Contact Messages | GJU UIMS</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
          rel="stylesheet" />

    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css"
          rel="stylesheet" />

    <style>
        :root {
            --navy: #092e68;
            --blue: #164b84;
            --border: #d6e5f6;
            --background: #f2f8ff;
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: Arial, sans-serif;
            background: var(--background);
            color: var(--navy);
        }

        /* ===== Layout ===== */

        .app-layout {
            display: flex;
            min-height: 100vh;
        }

        .main-area {
            flex: 1;
            min-width: 0;
        }

        /* ===== Sidebar ===== */

        .sidebar {
            width: 258px;
            flex: 0 0 258px;
            background: #fff;
            border-right: 1px solid #e5edf6;
            display: flex;
            flex-direction: column;
            position: sticky;
            top: 0;
            height: 100vh;
            z-index: 10;
        }

        .sidebar-brand {
            text-align: center;
            padding: 24px 12px 12px;
        }

        .gju-logo {
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 5px;
        }

        .gju-symbol {
            font-size: 44px;
            font-weight: 700;
            color: #edaa24;
            text-shadow: -7px 5px #247cae;
        }

        .gju-letters {
            font-size: 29px;
            font-weight: 600;
            color: #666;
        }

        .brand-ar {
            font-size: 10px;
            color: #555;
            margin-top: 5px;
        }

        .brand-en {
            font-size: 9px;
            color: #777;
        }

        .brand-name {
            font-size: 13px;
            font-weight: 700;
            margin-top: 15px;
            color: var(--navy);
        }

        .role-chip {
            display: inline-block;
            background: #e6f1ff;
            color: #21548b;
            font-size: 12px;
            padding: 6px 12px;
            border-radius: 18px;
            margin-top: 11px;
        }

        .sidebar-nav {
            padding: 10px 15px;
            display: flex;
            flex-direction: column;
            gap: 5px;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: #244a78;
            font-size: 14px;
            border-radius: 5px;
            padding: 12px 14px;
            transition: background .2s;
        }

        .sidebar-nav a i {
            font-size: 17px;
            width: 20px;
        }

        .sidebar-nav a:hover {
            background: #eff6ff;
        }

        .sidebar-nav a.active {
            background: #244e76;
            color: white;
            font-weight: 600;
        }

        .sidebar-bottom {
            margin: auto 22px 20px;
            padding-top: 14px;
            border-top: 1px solid #e5edf6;
        }

        .sidebar-bottom a {
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: #244a78;
            font-size: 14px;
            padding: 12px 14px;
        }

        /* ===== Page ===== */

        .page-content {
            padding: 26px 30px;
            max-width: 1600px;
            margin: auto;
        }

        .breadcrumb-line {
            font-size: 14px;
            margin-bottom: 8px;
            color: #40669b;
        }

        .page-title {
            font-size: 30px;
            font-weight: 700;
            margin-bottom: 4px;
        }

        .page-subtitle {
            color: #43669c;
            font-size: 16px;
            margin-bottom: 20px;
        }

        /* ===== Summary Cards ===== */

        .summary-card {
            display: flex;
            align-items: center;
            gap: 22px;
            padding: 20px;
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 10px;
            min-height: 106px;
        }

        .summary-icon {
            width: 70px;
            height: 70px;
            border-radius: 50%;
            display: grid;
            place-items: center;
            font-size: 30px;
            flex-shrink: 0;
        }

        .summary-icon.total {
            background: #e4f0ff;
            color: #1254a1;
        }

        .summary-icon.new {
            background: #fff1d2;
            color: #f0a000;
        }

        .summary-icon.reviewed {
            background: #def8ed;
            color: #009e73;
        }

        .summary-label {
            font-size: 15px;
            font-weight: 600;
            color: #294d83;
        }

        .summary-value {
            font-size: 32px;
            font-weight: 700;
        }

        /* ===== Panels ===== */

        .content-panel {
            background: #fff;
            border: 1px solid var(--border);
            border-radius: 10px;
            padding: 18px;
            margin-bottom: 16px;
        }

        .section-title {
            font-size: 19px;
            font-weight: 700;
            margin-bottom: 14px;
        }

        /* ===== Search ===== */

        .form-label {
            font-weight: 600;
            font-size: 14px;
            margin-bottom: 5px;
        }

        .form-control,
        .form-select,
        .input-group-text {
            min-height: 44px;
            border-color: #ccddf2;
        }

        .input-group-text {
            background: #fff;
            color: #456a9e;
        }

        .btn-main {
            background: #104784;
            border: 1px solid #104784;
            color: white;
            min-height: 44px;
            font-weight: 600;
        }

        .btn-main:hover {
            background: #08346a;
            color: white;
        }

        /* ===== Table ===== */

        .messages-table {
            border: 1px solid var(--border);
            border-radius: 8px;
            overflow: hidden;
        }

        .messages-table .table {
            margin-bottom: 0;
            --bs-table-color: #173d76;
        }

        .messages-table th {
            background: #edf5fd;
            font-size: 14px;
            font-weight: 700;
            padding: 14px;
            white-space: nowrap;
        }

        .messages-table td {
            padding: 13px 14px;
            font-size: 14px;
            border-color: #e4edf8;
        }

        .messages-table tr:hover td {
            background: #f3f9ff;
        }

        .email-text {
            color: #5272a1;
            font-size: 13px;
        }

        .status-badge {
            display: inline-block;
            padding: 6px 14px;
            border-radius: 25px;
            font-size: 13px;
            font-weight: 600;
        }

        .status-badge.new {
            color: #a46b00;
            background: #fff0cc;
        }

        .status-badge.reviewed {
            color: #008b64;
            background: #def7e9;
        }

        /* ===== View Button ===== */

        .action-button {
            display: inline-block;
            border: 1px solid #cfe0f6;
            border-radius: 7px;
            background: #f5faff;
            color: #164b84;
            padding: 7px 16px;
            text-decoration: none;
            font-size: 13px;
            font-weight: 600;
            transition: .2s;
        }

        .action-button:hover {
            background: #e3f0ff;
            color: #092e68;
        }

        /* ===== Message Details ===== */

        .details-info {
            border: 1px solid var(--border);
            border-radius: 8px;
            overflow: hidden;
        }

        .details-row {
            display: flex;
            padding: 11px 15px;
            gap: 12px;
            font-size: 14px;
        }

        .details-row:nth-child(odd) {
            background: #f1f7fd;
        }

        .details-label {
            width: 100px;
            flex-shrink: 0;
            font-weight: 700;
        }

        .details-value {
            overflow-wrap: anywhere;
        }

        .message-box {
            min-height: 140px;
            background: #f2f7fd;
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 18px;
            line-height: 1.7;
            overflow-wrap: anywhere;
        }

        .btn-reviewed {
            background: #104784;
            border-color: #104784;
            color: #fff;
        }

        .btn-reviewed:hover {
            background: #08346a;
            color: #fff;
        }

        /* ===== Responsive ===== */

        @media (max-width: 992px) {
            .sidebar {
                width: 215px;
                flex-basis: 215px;
            }

            .page-content {
                padding: 20px;
            }
        }

        @media (max-width: 768px) {
            .app-layout {
                display: block;
            }

            .sidebar {
                position: relative;
                width: 100%;
                height: auto;
            }

            .sidebar-nav {
                flex-direction: row;
                overflow-x: auto;
            }

            .sidebar-nav a {
                white-space: nowrap;
            }

            .sidebar-bottom {
                display: none;
            }

            .page-content {
                padding: 18px 12px;
            }

            .page-title {
                font-size: 25px;
            }

            .summary-icon {
                width: 56px;
                height: 56px;
            }

            .details-row {
                flex-wrap: wrap;
            }
        }
    </style>
</head>

<body>
<form id="form1" runat="server">

<div class="app-layout">

    <!-- ========== SIDEBAR ========== -->

    
    <!-- ========== MAIN CONTENT ========== -->

    <div class="main-area">

        <main class="page-content">

            <!-- Header -->

            <h1 class="page-title">
                Contact Messages
            </h1>

            <p class="page-subtitle">
                View and manage messages submitted through
                the Contact Us form.
            </p>

            <asp:Label ID="lblError" runat="server"
                CssClass="alert alert-danger d-block"
                Visible="false" />

            <!-- ========== SUMMARY CARDS ========== -->

            <div class="row g-3 mb-3">

                <!-- Total Messages -->

                <div class="col-lg-4">

                    <div class="summary-card">

                        <div class="summary-icon total">
                            <i class="bi bi-envelope"></i>
                        </div>

                        <div>
                            <div class="summary-label">
                                Total Messages
                            </div>

                            <div class="summary-value">
                                <asp:Literal ID="litTotal"
                                    runat="server" />
                            </div>
                        </div>

                    </div>

                </div>

                <!-- New Messages -->

                <div class="col-lg-4">

                    <div class="summary-card">

                        <div class="summary-icon new">
                            <i class="bi bi-envelope-exclamation"></i>
                        </div>

                        <div>
                            <div class="summary-label">
                                New Messages
                            </div>

                            <div class="summary-value">
                                <asp:Literal ID="litNew"
                                    runat="server" />
                            </div>
                        </div>

                    </div>

                </div>

                <!-- Reviewed Messages -->

                <div class="col-lg-4">

                    <div class="summary-card">

                        <div class="summary-icon reviewed">
                            <i class="bi bi-envelope-check"></i>
                        </div>

                        <div>
                            <div class="summary-label">
                                Reviewed Messages
                            </div>

                            <div class="summary-value">
                                <asp:Literal ID="litReviewed"
                                    runat="server" />
                            </div>
                        </div>

                    </div>

                </div>

            </div>

            <!-- ========== SEARCH & FILTER ========== -->

            <div class="content-panel">

                <div class="row g-3 align-items-end">

                    <div class="col-lg-6">

                        <label class="form-label">
                            Search
                        </label>

                        <div class="input-group">

                            <span class="input-group-text">
                                <i class="bi bi-search"></i>
                            </span>

                            <asp:TextBox ID="txtSearch"
                                runat="server"
                                CssClass="form-control"
                                placeholder="Search by name, email, subject or message..." />

                        </div>

                    </div>

                    <div class="col-lg-4">

                        <label class="form-label">
                            Status
                        </label>

                        <asp:DropDownList ID="ddlStatus"
                            runat="server"
                            CssClass="form-select">

                            <asp:ListItem Value="All">
                                All Messages
                            </asp:ListItem>

                            <asp:ListItem Value="New">
                                New
                            </asp:ListItem>

                            <asp:ListItem Value="Reviewed">
                                Reviewed
                            </asp:ListItem>

                        </asp:DropDownList>

                    </div>

                    <div class="col-lg-2">

                        <asp:Button ID="btnSearch"
                            runat="server"
                            Text="Search"
                            CssClass="btn btn-main w-100"
                            OnClick="btnSearch_Click" />

                    </div>

                </div>

            </div>

            <!-- ========== MESSAGES TABLE ========== -->

            <div class="content-panel">

                <div class="d-flex justify-content-between align-items-center mb-3">

                    <h2 class="section-title mb-0">
                        Contact Messages
                    </h2>

                </div>

                <div class="table-responsive messages-table">

                    
<asp:GridView ID="gvMessages"
    runat="server"
    AutoGenerateColumns="false"
    CssClass="table align-middle"
    GridLines="None"
    ShowHeaderWhenEmpty="true"
    EmptyDataText="No messages found."
    OnRowCommand="gvMessages_RowCommand">

    <Columns>

        <asp:TemplateField HeaderText="Name">
            <ItemTemplate>
                <%#: Eval("Name") %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Email">
            <ItemTemplate>
                <span class="email-text">
                    <%#: Eval("Email") %>
                </span>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Subject">
            <ItemTemplate>
                <%#: Eval("Subject") %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:BoundField
            DataField="FormattedDate"
            HeaderText="Date"
            HtmlEncode="true" />

        <asp:TemplateField HeaderText="Status">
            <ItemTemplate>
                <span class='<%# Convert.ToString(Eval("Status")) == "Reviewed" ? "status-badge reviewed" : "status-badge new" %>'>
                    <%#: Eval("Status") %>
                </span>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Actions">
            <ItemTemplate>
                <asp:LinkButton
                    ID="btnDetails"
                    runat="server"
                    CssClass="action-button"
                    CommandName="Details"
                    CommandArgument='<%# Eval("Id") %>'
                    ToolTip="View Message Details"
                    CausesValidation="false">
                    View
                </asp:LinkButton>
            </ItemTemplate>
        </asp:TemplateField>

    </Columns>

</asp:GridView>

                </div>

            </div>

            <!-- ========== MESSAGE DETAILS ========== -->

            <asp:Panel ID="pnlDetails"
                runat="server"
                CssClass="content-panel"
                Visible="false">

                <div class="row g-4">

                    <!-- Message Information -->

                    <div class="col-lg-5">

                        <h2 class="section-title">

                            <i class="bi bi-envelope me-2"></i>
                            Message Details

                        </h2>

                        <div class="details-info">

                            <!-- Name -->

                            <div class="details-row">

                                <span class="details-label">
                                    Name:
                                </span>

                                <span class="details-value">

                                    <asp:Literal ID="litFrom"
                                        runat="server" />

                                </span>

                            </div>

                            <!-- Email -->

                            <div class="details-row">

                                <span class="details-label">
                                    Email:
                                </span>

                                <span class="details-value">

                                    <asp:Literal ID="litEmail"
                                        runat="server" />

                                </span>

                            </div>

                            <!-- Subject -->

                            <div class="details-row">

                                <span class="details-label">
                                    Subject:
                                </span>

                                <span class="details-value">

                                    <asp:Literal ID="litSubject"
                                        runat="server" />

                                </span>

                            </div>

                            <!-- Date -->

                            <div class="details-row">

                                <span class="details-label">
                                    Date:
                                </span>

                                <span class="details-value">

                                    <asp:Literal ID="litSubmitted"
                                        runat="server" />

                                </span>

                            </div>

                            <!-- Status -->

                            <div class="details-row">

                                <span class="details-label">
                                    Status:
                                </span>

                                <span class="details-value">

                                    <asp:Literal ID="litStatus"
                                        runat="server" />

                                </span>

                            </div>

                        </div>

                    </div>

                    <!-- Message Content -->

                    <div class="col-lg-7">

                        <h2 class="section-title">

                            <i class="bi bi-file-text me-2"></i>
                            Message Content

                        </h2>

                        <div class="message-box">

                            <asp:Literal ID="litFullMessage"
                                runat="server" />

                        </div>

                        <!-- Action Buttons -->

                        <div class="d-flex justify-content-end gap-2 mt-3 flex-wrap">

                            <!-- Reply -->

                            <asp:HyperLink ID="lnkReply"
                                runat="server"
                                CssClass="btn btn-outline-primary">

                                <i class="bi bi-reply me-1"></i>
                                Reply (Email)

                            </asp:HyperLink>

                            <!-- Mark as Reviewed -->

                            <asp:Button ID="btnMarkReviewed"
                                runat="server"
                                Text="Mark as Reviewed"
                                CssClass="btn btn-reviewed"
                                OnClick="btnMarkReviewed_Click" />

                            <!-- Close -->

                            <asp:Button ID="btnClose"
                                runat="server"
                                Text="Close"
                                CssClass="btn btn-outline-secondary"
                                OnClick="btnClose_Click"
                                CausesValidation="false" />

                        </div>

                    </div>

                </div>

            </asp:Panel>

        </main>

    </div>



</form>


</body>
</html>


