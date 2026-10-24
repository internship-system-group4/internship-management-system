// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card X02)
//  Task evaluations and the two confidential final evaluations.
// =============================================================================

using System.Collections.Generic;
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

        /// <summary>Every task evaluation. Used only as a fallback when the
        /// database has no .indexOn rule for a filtered query.</summary>
        public List<TaskEvaluation> GetAllTaskEvaluations()
        {
            return Deserialise<TaskEvaluation>(FirebaseContext.Get(Constants.Paths.TaskEvaluations));
        }

        public List<TaskEvaluation> GetTaskEvaluationsForPlacement(string placementId)
        {
            return Deserialise<TaskEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.TaskEvaluations, "PlacementId", placementId));
        }

        public string SaveTaskEvaluation(TaskEvaluation evaluation)
        {
            string id = PushWithId(Constants.Paths.TaskEvaluations, evaluation);
            if (!string.IsNullOrEmpty(id)) Services.NotificationService.TaskReviewed(evaluation);
            return id;
        }

        // ---- final company evaluation: CONFIDENTIAL ----------------------
        public FinalCompanyEvaluation GetCompanyFinalForPlacement(string placementId)
        {
            if (string.IsNullOrEmpty(placementId)) return null;

            List<FinalCompanyEvaluation> found;
            try
            {
                found = Deserialise<FinalCompanyEvaluation>(
                    FirebaseContext.GetWhere(Constants.Paths.CompanyEvaluations, "PlacementId", placementId));
            }
            catch (FirebaseException)
            {
                // No .indexOn rule for PlacementId yet: read all and filter here.
                found = new List<FinalCompanyEvaluation>();
                foreach (FinalCompanyEvaluation evaluation in GetAllCompanyFinals())
                {
                    if (evaluation.PlacementId == placementId) found.Add(evaluation);
                }
            }

            // Prefer the submitted record if a draft was ever duplicated.
            FinalCompanyEvaluation best = null;
            foreach (FinalCompanyEvaluation evaluation in found)
            {
                if (best == null || (evaluation.IsSubmitted && !best.IsSubmitted)) best = evaluation;
            }
            return best;
        }

        /// <summary>Every company final written for one company. The company
        /// supervisor's Reports page uses this; never call it from a student page.</summary>
        public List<FinalCompanyEvaluation> GetCompanyFinalsForCompany(string companyId)
        {
            List<FinalCompanyEvaluation> result = new List<FinalCompanyEvaluation>();
            if (string.IsNullOrEmpty(companyId)) return result;

            foreach (FinalCompanyEvaluation evaluation in GetAllCompanyFinals())
            {
                if (evaluation.CompanyId == companyId) result.Add(evaluation);
            }
            return result;
        }

        private List<FinalCompanyEvaluation> GetAllCompanyFinals()
        {
            return Deserialise<FinalCompanyEvaluation>(FirebaseContext.Get(Constants.Paths.CompanyEvaluations));
        }

        public string SaveCompanyFinal(FinalCompanyEvaluation evaluation)
        {
            string id;
            if (!string.IsNullOrEmpty(evaluation.Id))
            {
                FirebaseContext.Put(Constants.Paths.CompanyEvaluations + "/" + evaluation.Id, evaluation);
                id = evaluation.Id;
            }
            else
            {
                id = PushWithId(Constants.Paths.CompanyEvaluations, evaluation);
            }
            // Drafts send nothing; only a submitted form notifies.
            Services.NotificationService.CompanyFinalSubmitted(evaluation);
            return id;
        }

        // ---- final academic evaluation: CONFIDENTIAL --------------------
        public FinalAcademicEvaluation GetAcademicFinalForPlacement(string placementId)
        {
            List<FinalAcademicEvaluation> found = Deserialise<FinalAcademicEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.AcademicEvaluations, "PlacementId", placementId));
            return found.Count > 0 ? found[0] : null;
        }

        public string SaveAcademicFinal(FinalAcademicEvaluation evaluation)
        {
            string id;
            if (!string.IsNullOrEmpty(evaluation.Id))
            {
                FirebaseContext.Put(Constants.Paths.AcademicEvaluations + "/" + evaluation.Id, evaluation);
                id = evaluation.Id;
            }
            else
            {
                id = PushWithId(Constants.Paths.AcademicEvaluations, evaluation);
            }
            // Drafts send nothing; only a submitted form notifies.
            Services.NotificationService.AcademicFinalSubmitted(evaluation);
            return id;
        }

        // ----------------------------------------------------------------
        /// <summary>Pushes a record and writes the generated key back into it.
        /// FirebaseContext.Push returns the key but does not store it, so
        /// without this step every record read back later would have a null Id
        /// and nothing could reference it.</summary>
        private static string PushWithId(string collection, object entity)
        {
            // One request instead of Push + Patch.
            return FirebaseContext.PushWithId(collection, entity);
        }

        private static List<T> Deserialise<T>(string json) where T : class
        {
            List<T> results = new List<T>();
            if (string.IsNullOrWhiteSpace(json) || json == "null") return results;

            Dictionary<string, T> map = Json.Deserialize<Dictionary<string, T>>(json);
            if (map == null) return results;
            foreach (KeyValuePair<string, T> pair in map)
            {
                if (pair.Value != null) results.Add(pair.Value);
            }
            return results;
        }
    }
}
