// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F08)
//  OPTIONAL - Zoom meeting records (cards F08-F10).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class MeetingRepository : NotifyingRepositoryBase<Meeting>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Meetings; }
        }

        protected override void SetId(Meeting entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
