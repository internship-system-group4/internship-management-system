// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A08)
//  Student groups and their academic supervisor (cards A08, A09).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class GroupRepository : RepositoryBase<StudentGroup>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Groups; }
        }

        protected override void SetId(StudentGroup entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
