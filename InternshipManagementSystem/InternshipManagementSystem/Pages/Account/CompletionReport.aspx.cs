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
                Fail(404, "This report is not available.");
                return;
            }

            UserRepository users = new UserRepository();
            Student student = users.GetStudent(record.StudentId);
            Placement placement = new PlacementRepository().GetById(record.PlacementId);
            Person coordinator = users.GetPerson(record.ReviewedByCoordinatorId);
            string coordinatorName = coordinator == null ? "Internship Coordinator" : coordinator.FullName;

            bool certificate = Request.QueryString["doc"] == "certificate";
            byte[] pdf = certificate
                ? PdfReportService.GenerateCertificate(record, student, placement, coordinatorName)
                : PdfReportService.GenerateCompletionReport(record, student, placement, coordinatorName);
            if (pdf == null)
            {
                Fail(404, "This report is not available.");
                return;
            }

            string fileName = (certificate ? "Completion-Certificate-" : "Completion-Report-")
                              + PdfReportService.Reference(record) + ".pdf";
            Response.Clear();
            Response.ContentType = "application/pdf";
            // inline: opens in the browser's PDF viewer, which can download and print it.
            Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
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
    }
}
