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

namespace InternshipManagementSystem.Pages.AccountArea
{
    /// <summary>Downloads a task attachment saved on the server (TaskAttachmentStorage).
    /// Allowed: the company's supervisors, a trainee who was given a task with this
    /// file, that trainee's academic supervisor, and coordinators.</summary>
    public class TaskAttachment : IHttpHandler, IRequiresSessionState
    {
        public bool IsReusable { get { return false; } }

        public void ProcessRequest(HttpContext context)
        {
            context.Response.Cache.SetCacheability(HttpCacheability.NoCache);
            context.Response.Cache.SetNoStore();
            if (context.Request.HttpMethod != "GET") { context.Response.StatusCode = 405; return; }

            Person sessionUser = SessionHelper.Current;
            if (sessionUser == null) { context.Response.StatusCode = 401; return; }

            string companyId = context.Request.QueryString["company"];
            string storageName = context.Request.QueryString["file"];
            string path = TaskAttachmentStorage.LocalPath(companyId, storageName);
            if (path == null) { context.Response.StatusCode = 404; return; }

            try
            {
                Person actor = new UserRepository().GetPerson(sessionUser.Id);
                if (actor == null || !actor.IsActive || actor.MustChangePassword)
                { context.Response.StatusCode = 403; return; }

                string url = TaskAttachmentStorage.LocalUrl(companyId, storageName);
                if (!Allowed(actor, companyId, url) || !File.Exists(path))
                { context.Response.StatusCode = 404; return; }

                // Use the name the supervisor uploaded when we know it.
                InternshipTask task = new TaskRepository().GetByCompany(companyId)
                    .FirstOrDefault(t => t != null && t.AttachmentUrl == url);
                string name = task != null && !string.IsNullOrWhiteSpace(task.AttachmentName)
                    ? Path.GetFileName(task.AttachmentName) : storageName;

                context.Response.ContentType = MimeMapping.GetMimeMapping(path);
                context.Response.AddHeader("X-Content-Type-Options", "nosniff");
                context.Response.AddHeader("Content-Disposition",
                    "attachment; filename*=UTF-8''" + Uri.EscapeDataString(name));
                context.Response.TransmitFile(path);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Task attachment: " + ex);
                context.Response.StatusCode = 503;
                context.Response.TrySkipIisCustomErrors = true;
            }
        }

        private static bool Allowed(Person actor, string companyId, string url)
        {
            if (actor.Role == UserRole.Coordinator) return true;

            if (actor.Role == UserRole.CompanySupervisor)
            {
                var supervisor = actor as CompanySupervisor;
                return supervisor != null && supervisor.CompanyId == companyId;
            }

            if (actor.Role == UserRole.Student)
                return new TaskRepository().GetByStudent(actor.Id)
                    .Any(t => t != null && t.CompanyId == companyId && t.AttachmentUrl == url);

            if (actor.Role == UserRole.AcademicSupervisor)
            {
                var placements = new PlacementRepository();
                return new TaskRepository().GetByCompany(companyId)
                    .Where(t => t != null && t.AttachmentUrl == url)
                    .Any(t =>
                    {
                        Placement placement = placements.GetById(t.PlacementId);
                        return placement != null && placement.AcademicSupervisorId == actor.Id;
                    });
            }
            return false;
        }
    }
}
