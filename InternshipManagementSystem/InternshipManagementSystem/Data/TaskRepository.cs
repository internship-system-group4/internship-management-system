// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F01)
//  Tasks assigned to trainees (cards F01, F02).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class TaskRepository : RepositoryBase<InternshipTask>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Tasks; }
        }

        protected override void SetId(InternshipTask entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
