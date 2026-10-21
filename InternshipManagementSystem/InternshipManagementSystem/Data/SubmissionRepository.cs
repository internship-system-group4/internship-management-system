// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F04)
//  Submission attempts, append-only (cards F04, F06, F07).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class SubmissionRepository : RepositoryBase<Submission>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Submissions; }
        }

        protected override void SetId(Submission entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
