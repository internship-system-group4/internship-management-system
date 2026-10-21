// =============================================================================
//  UIMS - Group 4   |   Owner: Osama  (Trello card O03)
//  Placements - and the one-internship rule.
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class PlacementRepository : RepositoryBase<Placement>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Placements; }
        }

        protected override void SetId(Placement entity, string id)
        {
            entity.Id = id;
        }

        public List<Placement> GetByStudent(string studentId)
        {
            return GetWhere("StudentId", studentId);
        }

        public List<Placement> GetByCompany(string companyId)
        {
            return GetWhere("CompanyId", companyId);
        }

        public List<Placement> GetByAcademicSupervisor(string supervisorId)
        {
            return GetWhere("AcademicSupervisorId", supervisorId);
        }

        /// <summary>
        /// Card O03: a student may confirm one offer and no more.
        ///
        /// The check and the write are separate HTTP calls, so two fast clicks
        /// could both pass the check. Re-reading the student immediately before
        /// writing and refusing when ConfirmedPlacementId is already set closes
        /// almost all of that window. To close it completely, add a Firebase
        /// security rule that makes users/{uid}/ConfirmedPlacementId writable
        /// only while its current value is null:
        ///
        ///   ".validate": "!data.exists() || data.val() === newData.val()"
        ///
        /// A rule is the only guarantee here, because it runs on Google's side.
        /// </summary>
        public bool TryConfirm(string studentId, Placement placement)
        {
            if (string.IsNullOrEmpty(studentId) || placement == null) return false;

            UserRepository users = new UserRepository();
            Student student = users.GetStudent(studentId);
            if (student == null) return false;
            if (student.HasConfirmedPlacement) return false;

            string placementId = Insert(placement);
            if (string.IsNullOrEmpty(placementId)) return false;

            users.Update(studentId, new Dictionary<string, object>
            {
                { "ConfirmedPlacementId", placementId }
            });
            return true;
        }
    }
}
