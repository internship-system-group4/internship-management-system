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

        public List<TaskEvaluation> GetTaskEvaluationsForPlacement(string placementId)
        {
            return Deserialise<TaskEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.TaskEvaluations, "PlacementId", placementId));
        }

        public string SaveTaskEvaluation(TaskEvaluation evaluation)
        {
            return PushWithId(Constants.Paths.TaskEvaluations, evaluation);
        }

        // ---- final company evaluation: CONFIDENTIAL ----------------------
        public FinalCompanyEvaluation GetCompanyFinalForPlacement(string placementId)
        {
            List<FinalCompanyEvaluation> found = Deserialise<FinalCompanyEvaluation>(
                FirebaseContext.GetWhere(Constants.Paths.CompanyEvaluations, "PlacementId", placementId));
            return found.Count > 0 ? found[0] : null;
        }

        public string SaveCompanyFinal(FinalCompanyEvaluation evaluation)
        {
            if (!string.IsNullOrEmpty(evaluation.Id))
            {
                FirebaseContext.Put(Constants.Paths.CompanyEvaluations + "/" + evaluation.Id, evaluation);
                return evaluation.Id;
            }
            return PushWithId(Constants.Paths.CompanyEvaluations, evaluation);
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
            if (!string.IsNullOrEmpty(evaluation.Id))
            {
                FirebaseContext.Put(Constants.Paths.AcademicEvaluations + "/" + evaluation.Id, evaluation);
                return evaluation.Id;
            }
            return PushWithId(Constants.Paths.AcademicEvaluations, evaluation);
        }

        // ----------------------------------------------------------------
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
                if (pair.Value != null) results.Add(pair.Value);
            }
            return results;
        }
    }
}
