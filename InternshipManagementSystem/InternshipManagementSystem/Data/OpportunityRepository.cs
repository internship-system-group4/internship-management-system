// =============================================================================
//  UIMS - Group 4   |   Owner: Sara Rajoub  (Trello card R01)
//  Internship opportunities (cards R01-R04).
// =============================================================================
using System;
using System.Collections.Generic;
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

        // Anonymous browsing reads only the separately published public projection.
        public List<PublicOpportunityPreview> GetPublicPreviews(int count = 3)
        {
            List<PublicOpportunityPreview> previews = new List<PublicOpportunityPreview>();

            var raw = Json.Deserialize<Dictionary<string, PublicOpportunityPreview>>(
                FirebaseContext.Get("publicOpportunityPreviews"));
            if (raw != null)
            {
                foreach (var pair in raw)
                {
                    if (pair.Value != null)
                        pair.Value.Id = pair.Key;
                }
                previews = raw.Values.Where(p => p != null && ApplicationRepository.IsValidKey(p.Id)
                    && p.Status == OpportunityStatus.Open && p.RemainingSeats > 0
                    && (p.ApplicationDeadline <= 0 || !Time.IsPast(p.ApplicationDeadline))
                    && !string.IsNullOrWhiteSpace(p.Title)).ToList();
            }

            return previews
                .Where(p => p != null && !string.IsNullOrWhiteSpace(p.Title))
                .OrderByDescending(p => p.PublishedAt)
                .Take(count)
                .ToList();
        }

        // Explicit publication by a verified owner/coordinator
        public void PublishPublicPreview(string id, string summary)
        {
            var current = Security.SessionHelper.Current;
            var actor = current == null ? null : new UserRepository().GetPerson(current.Id);
            if (actor == null || !actor.CanLogin() || actor.MustChangePassword
                || (actor.Role != UserRole.Coordinator && actor.Role != UserRole.CompanySupervisor))
                throw new InvalidOperationException("Only an active opportunity owner or coordinator may publish a summary.");

            var opportunity = ApplicationRepository.IsValidKey(id) ? GetById(id) : null;
            var company = actor as CompanySupervisor;
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
                Id = id,
                Title = opportunity.Title,
                CompanyName = opportunity.CompanyName,
                Location = opportunity.Location,
                Summary = summary,
                Status = opportunity.Status,
                Specialization = SpecializationText(opportunity),
                RemainingSeats = opportunity.RemainingSeats,
                ApplicationDeadline = opportunity.ApplicationDeadline,
                PublishedAt = Time.NowMs()
            });
        }

        public void SyncPublicPreview(string id)
        {
            try
            {
                var opportunity = ApplicationRepository.IsValidKey(id) ? GetById(id) : null;
                if (opportunity == null) return;
                string summary = (opportunity.Description ?? "").Trim();
                if (summary.Length > 280) summary = summary.Substring(0, 277).TrimEnd() + "...";
                if (summary.Length < 20) summary = (opportunity.Title + " internship at " + opportunity.CompanyName + ".").Trim();
                PublishPublicPreview(id, summary);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceWarning("Public preview sync skipped for " + id + ": " + ex.Message);
            }
        }

        private static string SpecializationText(Opportunity opportunity)
        {
            var majors = (opportunity.EligibleMajors ?? new List<string>()).Where(m => !string.IsNullOrWhiteSpace(m)).ToList();
            string text = majors.Count > 0 ? string.Join(", ", majors) : (opportunity.EligibleCollege ?? "");
            return text.Length > 200 ? text.Substring(0, 200) : text;
        }
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
        public string Specialization { get; set; }
    }
}
