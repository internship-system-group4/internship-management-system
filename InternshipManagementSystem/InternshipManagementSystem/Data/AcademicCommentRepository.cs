using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class AcademicCommentRepository : RepositoryBase<AcademicComment>
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

        /// <summary>Saves a comment; a comment visible to the student also notifies them.</summary>
        public override string Insert(AcademicComment entity)
        {
            string id = base.Insert(entity);
            if (!string.IsNullOrEmpty(id)) Services.NotificationService.AcademicCommentAdded(entity);
            return id;
        }
    }
}
