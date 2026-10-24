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

        /// <summary>Saves a grade or a revision request and tells the student.</summary>
        public override string Insert(TaskEvaluation entity)
        {
            string id = base.Insert(entity);
            if (!string.IsNullOrEmpty(id)) Services.NotificationService.TaskReviewed(entity);
            return id;
        }

        public List<TaskEvaluation> GetByTask(string taskId)
        {
            return GetWhere("TaskId", taskId);
        }
    }
}