<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="WorkspaceJourney.ascx.cs" Inherits="InternshipManagementSystem.Layout.WorkspaceJourney" %>
<% if (Model != null && Model.Stages.Count > 0) { %>
<section class="ws-journey" data-workspace-journey aria-label="<%: Model.Title %>">
    <div class="ws-journey-heading"><h3><%: Model.Title %></h3><span>Select a stage for details <span data-ui-icon="next" aria-hidden="true"></span></span></div>
    <p class="ws-journey-context"><%: Model.Context %></p>
    <p class="ws-journey-mobile-help">Swipe through stages. Select one to view its details.</p>
    <div class="ws-journey-track" style="--journey-count:<%: Model.Stages.Count %>">
        <div class="ws-journey-marker" aria-hidden="true"></div>
        <% for (int i = 0; i < Model.Stages.Count; i++) { var stage = Model.Stages[i]; %>
        <button type="button" class="ws-journey-step" data-stage-state="<%: stage.State %>" data-journey-template="<%: ClientID + "_stage_" + i %>" data-journey-title="<%: stage.Title %>" data-journey-dialog="<%: DialogId %>" aria-haspopup="dialog" aria-controls="<%: DialogId %>" aria-expanded="false" <% if(stage.State == "current") { %>aria-current="step"<% } %>>
            <span class="ws-journey-symbol" aria-hidden="true"><% if(stage.State == "completed") { %><span data-ui-icon="approved"></span><% } else if(stage.State == "blocked") { %><span data-ui-icon="warning"></span><% } else { %><span data-ui-icon="<%: stage.State == "current" ? "next" : "clock" %>"></span><% } %></span>
            <span class="ws-journey-title"><%: stage.Title %></span><span class="ws-journey-summary"><%: stage.Summary %></span><span class="ws-journey-state"><%: stage.StateLabel %></span>
        </button>
        <% } %>
    </div>
</section>
<% for(int i = 0; i < Model.Stages.Count; i++) { var stage = Model.Stages[i]; %>
<template id="<%: ClientID + "_stage_" + i %>">
    <p class="ws-dialog-lead"><%: stage.Description %></p>
    <dl class="ws-dialog-facts"><% foreach(var fact in stage.Facts) { %><div><dt><%: fact.Label %></dt><dd><%: fact.Value %></dd></div><% } %></dl>
    <div class="ws-dialog-actions"><% foreach(var action in stage.Actions) { %><a class="btn btn-brand" href="<%: ResolveUrl(action.Url) %>"><%: action.Label %><span data-ui-icon="next" aria-hidden="true"></span></a><% } %></div>
</template>
<% } %>
<div class="modal fade ws-journey-modal" id="<%: DialogId %>" tabindex="-1" aria-labelledby="<%: DialogId + "_title" %>" aria-hidden="true">
 <div class="modal-dialog modal-dialog-centered modal-dialog-scrollable"><div class="modal-content">
  <div class="modal-header"><div><p class="ws-dialog-context"><%: Model.Title %></p><h2 class="modal-title" id="<%: DialogId + "_title" %>">Journey details</h2></div><button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close journey details"></button></div>
  <div class="modal-body" data-journey-body></div>
  <div class="modal-footer"><span>Details reflect the current server record.</span><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Close</button></div>
 </div></div>
</div>
<% } %>
