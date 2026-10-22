// =============================================================================
//  UIMS - Group 4   |   Owner: Sara Rajoub  (Trello card R01)
//  Internship opportunities (cards R01-R04).
// =============================================================================

using System.Collections.Generic;
using System;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class OpportunityRepository : RepositoryBase<Opportunity>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Opportunities; }
        }

        protected override void SetId(Opportunity entity, string id)
        {
            entity.Id = id;
        }

        // Separate allowlisted projection: never expose the protected opportunity
        // collection or its requirements/contacts to anonymous homepage visitors.
        public List<PublicOpportunityPreview> GetPublicPreviews()
        {
            var raw = Json.Deserialize<Dictionary<string, PublicOpportunityPreview>>(
                FirebaseContext.Get("publicOpportunityPreviews"));
            if (raw == null) return new List<PublicOpportunityPreview>();
            foreach (var pair in raw) if (pair.Value != null) pair.Value.Id = pair.Key;
            return raw.Values.Where(p => p != null && ApplicationRepository.IsValidKey(p.Id)
                && p.Status == OpportunityStatus.Open && p.RemainingSeats > 0
                && (p.ApplicationDeadline <= 0 || !Time.IsPast(p.ApplicationDeadline))
                && !string.IsNullOrWhiteSpace(p.Title) && p.Title.Length <= 150
                && (p.Summary ?? "").Length <= 280 && (p.CompanyName ?? "").Length <= 150
                && (p.Location ?? "").Length <= 150)
                .OrderByDescending(p => p.PublishedAt).Take(3).ToList();
        }

        // Explicit publication by a verified owner/coordinator; private workflows
        // can call this after saving an opportunity, without changing existing CRUD.
        public void PublishPublicPreview(string id, string summary)
        {
            var current = Security.SessionHelper.Current;
            var actor = current == null ? null : new UserRepository().GetPerson(current.Id);
            if (actor == null || !actor.CanLogin() || actor.MustChangePassword
                || (actor.Role != UserRole.Coordinator && actor.Role != UserRole.CompanySupervisor))
                throw new InvalidOperationException("Only an active opportunity owner or coordinator may publish a summary.");
            var opportunity = ApplicationRepository.IsValidKey(id) ? GetById(id) : null;
            var company = actor as Models.CompanySupervisor;
            if (actor == null || !actor.CanLogin() || opportunity == null
                || (actor.Role != UserRole.Coordinator && (company == null || company.CompanyId != opportunity.CompanyId)))
                throw new InvalidOperationException("Only the opportunity owner or coordinator may publish a summary.");
            string path = "publicOpportunityPreviews/" + id;
            if (!opportunity.IsOpenForApplications) { FirebaseContext.Delete(path); return; }
            summary = (summary ?? "").Trim();
            if (summary.Length < 20 || summary.Length > 280)
                throw new InvalidOperationException("Write a public summary between 20 and 280 characters.");
            FirebaseContext.Put(path, new PublicOpportunityPreview
            {
                Id = id, Title = opportunity.Title, CompanyName = opportunity.CompanyName,
                Location = opportunity.Location, Summary = summary, Status = opportunity.Status,
                RemainingSeats = opportunity.RemainingSeats, ApplicationDeadline = opportunity.ApplicationDeadline,
                PublishedAt = Time.NowMs()
            });
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }

    public class PublicOpportunityPreview
    {
        public string Id { get; set; }
        public string Title { get; set; }
        public string CompanyName { get; set; }
        public string Location { get; set; }
        public string Summary { get; set; }
        public OpportunityStatus Status { get; set; }
        public int RemainingSeats { get; set; }
        public long ApplicationDeadline { get; set; }
        public long PublishedAt { get; set; }
    }
}
