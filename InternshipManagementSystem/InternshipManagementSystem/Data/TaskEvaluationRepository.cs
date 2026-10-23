//fatima new one 
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class TaskEvaluationRepository : RepositoryBase<TaskEvaluation>
    {
        protected override string Collection
        {
            get { return Constants.Paths.TaskEvaluations; }
        }

        protected override void SetId(TaskEvaluation entity, string id)
        {
            entity.Id = id;
        }
    }
}