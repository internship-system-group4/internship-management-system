using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class TaskEvaluationRepository : NotifyingRepositoryBase<TaskEvaluation>
    {
        protected override string Collection
        {
            get { return Constants.Paths.TaskEvaluations; }
        }

        protected override void SetId(TaskEvaluation entity, string id)
        {
            entity.Id = id;
        }

        /// <summary>A new grade or revision request tells the student.</summary>
        protected override bool SendNotice(TaskEvaluation previous, TaskEvaluation current)
        {
            if (previous != null) return false;
            Services.NotificationService.TaskReviewed(current);
            return true;
        }

        public List<TaskEvaluation> GetByTask(string taskId)
        {
            return GetWhere("TaskId", taskId);
        }
    }
}