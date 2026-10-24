using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class AcademicCommentRepository : NotifyingRepositoryBase<AcademicComment>
    {
        protected override string Collection
        {
            get { return Constants.Paths.AcademicComments; }
        }

        protected override void SetId(AcademicComment entity, string id)
        {
            entity.Id = id;
        }

        public List<AcademicComment> GetByPlacement(string placementId)
        {
            return GetWhere("PlacementId", placementId);
        }

        public List<AcademicComment> GetByStudent(string studentId)
        {
            return GetWhere("StudentId", studentId);
        }

        /// <summary>A new comment that the student may see notifies the student.</summary>
        protected override bool SendNotice(AcademicComment previous, AcademicComment current)
        {
            if (previous != null) return false;
            Services.NotificationService.AcademicCommentAdded(current);
            return true;
        }
    }
}
