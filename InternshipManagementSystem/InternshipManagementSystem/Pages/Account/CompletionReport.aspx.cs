// =============================================================================
//  Official completion report / certificate download
//  Owner : Ahmad
//  Cards : A13, A14, A16
//
//  Streams the PDF built by PdfReportService. Only the coordinator and the
//  student the record belongs to may open it, and only after approval.
//    CompletionReport.aspx?id={completionId}                  -> report
//    CompletionReport.aspx?id={completionId}&doc=certificate  -> certificate
// =============================================================================
using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class CompletionReport : Security.SecurePage
    {
        protected override UserRole[] AllowedRoles
        {
            get { return new[] { UserRole.Student, UserRole.Coordinator }; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            string id = Request.QueryString["id"];
            CompletionRecord record = ApplicationRepository.IsValidKey(id)
                ? new CompletionRepository().GetById(id) : null;

            if (!PdfReportService.MayDownload(record, CurrentUser))
            {
                Fail(404, L.T("Account.CompletionReport.ThisReportIsNotAvailable"));
                return;
            }

            UserRepository users = new UserRepository();
            Student student = users.GetStudent(record.StudentId);
            Placement placement = new PlacementRepository().GetById(record.PlacementId);
            Person coordinator = users.GetPerson(record.ReviewedByCoordinatorId);
            string coordinatorName = coordinator == null ? "Internship Coordinator" : coordinator.FullName;

            // The certificate is printed by the coordinator (card A14); the
            // student receives the completion report.
            bool certificate = Request.QueryString["doc"] == "certificate";
            if (certificate && CurrentUser.Role != UserRole.Coordinator)
            {
                Fail(404, L.T("Account.CompletionReport.ThisReportIsNotAvailable"));
                return;
            }
            byte[] pdf = certificate
                ? PdfReportService.GenerateCertificate(record, student, placement, coordinatorName)
                : PdfReportService.GenerateCompletionReport(record, student, placement, coordinatorName);
            if (pdf == null)
            {
                Fail(404, L.T("Account.CompletionReport.ThisReportIsNotAvailable"));
                return;
            }

            string fileName = (certificate ? "Completion-Certificate-" : "Completion-Report-")
                              + PdfReportService.Reference(record) + ".pdf";
            Response.Clear();
            Response.ContentType = "application/pdf";
            // Private documents: never cached by shared proxies.
            Response.Cache.SetCacheability(System.Web.HttpCacheability.Private);
            Response.Cache.SetNoStore();
            Response.AddHeader("X-Content-Type-Options", "nosniff");
            // inline (default): opens in the browser's PDF viewer for printing.
            // &download=1: saved as a file.
            string disposition = Request.QueryString["download"] == "1" ? "attachment" : "inline";
            Response.AddHeader("Content-Disposition", disposition + "; filename=\"" + fileName + "\"");
            Response.BinaryWrite(pdf);
            Response.Flush();
            Context.ApplicationInstance.CompleteRequest();
        }

        private void Fail(int status, string message)
        {
            Response.Clear();
            Response.StatusCode = status;
            Response.TrySkipIisCustomErrors = true;
            Response.ContentType = "text/plain";
            Response.Write(message);
            Context.ApplicationInstance.CompleteRequest();
        }

        // The page writes the PDF itself; skip the normal HTML rendering.
        protected override void Render(System.Web.UI.HtmlTextWriter writer)
        {
        }

        // Global.asax localises page titles on PreRenderComplete, which needs a
        // <head runat="server">. This page has none (it sends a PDF or a plain
        // 404), so the event is not raised here; otherwise every refusal
        // became a 500 error.
        protected override void OnPreRenderComplete(EventArgs e)
        {
        }
    }
}
