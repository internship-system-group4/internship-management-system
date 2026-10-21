// =============================================================================
//  UIMS - Group 4   |   Owner: Osama  (Trello card O03)
//  Placements - and the one-internship rule.
// =============================================================================

using System;
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

        public OfferConfirmationResult ConfirmAcceptedOffer(Student student, string applicationId)
        {
            if (student == null || !student.CanLogin() || student.Role != UserRole.Student
                || !ApplicationRepository.IsValidKey(student.Id))
                throw new InvalidOperationException("Sign in with an active student account.");
            if (!ApplicationRepository.IsValidKey(applicationId))
                throw new InvalidOperationException("Choose a valid accepted offer.");
            var existing = GetById(student.Id);
            if (existing != null && existing.ApplicationId != applicationId)
                throw new InvalidOperationException("You already confirmed an internship. You cannot confirm another offer.");

            var applications = new ApplicationRepository();
            var application = applications.GetById(applicationId);
            if (application == null || application.StudentId != student.Id)
                throw new InvalidOperationException("This application does not belong to you.");
            if (application.Status != ApplicationStatus.Accepted)
                throw new InvalidOperationException("Only an accepted offer can be confirmed.");
            if (!ApplicationRepository.IsValidKey(application.OpportunityId))
                throw new InvalidOperationException("The linked opportunity is unavailable.");
            var opportunity = new OpportunityRepository().GetById(application.OpportunityId);
            if (opportunity == null || opportunity.CompanyId != application.CompanyId)
                throw new InvalidOperationException("The linked opportunity is unavailable. Contact the coordinator.");
            string supervisorId = string.IsNullOrWhiteSpace(application.DecidedBySupervisorId)
                ? opportunity.CreatedBySupervisorId : application.DecidedBySupervisorId;
            var supervisor = ApplicationRepository.IsValidKey(supervisorId)
                ? new UserRepository().GetPerson(supervisorId) as CompanySupervisor : null;
            if (supervisor == null || supervisor.CompanyId != application.CompanyId)
                throw new InvalidOperationException("The company supervisor is unavailable. Contact the coordinator.");

            var placement = existing ?? new Placement
            {
                Id = student.Id, StudentId = student.Id, StudentName = student.FullName,
                ApplicationId = applicationId, OpportunityId = opportunity.Id,
                OpportunityTitle = opportunity.Title, CompanyId = opportunity.CompanyId,
                CompanyName = opportunity.CompanyName, CompanySupervisorId = supervisor.Id,
                CompanySupervisorName = supervisor.FullName, AcademicSupervisorId = student.AcademicSupervisorId,
                RequiredHours = student.RequiredHours, ApprovedHours = 0,
                StartDate = opportunity.StartDate,
                EndDate = opportunity.StartDate > 0 && opportunity.DurationWeeks > 0
                    ? opportunity.StartDate + (long)opportunity.DurationWeeks * 7 * 24 * 60 * 60 * 1000 : 0,
                Status = PlacementStatus.Confirmed, ConfirmedAt = Time.NowMs()
            };
            if (existing == null && !Confirm(student.Id, placement))
            {
                // A competing confirmation may have won after the first read.
                placement = GetById(student.Id);
                if (placement == null || placement.ApplicationId != applicationId)
                    throw new InvalidOperationException("Another internship was confirmed. Refresh to see your placement.");
            }
            bool syncPending = false;
            try
            {
                applications.Update(applicationId, new Dictionary<string, object> { { "IsConfirmedByStudent", true } });
            }
            catch (FirebaseException)
            {
                // The placement is the durable source of truth. A retry repairs the display flag.
                syncPending = true;
            }
            return new OfferConfirmationResult { Placement = placement, ApplicationSyncPending = syncPending };
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

    public class OfferConfirmationResult
    {
        public Placement Placement { get; set; }
        public bool ApplicationSyncPending { get; set; }
    }
}
