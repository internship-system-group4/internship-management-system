// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A10)
//  Completion records and the official report (cards A10-A14).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class CompletionRepository : RepositoryBase<CompletionRecord>
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
            return found.Count > 0 ? found[0] : null;
        }

        public CompletionRecord GetByStudent(string studentId)
        {
            List<CompletionRecord> found = GetWhere("StudentId", studentId);
            return found.Count > 0 ? found[0] : null;
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
        public override string Insert(CompletionRecord entity)
        {
            string id = base.Insert(entity);
            if (!string.IsNullOrEmpty(id)) Services.NotificationService.CompletionDecided(entity);
            return id;
        }

        public override void Save(string id, CompletionRecord entity)
        {
            base.Save(id, entity);
            Services.NotificationService.CompletionDecided(entity);
        }
    }
}
