<%@ Page Language="C#"
    MasterPageFile="~/Layout/Coordinator.master"
    AutoEventWireup="true"
    Async="true"
    CodeBehind="ContactMessages.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CoordinatorArea.CoordinatorContactMessages"
    Title="Contact Messages" %>
<%@ Import Namespace="InternshipManagementSystem.Pages.CoordinatorArea" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server"></asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">
    <div class="students-page dir-page">
        <header class="dir-head">
            <div>
                <div class="dir-crumb"><%: L.T("Coordinator.ContactMessages.Crumb") %></div>
                <h2><%: L.T("Coordinator.ContactMessages.ContactMessages") %></h2>
                <p><%: L.T("Coordinator.ContactMessages.ViewAndManageMessagesSubmittedThrough") %></p>
            </div>
        </header>

        <asp:Label ID="lblError" runat="server" CssClass="alert alert-danger d-block" Visible="false" />

        <ul class="dir-stats">
            <li style="--dir-i:0"><span class="dir-stat-icon" data-ui-icon="mail" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.ContactMessages.TotalMessages") %></span><strong><asp:Literal ID="litTotal" runat="server" /></strong></div></li>
            <li style="--dir-i:1"><span class="dir-stat-icon is-warning" data-ui-icon="warning" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.ContactMessages.NewMessages") %></span><strong><asp:Literal ID="litNew" runat="server" /></strong></div></li>
            <li style="--dir-i:2"><span class="dir-stat-icon is-success" data-ui-icon="approved" aria-hidden="true"></span><div><span class="dir-label"><%: L.T("Coordinator.ContactMessages.ReviewedMessages") %></span><strong><asp:Literal ID="litReviewed" runat="server" /></strong></div></li>
        </ul>

        <section class="dir-card" aria-labelledby="messagesHeading">
            <div class="dir-toolbar">
                <div class="dir-title"><h3 id="messagesHeading"><%: L.T("Coordinator.ContactMessages.ContactMessages") %> <span class="dir-count"><%: gvMessages.Rows.Count %></span></h3><p><%: L.T("Coordinator.ContactMessages.DirectoryHelp") %></p></div>
                <asp:Panel ID="pnlSearch" runat="server" CssClass="dir-filters" DefaultButton="btnSearch">
                    <label class="dir-search"><span class="visually-hidden"><%: L.T("Coordinator.ContactMessages.Search") %></span><span data-ui-icon="search" aria-hidden="true"></span><asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" TextMode="Search" placeholder="<%$ Resources:Coordinator, ContactMessages.SearchByNameEmailSubjectOr %>" /></label>
                    <label><span class="visually-hidden"><%: L.T("Coordinator.ContactMessages.Status") %></span><asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-select">
                        <asp:ListItem Value="All" Text="<%$ Resources:Coordinator, ContactMessages.AllMessages %>" />
                        <asp:ListItem Value="New" Text="<%$ Resources:Shared, Value.ContactMessageStatus.New %>" />
                        <asp:ListItem Value="Reviewed" Text="<%$ Resources:Shared, Value.ContactMessageStatus.Reviewed %>" />
                    </asp:DropDownList></label>
                    <asp:Button ID="btnSearch" runat="server" Text="<%$ Resources:Coordinator, ContactMessages.Search %>" CssClass="btn btn-brand" OnClick="btnSearch_Click" />
                </asp:Panel>
            </div>

            <div class="table-responsive">
                <asp:GridView ID="gvMessages" runat="server" AutoGenerateColumns="false" CssClass="dir-table" GridLines="None" CellSpacing="-1" ShowHeaderWhenEmpty="true"
                    EmptyDataText="<%$ Resources:Coordinator, ContactMessages.NoMessagesFound %>" OnRowCommand="gvMessages_RowCommand">
                    <Columns>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, ContactMessages.Name %>">
                            <ItemTemplate>
                                <div class="dir-person"><span class="dir-avatar" aria-hidden="true"><%#: StudentDirectoryRow.MakeInitials(Convert.ToString(Eval("Name"))) %></span><div><strong><%#: Eval("Name") %></strong><small><%#: Eval("Email") %></small></div></div>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, ContactMessages.Subject %>">
                            <ItemTemplate><%#: Eval("Subject") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, ContactMessages.Date %>">
                            <ItemTemplate><span class="dir-num"><%#: Eval("FormattedDate") %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, ContactMessages.Status %>">
                            <ItemTemplate><span class='<%# StatusCss(Eval("Status")) %>'><%#: L.Value("Ui", Eval("Status")) %></span></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="<%$ Resources:Coordinator, ContactMessages.Actions %>" HeaderStyle-CssClass="dir-actions-col">
                            <ItemTemplate>
                                <div class="dir-actions">
                                    <asp:LinkButton ID="btnDetails" runat="server" CssClass="dir-btn dir-btn-primary" CommandName="Details" CommandArgument='<%# Eval("Id") %>' ToolTip="<%$ Resources:Coordinator, ContactMessages.ViewMessageDetails %>" CausesValidation="false"><span data-ui-icon="eye" aria-hidden="true"></span> <%# L.T("Coordinator.ContactMessages.ReviewAction") %></asp:LinkButton>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>
        </section>

        <%-- Message details pop-up (filled by the server after "Review"). --%>
        <div id="messageModal" class="dir-overlay dir-modal" role="dialog" aria-modal="true" aria-labelledby="messageModalTitle">
            <asp:Panel ID="pnlDetails" runat="server" CssClass="modal-content" Visible="false">
                <div class="modal-header dir-modal-hero">
                    <span class="dir-avatar dir-avatar-lg" aria-hidden="true"><span data-ui-icon="mail"></span></span>
                    <div class="dir-hero-text"><span class="dir-eyebrow"><%: L.T("Coordinator.ContactMessages.MessageDetails") %></span><h3 class="modal-title" id="messageModalTitle"><asp:Literal ID="litSubject" runat="server" /></h3><p><asp:Literal ID="litStatus" runat="server" /></p></div>
                    <button type="button" class="btn-close" onclick="closeMessageModal()" aria-label="<%: L.T("Coordinator.ContactMessages.Close") %>"></button>
                </div>
                <div class="modal-body">
                    <div class="dir-info-grid">
                        <section><h4><span data-ui-icon="person" aria-hidden="true"></span><%: L.T("Coordinator.ContactMessages.SenderInformation") %></h4><dl>
                            <div><dt><%: L.T("Coordinator.ContactMessages.Name2") %></dt><dd><asp:Literal ID="litFrom" runat="server" /></dd></div>
                            <div><dt><%: L.T("Coordinator.ContactMessages.Email2") %></dt><dd><asp:Literal ID="litEmail" runat="server" /></dd></div>
                            <div><dt><%: L.T("Coordinator.ContactMessages.Date2") %></dt><dd><asp:Literal ID="litSubmitted" runat="server" /></dd></div>
                        </dl></section>
                        <section><h4><span data-ui-icon="document" aria-hidden="true"></span><%: L.T("Coordinator.ContactMessages.MessageContent") %></h4>
                            <div class="dir-message-box"><asp:Literal ID="litFullMessage" runat="server" /></div>
                        </section>
                    </div>
                </div>
                <div class="modal-footer">
                    <asp:Button ID="btnClose" runat="server" Text="<%$ Resources:Coordinator, ContactMessages.Close %>" CssClass="btn btn-outline-secondary" OnClick="btnClose_Click" CausesValidation="false" />
                    <asp:Button ID="btnMarkReviewed" runat="server" Text="<%$ Resources:Coordinator, ContactMessages.MarkAsReviewed %>" CssClass="btn btn-brand" OnClick="btnMarkReviewed_Click" data-ui-action="mark" data-loading-label="<%$ Resources:Shared, I18n.Updating %>" />
                </div>
            </asp:Panel>
        </div>
    </div>

    <%-- Defined inside the form: the server calls openMessageModal() from a startup script. --%>
    <script>
        function openMessageModal() {
            var modal = document.getElementById('messageModal');
            if (modal) { modal.classList.add('open'); document.body.style.overflow = 'hidden'; }
        }
        function closeMessageModal() {
            var modal = document.getElementById('messageModal');
            if (modal) { modal.classList.remove('open'); document.body.style.overflow = ''; }
        }
        document.addEventListener('keydown', function (event) { if (event.key === 'Escape') closeMessageModal(); });
        document.addEventListener('click', function (event) { if (event.target && event.target.id === 'messageModal') closeMessageModal(); });
    </script>
</asp:Content>
