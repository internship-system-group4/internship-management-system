
<%@ Page Title="Manage Opportunities"
    Language="C#"
    MasterPageFile="~/Layout/Company.master"
    AutoEventWireup="true"
    CodeBehind="ManageOpportunities.aspx.cs"
    Inherits="InternshipManagementSystem.Pages.CompanyArea.ManageOpportunities" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">

<style>
.mo-page {
    max-width: 1200px;
    margin: 0 auto;
    color: var(--th-fg-173451, #173451);
}

.mo-heading {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 15px;
    margin-bottom: 18px;
}

.mo-heading h2 {
    font-size: 26px;
    font-weight: 750;
    margin: 0 0 5px;
}

.mo-muted {
    color: var(--th-fg-718298, #718298);

            </div>

        </div>

    <% } %>

</div>

<script type="text/javascript">

    function showToggleDialog(id, title, action) {

        var dialog =
            document.getElementById("moDialog");

        var dialogTitle =
            document.getElementById("moDialogTitle");

        var message =
            document.getElementById("moDialogMessage");

        var confirmButton =
            document.getElementById("moConfirmButton");

        var hiddenId =
            document.getElementById("moToggleId");

        var dialogIcon =
            document.getElementById("moDialogIcon");

        if (!dialog ||
            !dialogTitle ||
            !message ||
            !confirmButton ||
            !hiddenId) {
            return;
        }

        hiddenId.value = id;

        if (action === "deactivate") {

            dialogTitle.textContent =
                dialog.dataset.deactivateTitle;

            message.textContent =
                dialog.dataset.deactivateMessage.replace('{0}', function () { return title; });

            confirmButton.textContent =
                dialog.dataset.deactivateLabel;

            confirmButton.classList.remove(
                "mo-btn-success"
            );

            confirmButton.classList.add(
                "mo-btn-danger"
            );

            if (dialogIcon) {
                dialogIcon.textContent = "−";
                if (window.UimsUI) dialogIcon.replaceChildren(window.UimsUI.icon('warning'));
                dialogIcon.classList.remove("activate");
            }

        } else {

            dialogTitle.textContent =
                dialog.dataset.activateTitle;

            message.textContent =
                dialog.dataset.activateMessage.replace('{0}', function () { return title; });

            confirmButton.textContent =
                dialog.dataset.activateLabel;

            confirmButton.classList.remove(
                "mo-btn-danger"
            );

            confirmButton.classList.add(
                "mo-btn-success"
            );

            if (dialogIcon) {
                dialogIcon.textContent = "✓";
                if (window.UimsUI) dialogIcon.replaceChildren(window.UimsUI.icon('approved'));
                dialogIcon.classList.add("activate");
            }
        }

        dialog.classList.add("show");
        dialog.setAttribute("aria-hidden", "false");
        // The shared supervisor dialog enhancement manages focus and keyboard navigation.
    }

    function hideToggleDialog() {

        var dialog =
            document.getElementById("moDialog");

        if (dialog) {

            dialog.classList.remove("show");
            dialog.setAttribute("aria-hidden", "true");
        }
    }

    document.addEventListener(
        "keydown",
        function (event) {

            if (event.key === "Escape") {
                hideToggleDialog();
            }
        }
    );

    document.addEventListener(
        "click",
        function (event) {

            var dialog =
                document.getElementById("moDialog");

            if (dialog && event.target === dialog) {
                hideToggleDialog();
            }
        }
    );

</script>

</asp:Content>
