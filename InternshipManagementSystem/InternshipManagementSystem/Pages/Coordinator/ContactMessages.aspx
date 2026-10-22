

<%@ Page Language="C#"
    MasterPageFile="~/Layout/Coordinator.master"
    AutoEventWireup="true"
    Async="true"
    CodeBehind="ContactMessages.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CoordinatorContactMessages"
    Title="Contact Messages" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

    <link rel="stylesheet"
        href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" />

    <style>
        .cm-page {
            --cm-navy: #092e68;
            --cm-blue: #164b84;
            --cm-border: #d6e5f6;
            color: var(--cm-navy);
            width: 100%;
            max-width: 1600px;
            margin: 0 auto;
            font-family: "Segoe UI", Arial, sans-serif;
        }

        .cm-page *,
        .cm-page *::before,
        .cm-page *::after {
            box-sizing: border-box;
        }

        .cm-page .page-heading {
            margin-bottom: 22px;
        }

        .cm-page .page-title {
            font-size: 28px;
            font-weight: 700;
            margin: 0 0 6px;
            color: var(--cm-navy);
        }

        .cm-page .page-subtitle {
            color: #43669c;
            font-size: 15px;
            margin: 0;
        }

        /* Summary cards */

        .cm-page .summary-card {
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 20px;
            background: #fff;
            border: 1px solid var(--cm-border);
            border-radius: 10px;
            min-height: 110px;
            height: 100%;
        }

        .cm-page .summary-icon {
            width: 64px;
            height: 64px;
            border-radius: 50%;
            display: grid;
            place-items: center;
            font-size: 27px;
            flex-shrink: 0;
        }

        .cm-page .summary-icon.total {
            background: #e4f0ff;
            color: #1254a1;
        }

        .cm-page .summary-icon.new {
            background: #fff1d2;
            color: #f0a000;
        }

        .cm-page .summary-icon.reviewed {
            background: #def8ed;
            color: #009e73;
        }

        .cm-page .summary-label {
            font-size: 14px;
            font-weight: 600;
            color: #294d83;
        }

        .cm-page .summary-value {
            font-size: 30px;
            font-weight: 700;
            color: var(--cm-navy);
        }

        /* Panels */

        .cm-page .content-panel {
            background: #fff;
            border: 1px solid var(--cm-border);
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 18px;
        }

        .cm-page .section-title {
            font-size: 19px;
            font-weight: 700;
            margin-bottom: 15px;
            color: var(--cm-navy);
        }

        /* Search */

        .cm-page .form-label {
            font-weight: 600;
            font-size: 13px;
            margin-bottom: 7px;
            color: #294d83;
        }

        .cm-page .form-control,
        .cm-page .form-select,
        .cm-page .input-group-text {
            min-height: 44px;
            border-color: #ccddf2;
            font-size: 13px;
        }

        .cm-page .input-group-text {
            background: #fff;
            color: #456a9e;
        }

        .cm-page .btn-main {
            background: #104784;
            border: 1px solid #104784;
            color: #fff;
            min-height: 44px;
            font-size: 13px;
            font-weight: 600;
        }

        .cm-page .btn-main:hover {
            background: #08346a;
            color: #fff;
        }

        /* Messages table */

        .cm-page .messages-table {
            border: 1px solid var(--cm-border);
            border-radius: 8px;
            overflow: hidden;
        }

        .cm-page .messages-table .table {
            margin-bottom: 0;
            --bs-table-color: #173d76;
        }

        .cm-page .messages-table th {
            background: #edf5fd;
            font-size: 13px;
            font-weight: 700;
            padding: 14px;
            white-space: nowrap;
            color: #173d76;
        }

        .cm-page .messages-table td {
            padding: 13px 14px;
            font-size: 13px;
            border-color: #e4edf8;
            vertical-align: middle;
        }

        .cm-page .messages-table tr:hover td {
            background: #f3f9ff;
        }

        .cm-page .email-text {
            color: #5272a1;
            font-size: 12px;
        }

        /* Status */

        .cm-page .status-badge {
            display: inline-block;
            padding: 6px 13px;
            border-radius: 25px;
            font-size: 12px;
            font-weight: 600;
        }

        .cm-page .status-badge.new {
            color: #a46b00;
            background: #fff0cc;
        }

        .cm-page .status-badge.reviewed {
            color: #008b64;
            background: #def7e9;
        }

        /* View button */

        .cm-page .action-button {
            display: inline-block;
            border: 1px solid #cfe0f6;
            border-radius: 7px;
            background: #f5faff;
            color: #164b84;
            padding: 7px 16px;
            text-decoration: none;
            font-size: 12px;
            font-weight: 600;
        }

        .cm-page .action-button:hover {
            background: #e3f0ff;
            color: #092e68;
        }

        /* Message details */

        .cm-page .details-info {
            border: 1px solid var(--cm-border);
            border-radius: 8px;
            overflow: hidden;
        }

        .cm-page .details-row {
            display: flex;
            padding: 12px 15px;
            gap: 12px;
            font-size: 13px;
        }

        .cm-page .details-row:nth-child(odd) {
            background: #f1f7fd;
        }

        .cm-page .details-label {
            width: 90px;
            flex-shrink: 0;
            font-weight: 700;
            color: #173d76;
        }

        .cm-page .details-value {
            overflow-wrap: anywhere;
            min-width: 0;
        }

        .cm-page .message-box {
            min-height: 140px;
            background: #f2f7fd;
            border: 1px solid var(--cm-border);
            border-radius: 8px;
            padding: 18px;
            line-height: 1.7;
            font-size: 13px;
            overflow-wrap: anywhere;
        }

        .cm-page .btn-reviewed {
            background: #104784;
            border: 1px solid #104784;
            color: #fff;
        }

        .cm-page .btn-reviewed:hover {
            background: #08346a;
            color: #fff;
        }

        .cm-page .details-actions .btn {
            font-size: 12px;
            font-weight: 600;
            padding: 9px 14px;
        }

        /* POPUP OVERLAY */

        #messageModal.message-modal-overlay {
            display: none;
            position: fixed !important;
            inset: 0 !important;
            width: 100vw;
            height: 100vh;
            z-index: 99999 !important;
            background: rgba(9, 30, 66, 0.65);
            align-items: center;
            justify-content: center;
            padding: 20px;
        }

        #messageModal.message-modal-overlay.open {
            display: flex !important;
        }

        /* POPUP WINDOW */

        #messageModal .message-modal-box {
            position: relative;
            background: #ffffff;
            width: 100%;
            max-width: 950px;
            max-height: 90vh;
            overflow-y: auto;
            border-radius: 16px;
            padding: 28px;
            box-shadow: 0 25px 70px rgba(0, 0, 0, 0.25);
        }

        #messageModal .message-popup {
            position: static !important;
            transform: none !important;
            width: 100% !important;
            max-width: none !important;
            padding: 0 !important;
            margin: 0 !important;
            background: transparent !important;
            box-shadow: none !important;
        }

        #messageModal .popup-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 1px solid #d6e5f6;
            padding-bottom: 15px;
            margin-bottom: 22px;
        }

        #messageModal .popup-title {
            font-size: 22px;
            font-weight: 700;
            color: #092e68;
            margin: 0;
        }

        #messageModal .popup-close {
            border: none;
            background: #edf5fd;
            color: #092e68;
            border-radius: 8px;
            width: 36px;
            height: 36px;
            font-size: 22px;
            cursor: pointer;
        }

        #messageModal .popup-close:hover {
            background: #dceafa;
        }

        /* Responsive */

        @media (max-width: 768px) {
            .cm-page .page-title {
                font-size: 24px;
            }

            .cm-page .content-panel {
                padding: 15px;
            }

            .cm-page .summary-icon {
                width: 55px;
                height: 55px;
                font-size: 24px;
            }

            .cm-page .details-row {
                flex-wrap: wrap;
            }

            #messageModal .message-modal-box {
                padding: 18px;
            }
        }

        /* Hide sidebar scrollbar */

        .uims-sidebar {
            scrollbar-width: none !important;
            -ms-overflow-style: none !important;
        }

        .uims-sidebar::-webkit-scrollbar,
        .uims-sidebar *::-webkit-scrollbar {
            display: none !important;
        }
    </style>

</asp:Content>


<asp:Content ID="Body"
    ContentPlaceHolderID="MainContent"
    runat="server">

    <div class="cm-page">

        <!-- PAGE HEADER -->

        <div class="page-heading">

            <h2 class="page-title">
                Contact Messages
            </h2>

            <p class="page-subtitle">
                View and manage messages submitted through
                the Contact Us form.
            </p>

        </div>

        <!-- ERROR -->

        <asp:Label ID="lblError"
            runat="server"
            CssClass="alert alert-danger d-block"
            Visible="false" />


        <!-- SUMMARY CARDS -->

        <div class="row g-3 mb-4">

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


        <!-- SEARCH AND FILTER -->

        <div class="content-panel">

            <div class="row g-3 align-items-end">

                <div class="col-lg-6">

                    <label class="form-label"
                        for="<%= txtSearch.ClientID %>">
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

                    <label class="form-label"
                        for="<%= ddlStatus.ClientID %>">
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


        <!-- CONTACT MESSAGES TABLE -->

        <div class="content-panel">

            <h3 class="section-title">
                Contact Messages
            </h3>

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
                                   Review
                                </asp:LinkButton>

                            </ItemTemplate>
                        </asp:TemplateField>

                    </Columns>

                </asp:GridView>

            </div>

        </div>


        <!-- MESSAGE DETAILS POPUP -->

        <div id="messageModal"
            class="message-modal-overlay"
            role="dialog"
            aria-modal="true"
            aria-label="Message Details">

            <div class="message-modal-box">

                <asp:Panel ID="pnlDetails"
                    runat="server"
                    CssClass="message-popup"
                    Visible="false">

                    <!-- POPUP HEADER -->

                    <div class="popup-header">

                        <h3 class="popup-title">
                            <i class="bi bi-envelope-open me-2"></i>
                            Message Details
                        </h3>

                        <button type="button"
                            class="popup-close"
                            onclick="closeMessageModal()"
                            aria-label="Close">
                            &times;
                        </button>

                    </div>

                    <div class="row g-4">

                        <!-- MESSAGE INFORMATION -->

                        <div class="col-lg-5">

                            <h3 class="section-title">
                                <i class="bi bi-person-lines-fill me-2"></i>
                                Sender Information
                            </h3>

                            <div class="details-info">

                                <div class="details-row">

                                    <span class="details-label">
                                        Name:
                                    </span>

                                    <span class="details-value">
                                        <asp:Literal ID="litFrom"
                                            runat="server" />
                                    </span>

                                </div>

                                <div class="details-row">

                                    <span class="details-label">
                                        Email:
                                    </span>

                                    <span class="details-value">
                                        <asp:Literal ID="litEmail"
                                            runat="server" />
                                    </span>

                                </div>

                                <div class="details-row">

                                    <span class="details-label">
                                        Subject:
                                    </span>

                                    <span class="details-value">
                                        <asp:Literal ID="litSubject"
                                            runat="server" />
                                    </span>

                                </div>

                                <div class="details-row">

                                    <span class="details-label">
                                        Date:
                                    </span>

                                    <span class="details-value">
                                        <asp:Literal ID="litSubmitted"
                                            runat="server" />
                                    </span>

                                </div>

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


                        <!-- MESSAGE CONTENT -->

                        <div class="col-lg-7">

                            <h3 class="section-title">
                                <i class="bi bi-file-text me-2"></i>
                                Message Content
                            </h3>

                            <div class="message-box">

                                <asp:Literal ID="litFullMessage"
                                    runat="server" />

                            </div>

                            <!-- ACTION BUTTONS -->

                            <div class="details-actions d-flex justify-content-end gap-2 mt-3 flex-wrap">


                                <asp:Button ID="btnMarkReviewed"
                                    runat="server"
                                    Text="Mark as Reviewed"
                                    CssClass="btn btn-reviewed"
                                    OnClick="btnMarkReviewed_Click" />

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

            </div>

        </div>

    </div>


    <!-- POPUP JAVASCRIPT -->

    <script type="text/javascript">

        function openMessageModal() {
            var modal = document.getElementById("messageModal");

            if (modal) {
                modal.classList.add("open");
                document.body.style.overflow = "hidden";
            }
        }

        function closeMessageModal() {
            var modal = document.getElementById("messageModal");

            if (modal) {
                modal.classList.remove("open");
                document.body.style.overflow = "";
            }
        }

        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                closeMessageModal();
            }
        });

    </script>

</asp:Content>