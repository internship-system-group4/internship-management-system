// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  Task evaluations and the two confidential final evaluations.
// =============================================================================

using System.Collections.Generic;
using System.Linq;
using System;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    /// <summary>
    /// Three collections live behind one repository because they are always
    /// read together on the coordinator's Final Completion Review page.
    ///
    /// Confidentiality is a requirement, not a UI preference: the student may
    /// see TaskEvaluation records, and must never see the two final evaluation
    /// forms. The methods below are named so that a page cannot reach for the
    /// confidential ones by accident.
    /// </summary>
    public class EvaluationRepository
    {
        // ---- per-task evaluations: visible to the student -----------------
        public List<TaskEvaluation> GetTaskEvaluationsForStudent(string studentId)
        {
            return Deserialise<TaskEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.TaskEvaluations, "StudentId", studentId));
        }

        public List<TaskEvaluation> GetTaskEvaluationsForPlacement(string placementId)
        {
            return Deserialise<TaskEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.TaskEvaluations, "PlacementId", placementId));
        }

        public string SaveTaskEvaluation(TaskEvaluation evaluation)
        {
            var actor = SessionHelper.Current;
            var placement = evaluation == null ? null : new PlacementRepository().GetById(evaluation.PlacementId);
            if (actor == null || !actor.IsActive || actor.Role != UserRole.CompanySupervisor || placement == null ||
                placement.CompanySupervisorId != actor.Id || ((CompanySupervisor)actor).CompanyId != placement.CompanyId ||
                evaluation.EvaluatedBySupervisorId != actor.Id || evaluation.StudentId != placement.StudentId)
                throw new UnauthorizedAccessException("Only the assigned company supervisor may evaluate tasks.");
            var task = new TaskRepository().GetById(evaluation.TaskId);
            var submission = new SubmissionRepository().GetById(evaluation.SubmissionId);
            if (task == null || submission == null || task.PlacementId != placement.Id || task.StudentId != placement.StudentId ||
                submission.PlacementId != placement.Id || submission.StudentId != placement.StudentId || submission.TaskId != task.Id ||
                !evaluation.RevisionRequested && !Services.CompletionReviewService.ValidScore(evaluation.TotalScore, evaluation.MaxScore))
                throw new InvalidOperationException("The task evaluation must reference matching submitted work and a valid score or revision request.");
            if (Services.CompletionReviewService.IsFinal(new CompletionRepository().GetByPlacement(placement.Id)))
                throw new InvalidOperationException("Completion is finalized; task evidence is read-only.");
            string id = PushWithId(Constants.Paths.TaskEvaluations, evaluation);
            if (!string.IsNullOrEmpty(id)) Services.EmailNotificationService.Saved(null, evaluation);
            return id;
        }

        // ---- final company evaluation: CONFIDENTIAL ----------------------
        public FinalCompanyEvaluation GetCompanyFinalForPlacement(string placementId)
        {
            AuthorizeFinalRead(placementId, false);
            List<FinalCompanyEvaluation> found = Deserialise<FinalCompanyEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.CompanyEvaluations, "PlacementId", placementId));
            return found.OrderByDescending(e => e.IsSubmitted)
                .ThenByDescending(e => e.SubmittedAt).ThenByDescending(e => e.CreatedAt)
                .FirstOrDefault();
        }

        public string SaveCompanyFinal(FinalCompanyEvaluation evaluation)
        {
            var placement = AuthorizeFinalWrite(evaluation.PlacementId, false);
            if (evaluation.StudentId != placement.StudentId || evaluation.CompanyId != placement.CompanyId || evaluation.SupervisorId != SessionHelper.Current.Id)
                throw new UnauthorizedAccessException("Company evaluation identity does not match this placement.");
            var existing = GetCompanyFinalForPlacement(placement.Id);
            string key = existing == null ? placement.Id : existing.Id;
            if (!string.IsNullOrEmpty(evaluation.Id) && evaluation.Id != key)
                throw new InvalidOperationException("The evaluation changed; reload before submitting.");
            string etag;
            var previous = Json.Deserialize<FinalCompanyEvaluation>(FirebaseContext.GetVersioned(Constants.Paths.CompanyEvaluations + "/" + key, out etag));
            if (previous != null && (previous.PlacementId != placement.Id || previous.StudentId != placement.StudentId || previous.SupervisorId != SessionHelper.Current.Id || previous.IsSubmitted))
                throw new InvalidOperationException("This evaluation is submitted or belongs to another placement.");
            evaluation.Id = key;
            if (!FirebaseContext.PutIfVersion(Constants.Paths.CompanyEvaluations + "/" + key, evaluation, etag))
                throw new InvalidOperationException("Another request submitted this evaluation. Reload before retrying.");
            Services.EmailNotificationService.Saved(previous, evaluation);
            return key;
        }
        // ---- final academic evaluation: CONFIDENTIAL --------------------
        public FinalAcademicEvaluation GetAcademicFinalForPlacement(string placementId)
        {
            AuthorizeFinalRead(placementId, true);
            List<FinalAcademicEvaluation> found = Deserialise<FinalAcademicEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.AcademicEvaluations, "PlacementId", placementId));
            return found.OrderByDescending(e => e.IsSubmitted)
                .ThenByDescending(e => e.SubmittedAt).ThenByDescending(e => e.CreatedAt)
                .FirstOrDefault();
        }

        public string SaveAcademicFinal(FinalAcademicEvaluation evaluation)
        {
            var placement = AuthorizeFinalWrite(evaluation.PlacementId, true);
            if (evaluation.StudentId != placement.StudentId || evaluation.AcademicSupervisorId != SessionHelper.Current.Id)
                throw new UnauthorizedAccessException("Academic evaluation identity does not match this placement.");
            var company = GetCompanyFinalForPlacement(placement.Id);
            if (evaluation.IsSubmitted && (company == null || !company.IsSubmitted || company.SupervisorId != placement.CompanySupervisorId))
                throw new InvalidOperationException("Review the submitted company final evaluation first.");
            var existing = GetAcademicFinalForPlacement(placement.Id);
            string key = existing == null ? placement.Id : existing.Id;
            if (!string.IsNullOrEmpty(evaluation.Id) && evaluation.Id != key)
                throw new InvalidOperationException("The evaluation changed; reload before submitting.");
            string etag;
            var previous = Json.Deserialize<FinalAcademicEvaluation>(FirebaseContext.GetVersioned(Constants.Paths.AcademicEvaluations + "/" + key, out etag));
            if (previous != null && (previous.PlacementId != placement.Id || previous.StudentId != placement.StudentId || previous.AcademicSupervisorId != SessionHelper.Current.Id || previous.IsSubmitted))
                throw new InvalidOperationException("This evaluation is submitted or belongs to another placement.");
            evaluation.Id = key;
            if (!FirebaseContext.PutIfVersion(Constants.Paths.AcademicEvaluations + "/" + key, evaluation, etag))
                throw new InvalidOperationException("Another request submitted this evaluation. Reload before retrying.");
            Services.EmailNotificationService.Saved(previous, evaluation);
            return key;
        }
        // ----------------------------------------------------------------
        private static void AuthorizeFinalRead(string placementId, bool academic)
        {
            var user = SessionHelper.Current;
            if (user == null || !user.IsActive || user.Role == UserRole.Student)
                throw new UnauthorizedAccessException("Final evaluations are confidential.");
            if (user.Role == UserRole.Coordinator) return;
            var p = new PlacementRepository().GetById(placementId);
            bool allowed = p != null && (user.Role == UserRole.AcademicSupervisor && p.AcademicSupervisorId == user.Id ||
                !academic && user.Role == UserRole.CompanySupervisor && p.CompanySupervisorId == user.Id &&
                ((CompanySupervisor)user).CompanyId == p.CompanyId);
            if (!allowed) throw new UnauthorizedAccessException("You are not assigned to this confidential evaluation.");
        }
        private static Placement AuthorizeFinalWrite(string placementId, bool academic)
        {
            AuthorizeFinalRead(placementId, academic);
            var user = SessionHelper.Current;
            var p = new PlacementRepository().GetById(placementId);
            if (p == null || (academic ? user.Role != UserRole.AcademicSupervisor || p.AcademicSupervisorId != user.Id :
                user.Role != UserRole.CompanySupervisor || p.CompanySupervisorId != user.Id))
                throw new UnauthorizedAccessException("Only the assigned supervisor can submit this evaluation.");
            if (Services.CompletionReviewService.IsFinal(new CompletionRepository().GetByPlacement(placementId)))
                throw new InvalidOperationException("This completion review is finalized. Its evidence is read-only.");
            return p;
        }

        /// <summary>Pushes a record and writes the generated key back into it.
        /// FirebaseContext.Push returns the key but does not store it, so
        /// without this step every record read back later would have a null Id
        /// and nothing could reference it.</summary>
        private static string PushWithId(string collection, object entity)
        {
            string id = FirebaseContext.Push(collection, entity);
            if (!string.IsNullOrEmpty(id))
            {
                FirebaseContext.Patch(collection + "/" + id,
                    new Dictionary<string, object> { { "Id", id } });
            }
            return id;
        }

        private static List<T> Deserialise<T>(string json) where T : class
        {
            List<T> results = new List<T>();
            if (string.IsNullOrWhiteSpace(json) || json == "null") return results;

            Dictionary<string, T> map = Json.Deserialize<Dictionary<string, T>>(json);
            if (map == null) return results;
            foreach (KeyValuePair<string, T> pair in map)
            {
                if (pair.Value != null)
                {
                    var company = pair.Value as FinalCompanyEvaluation;
                    var academic = pair.Value as FinalAcademicEvaluation;
                    var task = pair.Value as TaskEvaluation;
                    if (company != null) company.Id = pair.Key;
                    if (academic != null) academic.Id = pair.Key;
                    if (task != null) task.Id = pair.Key;
                    results.Add(pair.Value);
                }
            }
            return results;
        }
    }
}
