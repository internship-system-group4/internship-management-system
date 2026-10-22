// =============================================================================
//  UIMS - Group 4   |   Owner: Osama  (Trello card O01)
//  Applications and their decisions (cards O01-O05).
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class ApplicationRepository : RepositoryBase<InternshipApplication>
    {
        protected override string Collection
        {
            get { return Constants.Paths.Applications; }
        }

        protected override void SetId(InternshipApplication entity, string id)
        {
            entity.Id = id;
        }

        public List<InternshipApplication> GetByStudent(string studentId)
        {
            return GetWhere("StudentId", studentId).OrderByDescending(a => a.SubmittedAt).ToList();
        }

        public List<InternshipApplication> GetByCompany(string companyId)
        {
            return GetWhere("CompanyId", companyId).OrderByDescending(a => a.SubmittedAt).ToList();
        }

        public static bool IsValidKey(string key)
        {
            return !string.IsNullOrWhiteSpace(key) && key.Length <= 128
                && !Regex.IsMatch(key, @"[.#$\[\]/\x00-\x20\x7f]");
        }

        public void Decide(CompanySupervisor supervisor, string applicationId,
                           ApplicationStatus decision, string rejectionReason)
        {
            if (supervisor == null || !supervisor.CanLogin() || supervisor.Role != UserRole.CompanySupervisor
                || !IsValidKey(supervisor.Id) || !IsValidKey(supervisor.CompanyId))
                throw new InvalidOperationException("A valid company supervisor account is required.");
            if (!IsValidKey(applicationId)) throw new InvalidOperationException("Choose a valid application.");
            if (decision != ApplicationStatus.Accepted && decision != ApplicationStatus.Rejected)
                throw new InvalidOperationException("Choose Accept or Reject.");
            rejectionReason = (rejectionReason ?? "").Trim();
            if (decision == ApplicationStatus.Rejected && (rejectionReason.Length == 0 || rejectionReason.Length > 2000))
                throw new InvalidOperationException("Enter a rejection reason between 1 and 2,000 characters.");

            string path = Collection + "/" + applicationId;
            string etag;
            string json = FirebaseContext.GetWithEtag(path, out etag);
            var application = Json.Deserialize<InternshipApplication>(json);
            if (application == null || application.CompanyId != supervisor.CompanyId)
                throw new InvalidOperationException("This application is not available to your company.");
            if (!IsValidKey(application.OpportunityId))
                throw new InvalidOperationException("The linked opportunity is unavailable.");
            var opportunity = new OpportunityRepository().GetById(application.OpportunityId);
            if (opportunity == null || opportunity.CompanyId != supervisor.CompanyId)
                throw new InvalidOperationException("The linked opportunity does not belong to your company.");
            if (application.Status != ApplicationStatus.Pending || application.IsConfirmedByStudent)
                throw new InvalidOperationException("This application has already been reviewed. Refresh to see its current status.");

            // Preserve all other fields, including future model extensions.
            var record = Json.ToMap(json);
            record["Status"] = (int)decision;
            record["RejectionReason"] = decision == ApplicationStatus.Rejected ? rejectionReason : null;
            record["DecidedBySupervisorId"] = supervisor.Id;
            record["DecidedAt"] = Time.NowMs();
            if (!FirebaseContext.PutIfUnchanged(path, record, etag))
                throw new InvalidOperationException("This application changed during review. Refresh before making another decision.");

            Services.NotificationService.ApplicationDecided(application, decision);
        }

        public static bool IsSafeDocumentUrl(string value)
        {
            Uri uri;
            return !string.IsNullOrWhiteSpace(value) && value.Length <= 2048
                && Uri.TryCreate(value, UriKind.Absolute, out uri)
                && uri.Scheme == Uri.UriSchemeHttps && !string.IsNullOrEmpty(uri.Host)
                && string.IsNullOrEmpty(uri.UserInfo);
        }

        // Server-owned identifiers and status never come from posted form fields.
        public InternshipApplication Submit(Student student, string opportunityId,
                                             string coverLetter, string cvUrl, bool confirmed)
        {
            if (student == null || !IsValidKey(student.Id) || !student.CanLogin())
                throw new InvalidOperationException("Please sign in with an active student account.");
            if (!IsValidKey(opportunityId))
                throw new InvalidOperationException("Choose an internship from Explore Opportunities first.");
            coverLetter = (coverLetter ?? "").Trim();
            cvUrl = (cvUrl ?? "").Trim();
            if (coverLetter.Length < 50 || coverLetter.Length > 4000)
                throw new InvalidOperationException("Write a cover letter between 50 and 4,000 characters.");
            if (!IsSafeDocumentUrl(cvUrl))
                throw new InvalidOperationException("Enter a valid HTTPS link to your CV (up to 2,048 characters).");
            if (!confirmed)
                throw new InvalidOperationException("Confirm that your information is accurate before submitting.");

            Opportunity opportunity = new OpportunityRepository().GetById(opportunityId);
            if (opportunity == null || !opportunity.IsOpenForApplications)
                throw new InvalidOperationException("This internship is no longer accepting applications.");
            if (!opportunity.IsEligible(student))
                throw new InvalidOperationException("This internship is not available for your college or major.");
            if (!IsValidKey(opportunity.CompanyId))
                throw new InvalidOperationException("This opportunity has no valid company. Please contact the coordinator.");
            if (new PlacementRepository().Exists(student.Id))
                throw new InvalidOperationException("You already have a confirmed internship.");
            if (GetByStudent(student.Id).Any(a => a.OpportunityId == opportunityId))
                throw new InvalidOperationException("You have already applied to this internship. Check My Applications.");

            string id;
            using (SHA256 hash = SHA256.Create())
            {
                id = BitConverter.ToString(hash.ComputeHash(Encoding.UTF8.GetBytes(
                    student.Id + "\n" + opportunityId))).Replace("-", "").ToLowerInvariant();
            }
            var application = new InternshipApplication
            {
                Id = id, StudentId = student.Id, StudentName = student.FullName,
                StudentMajor = student.Major, OpportunityId = opportunityId,
                OpportunityTitle = opportunity.Title, CompanyId = opportunity.CompanyId,
                CompanyName = opportunity.CompanyName, CoverLetter = coverLetter,
                CvUrl = cvUrl, Status = ApplicationStatus.Pending, SubmittedAt = Time.NowMs()
            };
            // Conditional write prevents concurrent tabs and retries from overwriting a decision.
            if (!FirebaseContext.PutIfEmpty(Collection + "/" + id, application))
                throw new InvalidOperationException("You have already applied to this internship. Check My Applications.");

            Services.NotificationService.ApplicationSubmitted(application);
            return application;
        }
    }
}
