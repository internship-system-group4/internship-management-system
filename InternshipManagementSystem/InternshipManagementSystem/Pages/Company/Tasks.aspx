<%@ Page Language="C#" MasterPageFile="~/Layout/Company.master" AutoEventWireup="true" CodeBehind="Tasks.aspx.cs" Inherits="InternshipManagementSystem.Pages.CompanyArea.Tasks" Title="Manage Tasks" %>

<asp:Content ID="Head" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Body" ContentPlaceHolderID="MainContent" runat="server">

    <%-- ===================================================================
         Manage Tasks
         Owner : Fatima
         Cards : F01, F02
         Delete the placeholder below and build the page here.
         =================================================================== --%>

    <!--<div class="uims-stub">
        <span class="uims-stub-badge">F01, F02</span>
        <h2>Manage Tasks</h2>
        <p>Create tasks with title, description, instructions, deadline, trainee and evaluation criteria, and list them with their submission statuses. Set each task's MaxScore and Weight from the university's method - not a flat 100.</p>
        <p class="uims-stub-owner">Assigned to <strong>Fatima</strong></p>
    </div>
        -->
    <div class="uims-card">

        <h3>Create Task</h3>

        <div class="mb-3">

            <asp:Label
                ID="lblTaskTitle"
                runat="server"
                AssociatedControlID="txtTitle"
                CssClass="form-label"
                Text="Task Title" />

            <asp:TextBox
                ID="txtTitle"
                runat="server"
                CssClass="form-control" />
            <div class="mb-3">
            </div>
            <asp:Label
                ID="lblDescription"
                runat="server"
                AssociatedControlID="txtDescription"
                CssClass="form-label"
                Text="Description" />

            <asp:TextBox
                ID="txtDescription"
                runat="server"
                CssClass="form-control"
                TextMode="MultiLine"
                Rows="4" />

        </div>

        <div class="mb-3">

            <asp:Label
                ID="lblInstructions"
                runat="server"
                AssociatedControlID="txtInstructions"
                CssClass="form-label"
                Text="Instructions" />

            <asp:TextBox
                ID="txtInstructions"
                runat="server"
                CssClass="form-control"
                TextMode="MultiLine"
                Rows="4" />

        </div>
        <div class="mb-3">

            <asp:Label
                ID="lblDeadline"
                runat="server"
                AssociatedControlID="txtDeadline"
                CssClass="form-label"
                Text="Deadline" />

            <asp:TextBox
                ID="txtDeadline"
                runat="server"
                CssClass="form-control"
                TextMode="DateTimeLocal" />

        </div>
        <div class="mb-3">

            <asp:Label
                ID="lblTrainee"
                runat="server"
                AssociatedControlID="ddlTrainee"
                CssClass="form-label"
                Text="Assigned Trainee" />

            <asp:DropDownList
                ID="ddlTrainee"
                runat="server"
                CssClass="form-select">

                <asp:ListItem Text="Select a trainee" Value="" />

            </asp:DropDownList>

        </div>
        <div class="mb-3">

            <asp:Label
                ID="lblMaxScore"
                runat="server"
                AssociatedControlID="txtMaxScore"
                CssClass="form-label"
                Text="Maximum Score" />

            <asp:TextBox
                ID="txtMaxScore"
                runat="server"
                CssClass="form-control"
                TextMode="Number"
                min="0.01"
                step="0.01" />

        </div>
        <div class="mb-3">

            <asp:Label
                ID="lblWeight"
                runat="server"
                AssociatedControlID="txtWeight"
                CssClass="form-label"
                Text="Task Weight" />

            <asp:TextBox
                ID="txtWeight"
                runat="server"
                CssClass="form-control"
                TextMode="Number"
                min="0.01"
                step="0.01" />

        </div>
        <h3 class="mt-4">Evaluation Criteria</h3>

        <div class="mb-3">

            <asp:Label
                ID="lblCriterionName"
                runat="server"
                AssociatedControlID="txtCriterionName"
                CssClass="form-label"
                Text="Criterion Name" />

            <asp:TextBox
                ID="txtCriterionName"
                runat="server"
                CssClass="form-control" />

        </div>

        <div class="mb-3">

            <asp:Label
                ID="lblCriterionDescription"
                runat="server"
                AssociatedControlID="txtCriterionDescription"
                CssClass="form-label"
                Text="Criterion Description" />

            <asp:TextBox
                ID="txtCriterionDescription"
                runat="server"
                CssClass="form-control"
                TextMode="MultiLine"
                Rows="2" />

        </div>
        <div class="mb-3">

            <asp:Label
                ID="lblCriterionMaxScore"
                runat="server"
                AssociatedControlID="txtCriterionMaxScore"
                CssClass="form-label"
                Text="Criterion Maximum Score" />

            <asp:TextBox
                ID="txtCriterionMaxScore"
                runat="server"
                CssClass="form-control"
                TextMode="Number"
                min="0.01"
                step="0.01" />

        </div>

        <div class="mb-3">

            <asp:Label
                ID="lblCriterionWeight"
                runat="server"
                AssociatedControlID="txtCriterionWeight"
                CssClass="form-label"
                Text="Criterion Weight (%)" />

            <asp:TextBox
                ID="txtCriterionWeight"
                runat="server"
                CssClass="form-control"
                TextMode="Number"
                min="0.01"
                max="100"
                step="0.01" />

        </div>
        <asp:Button
    ID="btnAddCriterion"
    runat="server"
    Text="Add Criterion"
    CssClass="btn btn-outline-secondary mb-3"
    CausesValidation="false"
    OnClick="btnAddCriterion_Click" />
        <asp:GridView
    ID="gvCriteria"
    runat="server"
    AutoGenerateColumns="false"
    CssClass="uims-table"
    GridLines="None"
    EmptyDataText="No criteria added yet."
    ShowHeaderWhenEmpty="true">

    <Columns>

        <asp:BoundField
            DataField="Name"
            HeaderText="Criterion"
            HtmlEncode="true" />

        <asp:BoundField
            DataField="Description"
            HeaderText="Description"
            HtmlEncode="true" />

        <asp:BoundField
            DataField="MaxScore"
            HeaderText="Maximum Score" />

        <asp:BoundField
            DataField="Weight"
            HeaderText="Weight (%)" />

    </Columns>

</asp:GridView>
        <div class="mt-4">

   <asp:Button
    ID="btnCreateTask"
    runat="server"
    Text="Create Task"
    CssClass="btn btn-brand"
    OnClick="btnCreateTask_Click" />

</div>

<div class="mt-3">

    <asp:Label
        ID="lblMessage"
        runat="server"
        EnableViewState="false" />

</div>
    </div>
</asp:Content>

