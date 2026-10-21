// =============================================================================
//  UIMS - Group 4   |   Owner: Sara Rajoub  (Trello card R01)
//  Internship opportunities (cards R01-R04).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class OpportunityRepository : RepositoryBase<Opportunity>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Opportunities; }
        }

        protected override void SetId(Opportunity entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
