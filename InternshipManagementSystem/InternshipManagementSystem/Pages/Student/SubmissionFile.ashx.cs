using System;
using System.IO;
using System.Linq;
using System.Web;
using System.Web.SessionState;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.StudentArea
{
    /// <summary>Serve a saved submission only to its student and the placement's reviewers.</summary>
    public class SubmissionFile : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            if (context.Request.HttpMethod != "GET") { context.Response.StatusCode = 405; return; }
            Person sessionUser = SessionHelper.Current;
            if (sessionUser == null) { context.Response.StatusCode = 401; return; }
            string taskId = context.Request.QueryString["task"];
            string storageName = context.Request.QueryString["file"];
            if (!ApplicationRepository.IsValidKey(taskId) ||
                !TaskSubmissionStorage.IsStorageName(storageName))
            { context.Response.StatusCode = 404; return; }
            try
            {
                Person actor = new UserRepository().GetPerson(sessionUser.Id);
                if (actor == null || !actor.IsActive || actor.MustChangePassword)
                { context.Response.StatusCode = 403; return; }
                InternshipTask task = new TaskRepository().GetById(taskId);
                Placement placement = task == null ? null : new PlacementRepository().GetById(task.PlacementId);
                if (placement == null || placement.Id != task.PlacementId ||
                    placement.StudentId != task.StudentId || !Allowed(actor, placement))
                { context.Response.StatusCode = 403; return; }
                string expected = TaskSubmissionStorage.LocalUrl(taskId, storageName);
                bool recorded = new SubmissionRepository().GetByTask(taskId).Any(s =>
                    s != null && s.StudentId == task.StudentId &&
                    s.PlacementId == placement.Id && s.FileUrl == expected);
                string path = TaskSubmissionStorage.LocalPath(task.StudentId, taskId, storageName);
                if (!recorded || path == null || !File.Exists(path))
                { context.Response.StatusCode = 404; return; }
                context.Response.ContentType = MimeMapping.GetMimeMapping(path);
                context.Response.AddHeader("Content-Disposition", "attachment; filename=" + storageName);
                context.Response.TransmitFile(path);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Submission file: " + ex);
                context.Response.StatusCode = 503;
                context.Response.TrySkipIisCustomErrors = true;
            }
        }

        private static bool Allowed(Person actor, Placement placement)
        {
            if (actor.Role == UserRole.Coordinator) return true;
            if (actor.Role == UserRole.Student) return actor.Id == placement.StudentId;
            if (actor.Role == UserRole.AcademicSupervisor) return actor.Id == placement.AcademicSupervisorId;
            if (actor.Role == UserRole.CompanySupervisor)
            {
                CompanySupervisor supervisor = actor as CompanySupervisor;
                return actor.Id == placement.CompanySupervisorId ||
                    (supervisor != null && supervisor.CompanyId == placement.CompanyId);
            }
            return false;
        }
    }
}
