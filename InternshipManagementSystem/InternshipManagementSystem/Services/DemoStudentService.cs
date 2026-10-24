// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Demo student for presentations and testing (Pages/Coordinator/DemoStudent.aspx).
//
//  Creates ONE fictional student with a complete local internship that is
//  ready for the coordinator's final completion review: placement, accepted
//  application, graded tasks on different scales (one with a revision),
//  160 approved hours, both final evaluations submitted, and most manual
//  checks already verified. The coordinator then verifies the last checks,
//  approves, and prints the report and certificate.
//
//  Safety rules:
//   - Additive only. Every record it writes uses a "demo-" key or the new
//     student's own UID; it never edits or deletes anything else.
//   - It reuses the existing company and academic supervisor accounts and
//     never changes them.
//   - Records are written directly (no notifications), so supervisors' inboxes
//     are not flooded with demo messages.
//   - Reset only rewrites the demo student's completion record and placement
//     status, so the approval can be shown again.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    public class DemoStudentInfo
    {
        // Properties (not fields) so the page's data binding can read them.
        public string StudentId { get; set; }
        public string FullName { get; set; }
        public string Email { get; set; }
        public string CompanyName { get; set; }
        public string CompanySupervisorName { get; set; }
        public string AcademicSupervisorName { get; set; }
        public CompletionStatus Status { get; set; }
    }

    public static class DemoStudentService
    {
        private const string ApplicationPrefix = "demo-app-";
        private const long Day = 24L * 60 * 60 * 1000;

        /// <summary>Demo students created earlier (found by their demo application key).</summary>
        public static List<DemoStudentInfo> List()
        {
            List<DemoStudentInfo> result = new List<DemoStudentInfo>();
            Dictionary<string, object> apps = Json.ToMap(FirebaseContext.Get(Constants.Paths.Applications));
            UserRepository users = new UserRepository();
            CompletionRepository completions = new CompletionRepository();
            foreach (string key in apps.Keys.Where(k => k.StartsWith(ApplicationPrefix, StringComparison.Ordinal)))
            {
                string uid = key.Substring(ApplicationPrefix.Length);
                Student student = users.GetStudent(uid);
                Placement placement = new PlacementRepository().GetById(uid);
                if (student == null || placement == null) continue;
                CompletionRecord record = completions.GetById(uid);
                result.Add(new DemoStudentInfo
                {
                    StudentId = uid, FullName = student.FullName, Email = student.Email,
                    CompanyName = placement.CompanyName, CompanySupervisorName = placement.CompanySupervisorName,
                    AcademicSupervisorName = Name(users, placement.AcademicSupervisorId),
                    Status = record == null ? CompletionStatus.NotReady : record.Status
                });
            }
            return result;
        }

        /// <summary>Creates the Auth account and every record. Returns the new UID.</summary>
        public static string Create(string fullName, string email, string password, Coordinator coordinator)
        {
            fullName = Validators.Clean(fullName);
            email = (email ?? "").Trim();
            if (fullName == null || fullName.Length > 120) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorName"));
            if (!Validators.IsEmail(email)) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorEmail"));
            if (!Validators.IsStrongEnoughPassword(password)) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorPassword"));

            UserRepository users = new UserRepository();
            List<Person> people = users.GetAllPeople();
            CompanySupervisor company = people.OfType<CompanySupervisor>()
                .Where(p => p.IsActive && !string.IsNullOrEmpty(p.CompanyId))
                .OrderByDescending(p => string.Equals(p.Email, "company.supervisor@example.com", StringComparison.OrdinalIgnoreCase))
                .FirstOrDefault();
            AcademicSupervisor academic = people.OfType<AcademicSupervisor>()
                .Where(p => p.IsActive)
                .OrderByDescending(p => string.Equals(p.Email, "academic.supervisor@example.com", StringComparison.OrdinalIgnoreCase))
                .FirstOrDefault();
            if (company == null || academic == null) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorSupervisors"));

            AuthResult account = AuthService.CreateAccount(email, password);
            if (!account.Success || string.IsNullOrEmpty(account.Uid))
                throw new InvalidOperationException(account.ErrorMessage ?? L.T("Coordinator.Demo.ErrorAccount"));
            string uid = account.Uid;

            try
            {
                Seed(uid, fullName, email, company, academic, coordinator);
            }
            catch
            {
                // Without a profile the account is useless; remove it so the email can be reused.
                if (!string.IsNullOrEmpty(account.IdToken)) AuthService.DeleteAccount(account.IdToken);
                throw;
            }
            return uid;
        }

        /// <summary>Puts a demo internship back to "ready for review" so the
        /// approval can be shown again. Only demo students can be reset.</summary>
        public static void Reset(string uid, Coordinator coordinator)
        {
            if (!IsDemo(uid)) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorNotDemo"));
            Placement placement = new PlacementRepository().GetById(uid);
            if (placement == null) throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorNotDemo"));
            FirebaseContext.Put(Constants.Paths.Completions + "/" + uid, StartingCompletion(uid, coordinator));
            new PlacementRepository().Update(uid, new Dictionary<string, object> { { "Status", (int)PlacementStatus.AwaitingCompletion } });
        }

        public static bool IsDemo(string uid)
        {
            return ApplicationRepository.IsValidKey(uid)
                && FirebaseContext.Get(Constants.Paths.Applications + "/" + ApplicationPrefix + uid) != null;
        }

        // ---- the records ------------------------------------------------------------
        private static void Seed(string uid, string fullName, string email, CompanySupervisor sup,
            AcademicSupervisor academic, Coordinator coordinator)
        {
            long now = Time.NowMs();
            long start = Midnight(now - 35 * Day), end = Midnight(now - 7 * Day);
            Company company = new CompanyRepository().GetById(sup.CompanyId);
            string companyName = company != null && !string.IsNullOrWhiteSpace(company.Name) ? company.Name
                : (string.IsNullOrWhiteSpace(sup.CompanyName) ? "Demo Software Company" : sup.CompanyName);
            const string major = "Computer Science";
            const string title = "Junior Software Developer Intern";

            // Student profile (the coordinator may write any profile).
            Student student = new Student
            {
                Id = uid, FullName = fullName, Email = email, StudentNumber = "DEMO-CS-" + uid.Substring(0, 6).ToUpperInvariant(),
                University = Constants.UniversityName, College = Constants.CollegeName, Major = major,
                RequiredHours = Constants.DefaultRequiredHours, ApprovedHours = 160,
                AcademicSupervisorId = academic.Id, MustChangePassword = false, IsActive = true
            };
            new UserRepository().SavePerson(student);

            // Opportunity (closed, so it never appears to other students) and the accepted application.
            string opportunityId = "demo-opp-" + uid;
            FirebaseContext.Put(Constants.Paths.Opportunities + "/" + opportunityId, new Opportunity
            {
                Id = opportunityId, CompanyId = sup.CompanyId, CompanyName = companyName, CreatedBySupervisorId = sup.Id,
                Title = title, Location = "Amman, Jordan", EligibleCollege = Constants.CollegeName,
                EligibleMajors = new List<string> { major }, TotalSeats = 1, FilledSeats = 1, DurationWeeks = 4,
                Description = "Demo internship used to show the UIMS completion workflow.",
                Requirements = "Programming fundamentals, Git, SQL.",
                StartDate = start, ApplicationDeadline = start - 14 * Day, Status = OpportunityStatus.Closed, CreatedAt = start - 30 * Day
            });
            string applicationId = ApplicationPrefix + uid;
            FirebaseContext.Put(Constants.Paths.Applications + "/" + applicationId, new InternshipApplication
            {
                Id = applicationId, StudentId = uid, StudentName = fullName, StudentMajor = major,
                OpportunityId = opportunityId, OpportunityTitle = title, CompanyId = sup.CompanyId, CompanyName = companyName,
                CoverLetter = "Demo application.", Status = ApplicationStatus.Accepted, DecidedBySupervisorId = sup.Id,
                DecidedAt = start - 10 * Day, IsConfirmedByStudent = true, SubmittedAt = start - 20 * Day
            });

            // Placement through the shared contract (placements/{studentUid}).
            Placement placement = new Placement
            {
                StudentName = fullName, ApplicationId = applicationId, OpportunityId = opportunityId, OpportunityTitle = title,
                CompanyId = sup.CompanyId, CompanyName = companyName, CompanySupervisorId = sup.Id, CompanySupervisorName = sup.FullName,
                AcademicSupervisorId = academic.Id, StartDate = start, EndDate = end, RequiredHours = Constants.DefaultRequiredHours,
                ApprovedHours = 160, Status = PlacementStatus.AwaitingCompletion, ConfirmedAt = start - 8 * Day,
                InternshipType = InternshipTypes.Local
            };
            if (!new PlacementRepository().Confirm(uid, placement))
                throw new InvalidOperationException(L.T("Coordinator.Demo.ErrorAccount"));

            // Graded tasks on different scales; task 2 needed one revision.
            AddTask(uid, sup, 1, "Set up the development environment and repository", 10, 1, start + 3 * Day,
                new[] { Part("Environment ready", 6, 50, 5.5), Part("Repository and README", 4, 50, 3.5) }, 9,
                "Clean setup and a clear README. Well done.", null, null);
            AddTask(uid, sup, 2, "Build the user login REST API", 20, 2, start + 10 * Day,
                new[] { Part("Correctness", 10, 50, 9), Part("Validation and errors", 6, 30, 5), Part("Code quality", 4, 20, 3) }, 17,
                "Much better: validation and error codes are now consistent.",
                "Add input validation and return proper HTTP error codes (400/401).", "Good structure, but invalid input crashes the endpoint.");
            AddTask(uid, sup, 3, "Design the reporting database schema", 100, 3, start + 17 * Day,
                new[] { Part("Normalisation", 40, 40, 34), Part("Indexes and keys", 30, 30, 26), Part("Documentation", 30, 30, 26) }, 86,
                "Solid, well-normalised design. Document the archive tables next time.", null, null);
            AddTask(uid, sup, 4, "Write unit tests for the payment module", 25, 2, start + 22 * Day,
                new[] { Part("Coverage", 15, 60, 13), Part("Test readability", 10, 40, 8) }, 21,
                "Good coverage of edge cases.", null, null);
            AddTask(uid, sup, 5, "Final presentation of the internship project", 50, 2, start + 27 * Day,
                new[] { Part("Content", 30, 60, 27), Part("Delivery", 20, 40, 17) }, 44,
                "Clear, confident presentation to the team.", null, null);

            // 4 weeks x 40 h, each approved by the company supervisor.
            string[] weeks = { "Week 1: onboarding, environment and first tickets", "Week 2: login API and code review",
                               "Week 3: database schema and reporting queries", "Week 4: unit tests and final presentation" };
            for (int w = 0; w < 4; w++)
            {
                string id = "demo-" + uid + "-hours-" + (w + 1);
                long workDate = start + (w * 7 + 4) * Day;
                FirebaseContext.Put(Constants.Paths.TrainingHours + "/" + id, new TrainingHoursEntry
                {
                    Id = id, PlacementId = uid, StudentId = uid, Hours = 40, WorkDate = workDate, Description = weeks[w],
                    Status = HoursStatus.Approved, ReviewedById = sup.Id, ReviewNote = "Confirmed with the attendance sheet.",
                    ReviewedAt = workDate + 2 * Day, ReportedAt = workDate + Day
                });
            }

            // Both confidential final evaluations, submitted.
            List<GradeComponent> criteria = GradingPolicy.CompanyFinalCriteria();
            double[] ratings = { 4, 4, 5, 4, 5, 4 };
            for (int i = 0; i < criteria.Count && i < ratings.Length; i++) criteria[i].Score = ratings[i];
            FirebaseContext.Put(Constants.Paths.CompanyEvaluations + "/demo-cfe-" + uid, new FinalCompanyEvaluation
            {
                Id = "demo-cfe-" + uid, PlacementId = uid, StudentId = uid, CompanyId = sup.CompanyId, SupervisorId = sup.Id,
                Components = criteria, TotalScore = Math.Round(GradingService.PercentOf(criteria), 2), MaxScore = GradingPolicy.CompanyEvaluationMaxScore,
                Strengths = "Learns quickly, writes clean code and communicates progress clearly.",
                AreasForImprovement = "Estimate tasks more carefully and ask for reviews earlier.",
                OverallComment = "A reliable trainee who would be welcome back.",
                ReportedTotalHours = 160, IsSubmitted = true, SubmittedAt = end + Day, CreatedAt = end
            });
            FirebaseContext.Put(Constants.Paths.AcademicEvaluations + "/demo-afe-" + uid, new FinalAcademicEvaluation
            {
                Id = "demo-afe-" + uid, PlacementId = uid, StudentId = uid, AcademicSupervisorId = academic.Id,
                Components = new List<GradeComponent> { Part("Training report", 30, 60, 26), Part("Final presentation", 20, 40, 17) },
                TotalScore = 43, MaxScore = GradingPolicy.AcademicEvaluationMaxScore,
                AcademicComments = "Well-structured report that links the tasks to the study plan.",
                CompanyEvaluationRemarks = "Consistent with my site visit and the weekly reports.",
                IsSubmitted = true, SubmittedAt = end + 3 * Day, CreatedAt = end + 2 * Day
            });

            // Completion record waiting for the coordinator.
            FirebaseContext.Put(Constants.Paths.Completions + "/" + uid, StartingCompletion(uid, coordinator));
        }

        /// <summary>Under review, six of eight local checks verified; the training
        /// report and the dean endorsement are left for the coordinator.</summary>
        private static CompletionRecord StartingCompletion(string uid, Coordinator coordinator)
        {
            long now = Time.NowMs();
            Dictionary<string, RequirementCheck> checks = new Dictionary<string, RequirementCheck>();
            string[,] verified =
            {
                { "prior-approval", "Department approval email from the CS chair, dated before the start date" },
                { "prerequisites", "Transcript checked: 96 completed credit hours" },
                { "major-relevance", "Software development role, matches Computer Science" },
                { "schedule", "4 weeks x 40 h during the summer break, not a registered semester" },
                { "company-eligibility", "Single company; no family relation declared" },
                { "training-forms", "Local Training Form signed and stamped by the company supervisor, with task list" }
            };
            for (int i = 0; i < verified.GetLength(0); i++)
            {
                checks[verified[i, 0]] = new RequirementCheck
                {
                    Key = verified[i, 0], Status = RequirementCheck.Verified, Evidence = verified[i, 1],
                    CoordinatorId = coordinator == null ? null : coordinator.Id, CheckedAt = now - Day
                };
            }
            return new CompletionRecord
            {
                Id = uid, PlacementId = uid, StudentId = uid, Status = CompletionStatus.UnderCoordinatorReview,
                CompanyEvaluationId = "demo-cfe-" + uid, AcademicEvaluationId = "demo-afe-" + uid,
                Checks = checks, CreatedAt = now
            };
        }

        private static void AddTask(string uid, CompanySupervisor sup, int n, string title, double max, double weight, long deadline,
            GradeComponent[] criteria, double score, string feedback, string revision, string revisionFeedback)
        {
            string taskId = "demo-" + uid + "-task-" + n;
            FirebaseContext.Put(Constants.Paths.Tasks + "/" + taskId, new InternshipTask
            {
                Id = taskId, PlacementId = uid, StudentId = uid, CompanyId = sup.CompanyId, CreatedBySupervisorId = sup.Id,
                Title = title, Description = title + ".", Deadline = deadline, MaxScore = max, Weight = weight, EstimatedHours = 8,
                Criteria = criteria.Select(c => Part(c.Name, c.MaxScore, c.Weight, 0)).ToList(),
                Status = InternshipTaskStatus.Graded, CreatedAt = deadline - 6 * Day
            });

            int attempt = 1;
            if (revision != null)
            {
                string firstId = taskId + "-sub-1";
                FirebaseContext.Put(Constants.Paths.Submissions + "/" + firstId, Submission(firstId, taskId, uid, 1, deadline - 2 * Day));
                FirebaseContext.Put(Constants.Paths.TaskEvaluations + "/" + taskId + "-eval-1", new TaskEvaluation
                {
                    Id = taskId + "-eval-1", TaskId = taskId, SubmissionId = firstId, PlacementId = uid, StudentId = uid,
                    EvaluatedBySupervisorId = sup.Id, MaxScore = max, RevisionRequested = true, RevisionInstructions = revision,
                    Feedback = revisionFeedback, EvaluatedAt = deadline - Day
                });
                attempt = 2;
            }
            string subId = taskId + "-sub-" + attempt;
            FirebaseContext.Put(Constants.Paths.Submissions + "/" + subId, Submission(subId, taskId, uid, attempt, deadline));
            FirebaseContext.Put(Constants.Paths.TaskEvaluations + "/" + taskId + "-eval-" + attempt, new TaskEvaluation
            {
                Id = taskId + "-eval-" + attempt, TaskId = taskId, SubmissionId = subId, PlacementId = uid, StudentId = uid,
                EvaluatedBySupervisorId = sup.Id, Components = criteria.ToList(), TotalScore = score, MaxScore = max,
                Feedback = feedback, EvaluatedAt = deadline + Day
            });
        }

        private static Submission Submission(string id, string taskId, string uid, int attempt, long at)
        {
            return new Submission
            {
                Id = id, TaskId = taskId, PlacementId = uid, StudentId = uid, AttemptNumber = attempt,
                DescriptionText = "Attempt " + attempt + ": work submitted for review.", ReportedHours = 0,
                Status = SubmissionStatus.Accepted, SubmittedAt = at
            };
        }

        private static GradeComponent Part(string name, double max, double weight, double score)
        {
            return new GradeComponent { Name = name, MaxScore = max, Weight = weight, Score = score };
        }

        private static long Midnight(long ms)
        {
            DateTime local = Time.FromUnixMs(ms).ToLocalTime().Date;
            return Time.ToUnixMs(local);
        }

        private static string Name(UserRepository users, string id)
        {
            if (!ApplicationRepository.IsValidKey(id)) return "—";
            Person person = users.GetPerson(id);
            return person == null ? "—" : person.FullName;
        }
    }
}
