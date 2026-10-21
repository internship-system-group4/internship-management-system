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

        public bool Exists(string studentUid)
        {
            return !string.IsNullOrEmpty(studentUid)
                && FirebaseContext.Get(Collection + "/" + studentUid) != null;
        }

        public List<Placement> GetByCompany(string companyId)
        {
            return GetWhere("CompanyId", companyId);
        }

        public List<Placement> GetByAcademicSupervisor(string supervisorId)
        {
            return GetWhere("AcademicSupervisorId", supervisorId);
        }

        // The conditional PUT also protects against simultaneous confirmations.
        public bool Confirm(string studentUid, Placement placement)
        {
            if (string.IsNullOrWhiteSpace(studentUid) || placement == null) return false;
            if (Exists(studentUid)) return false;
            placement.Id = studentUid;
            placement.StudentId = studentUid;
            return FirebaseContext.PutIfEmpty(Collection + "/" + studentUid, placement);
        }

        public override string Insert(Placement entity)
        {
            throw new System.InvalidOperationException("Use Confirm(studentUid, placement) to create a placement.");
        }

        public override void Save(string id, Placement entity)
        {
            throw new System.InvalidOperationException("Use Confirm to create a placement and Update to edit its fields.");
        }
    }
}
