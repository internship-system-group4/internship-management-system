// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F01)
//  Tasks assigned to trainees (cards F01, F02).
// =============================================================================

using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;
using System.Collections.Generic;
using System.ComponentModel.Design;

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

        public List<InternshipTask> GetByStudent(string studentId)

        {
            return GetWhere("StudentId", studentId);
            
        }
        public List<InternshipTask> GetByCompany(string companyId)
        {
            return GetWhere("CompanyId", companyId);
        }
    }
}

        
    
