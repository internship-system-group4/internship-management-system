using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Services;

namespace InternshipManagementSystem.Pages.CompanyArea
{
    /// <summary>
    /// Opens an applicant's CV or portfolio for the company reviewing the
    /// application. The student's own download page is student-only, so the
    /// company gets the file through here after an ownership check.
    /// Usage: ApplicantDocument.aspx?id={applicationId}&amp;type=cv|portfolio
    /// </summary>
    public partial class ApplicantDocument : Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            string applicationId = Request.QueryString["id"];
            bool isCv = Request.QueryString["type"] != "portfolio";

            InternshipApplication application;
            try
            {
                application = ApplicationRepository.IsValidKey(applicationId)
                    ? new ApplicationRepository().GetById(applicationId)
                    : null;
            }
            catch (Exception)
            {
                ShowMessage(L.T("Company.ApplicantDocument.WeCouldNotLoadThisApplication"));
                return;
            }

            // Only the company the student applied to may open the document.
            if (application == null || application.CompanyId != CurrentSupervisor.CompanyId)
            {
                ShowMessage(L.T("Company.ApplicantDocument.ThisApplicationIsNotAvailableTo"));
                return;
            }

            var documents = StudentDocumentService.LoadDocuments(application.StudentId);
            string submittedLink = isCv ? application.CvUrl : documents.PortfolioUrl;
            string storageName = isCv ? documents.CvStorageName : documents.PortfolioStorageName;
            string profileLink = isCv ? documents.CvUrl : documents.PortfolioUrl;

            // 1) The external link the student gave (Google Drive, GitHub...).
            if (StudentDocumentService.IsExternalLink(submittedLink))
            {
                Response.Redirect(submittedLink, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // 2) The PDF the student uploaded to their profile.
            string filePath = StudentDocumentService.UploadedFilePath(application.StudentId, storageName);
            if (filePath != null)
            {
                SendPdf(filePath, isCv ? "Applicant-CV.pdf" : "Applicant-Portfolio.pdf");
                return;
            }

            // 3) A newer external link saved on the student's profile.
            if (StudentDocumentService.IsExternalLink(profileLink))
            {
                Response.Redirect(profileLink, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ShowMessage(isCv
                ? L.T("Company.ApplicantDocument.ThisStudentHasNotSharedA")
                : L.T("Company.ApplicantDocument.ThisStudentHasNotSharedA2"));
        }

        private void SendPdf(string path, string fileName)
        {
            Response.Clear();
            Response.ContentType = "application/pdf";
            // "inline" opens the PDF in the browser tab instead of downloading it.
            Response.AddHeader("Content-Disposition", "inline; filename=\"" + fileName + "\"");
            Response.AddHeader("X-Content-Type-Options", "nosniff");
            Response.TransmitFile(path);
            Response.Flush();
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string message)
        {
            Response.StatusCode = 404;
            MessageText.Text = message;
        }
    }
}
