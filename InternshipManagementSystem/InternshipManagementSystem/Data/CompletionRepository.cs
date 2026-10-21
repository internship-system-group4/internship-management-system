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
    }
}
