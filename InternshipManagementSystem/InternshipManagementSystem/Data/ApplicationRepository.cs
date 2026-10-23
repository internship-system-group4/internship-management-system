// =============================================================================
//  UIMS - Group 4   |   Owner: Osama  (Trello card O01)
//  Applications and their decisions (cards O01-O05).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class ApplicationRepository : NotifyingRepositoryBase<InternshipApplication>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Applications; }
        }

        protected override void SetId(InternshipApplication entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
