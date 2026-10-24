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
    public class TaskRepository : NotifyingRepositoryBase<InternshipTask>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Tasks; }
        }

        protected override void SetId(InternshipTask entity, string id)
        {
            entity.Id = id;
        }

        /// <summary>A new task tells the student (bilingual, opens the task).
        /// Edits and reassignments keep the email service's notice.</summary>
        protected override bool SendNotice(InternshipTask previous, InternshipTask current)
        {
            if (previous != null) return false;
            Services.NotificationService.TaskAssigned(current);
            return true;
        }

        public List<InternshipTask> GetByPlacement(string placementId)
        {
            return GetWhere("PlacementId", placementId);
        }
        public List<InternshipTask> GetByStudent(string id) { return GetWhere("StudentId", id); }
        public List<InternshipTask> GetByCompany(string id) { return GetWhere("CompanyId", id); }
    }
}

        
    
