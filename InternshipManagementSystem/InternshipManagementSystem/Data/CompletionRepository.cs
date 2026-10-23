// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A10)
//  Completion records and the official report (cards A10-A14).
// =============================================================================

using System.Collections.Generic;
using System;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class CompletionRepository : NotifyingRepositoryBase<CompletionRecord>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Completions; }
        }

        protected override void SetId(CompletionRecord entity, string id)
        {
            entity.Id = id;
        }

        public CompletionRecord GetByPlacement(string placementId)
        {
            List<CompletionRecord> found = GetWhere("PlacementId", placementId);
            return found.OrderByDescending(r => r.Status == CompletionStatus.Approved)
                .ThenByDescending(r => r.ReviewedAt).FirstOrDefault();
        }

        public CompletionRecord GetByStudent(string studentId)
        {
            List<CompletionRecord> found = GetWhere("StudentId", studentId);
            return found.OrderByDescending(r => r.Status == CompletionStatus.Approved)
                .ThenByDescending(r => r.ReviewedAt).FirstOrDefault();
        }

        public CompletionRecord ReadForReview(string placementId, out string etag)
        {
            var existing = GetWhere("PlacementId", placementId);
            if (existing.Count > 1)
                throw new InvalidOperationException("Multiple completion records exist. Reconcile them before reviewing this placement.");
            string key = existing.Count == 1 ? existing[0].Id : placementId;
            var record = Json.Deserialize<CompletionRecord>(FirebaseContext.GetVersioned(Collection + "/" + key, out etag));
            if (record != null && record.PlacementId != placementId)
                throw new InvalidOperationException("Completion record does not match this placement.");
            if (record != null) record.Id = key;
            return record;
        }

        public bool SaveReview(CompletionRecord record, string etag, Person actor)
        {
            Services.CompletionReviewService.RequireCoordinator(actor);
            if (record == null || string.IsNullOrEmpty(record.PlacementId)) throw new InvalidOperationException("Placement is required.");
            if (string.IsNullOrEmpty(record.Id)) record.Id = record.PlacementId;
            string currentVersion;
            var previous = Json.Deserialize<CompletionRecord>(FirebaseContext.GetVersioned(Collection + "/" + record.Id, out currentVersion));
            if (currentVersion != etag) return false;
            if (Services.CompletionReviewService.IsFinal(previous))
                throw new InvalidOperationException("This review has a final decision and is read-only.");
            if (previous != null && (previous.PlacementId != record.PlacementId || previous.StudentId != record.StudentId))
                throw new InvalidOperationException("Completion identity cannot be changed.");
            if (!FirebaseContext.PutIfVersion(Collection + "/" + record.Id, record, etag)) return false;
            Services.EmailNotificationService.Saved(previous, record);
            return true;
        }
    }
}
