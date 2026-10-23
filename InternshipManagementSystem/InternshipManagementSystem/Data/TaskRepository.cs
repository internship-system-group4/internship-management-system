// =============================================================================
//  UIMS - Group 4   |   Owner: Fatima  (Trello card F01)
//  Tasks assigned to trainees (cards F01, F02).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

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

        public List<InternshipTask> GetByPlacement(string placementId)
        {
            return GetWhere("PlacementId", placementId);
        }
    }
}
