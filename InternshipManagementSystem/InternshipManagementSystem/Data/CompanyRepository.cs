// =============================================================================
//  UIMS - Group 4   |   Owner: Nada  (Trello card N03)
//  Companies (card N03).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class CompanyRepository : RepositoryBase<Company>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Companies; }
        }

        protected override void SetId(Company entity, string id)
        {
            entity.Id = id;
        }

        // Add the queries your pages need here, as named methods.
        // Keep raw field names out of the pages: if the field is ever
        // renamed, this file is the only one that has to change.
    }
}
