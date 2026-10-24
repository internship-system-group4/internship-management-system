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

        /// <summary>Creates an empty NotReady record for the placement when none
        /// exists yet, so verification checks have somewhere to live. Uses a
        /// conditional write, so it never replaces a record someone else made.
        /// The key is the placement id (one record per placement).</summary>
        public void EnsureFor(Placement placement)
        {
            if (placement == null || string.IsNullOrEmpty(placement.Id)) return;
            CompletionRecord record = new CompletionRecord
            {
                Id = placement.Id,
                PlacementId = placement.Id,
                StudentId = placement.StudentId
            };
            FirebaseContext.PutIfEmpty(Collection + "/" + placement.Id, record);
        }

        /// <summary>Saves one coordinator verification without touching the
        /// rest of the record (no notification is sent).</summary>
        public void SaveCheck(string completionId, RequirementCheck check)
        {
            if (string.IsNullOrEmpty(completionId) || check == null || string.IsNullOrEmpty(check.Key)) return;
            FirebaseContext.Put(Collection + "/" + completionId + "/Checks/" + check.Key, check);
        }

        /// <summary>Reads the record with its version tag, for a
        /// compare-and-swap decision. Returns null when it does not exist.</summary>
        public CompletionRecord GetVersioned(string id, out string etag)
        {
            string json = FirebaseContext.GetWithEtag(Collection + "/" + id, out etag);
            CompletionRecord record = Json.ConvertTo<CompletionRecord>(Json.Deserialize<object>(json));
            if (record != null) record.Id = id;
            return record;
        }

        /// <summary>Writes the decision only if nobody changed the record since
        /// it was read. Returns false when another decision got there first.
        /// Notifies the student only after a successful write.</summary>
        public bool TrySaveDecision(CompletionRecord record, string etag)
        {
            if (record == null || string.IsNullOrEmpty(record.Id)) return false;
            bool saved = FirebaseContext.PutIfUnchanged(Collection + "/" + record.Id, record, etag);
            if (saved) Services.NotificationService.CompletionDecided(record);
            return saved;
        }

        // When the coordinator approves or returns a completion record, the
        // student is notified. Other statuses send nothing.

    }
}
