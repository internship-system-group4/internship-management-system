// =============================================================================
//  UIMS - Group 4   |   Owner: Sara Dolat  (Trello card D01)
//  Contact Us messages (cards D01-D03).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class ContactRepository : RepositoryBase<ContactMessage>
    {
        protected override string Collection
        {
            get { return Constants.Paths.ContactMessages; }
        }

        protected override void SetId(ContactMessage entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
