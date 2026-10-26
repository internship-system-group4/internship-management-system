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
        private bool pdfResponse;
        protected void Page_Load(object sender, EventArgs e)
        {
            string applicationId = Request.QueryString["id"];
            bool isCv = Request.QueryString["type"] != "portfolio";
            bool preview = Request.QueryString["preview"] == "1";

            // A trainee's CV (My Trainees, Final Evaluation): ?trainee={placementId}
            if (!string.IsNullOrEmpty(Request.QueryString["trainee"]))
            {
                SendTraineeDocument(Request.QueryString["trainee"]);
                return;
            }

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
                if (preview) { ShowMessage(L.T("Company.ApplicantDocument.ExternalPreviewUnavailable")); return; }
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
                if (preview) { ShowMessage(L.T("Company.ApplicantDocument.ExternalPreviewUnavailable")); return; }
                Response.Redirect(profileLink, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            ShowMessage(isCv
                ? L.T("Company.ApplicantDocument.ThisStudentHasNotSharedA")
                : L.T("Company.ApplicantDocument.ThisStudentHasNotSharedA2"));
        }

        /// <summary>Opens the CV of a trainee placed at this company: the uploaded PDF
        /// first, then a CV link, then the portfolio (file or link).</summary>
        private void SendTraineeDocument(string placementId)
        {
            Placement placement;
            Student student;
            try
            {
                placement = ApplicationRepository.IsValidKey(placementId) ? new PlacementRepository().GetById(placementId) : null;
                student = placement == null ? null : new UserRepository().GetStudent(placement.StudentId);
            }
            catch (Exception)
            {
                ShowMessage(L.T("Company.ApplicantDocument.WeCouldNotLoadThisApplication"));
                return;
            }

            // Only the trainee's own company may open the document.
            if (placement == null || placement.CompanyId != CurrentSupervisor.CompanyId)
            {
                ShowMessage(L.T("Company.ApplicantDocument.ThisApplicationIsNotAvailableTo"));
                return;
            }

            var documents = StudentDocumentService.LoadDocuments(placement.StudentId);

            string cvFile = StudentDocumentService.UploadedFilePath(placement.StudentId, documents.CvStorageName);
            if (cvFile != null) { SendPdf(cvFile, "Trainee-CV.pdf"); return; }

            string[] links = { documents.CvUrl, student == null ? null : student.CvUrl };
            foreach (string link in links)
            {
                if (StudentDocumentService.IsExternalLink(link))
                {
                    Response.Redirect(link, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }

            string portfolioFile = StudentDocumentService.UploadedFilePath(placement.StudentId, documents.PortfolioStorageName);
            if (portfolioFile != null) { SendPdf(portfolioFile, "Trainee-Portfolio.pdf"); return; }

            string[] portfolioLinks = { documents.PortfolioUrl, student == null ? null : student.PortfolioUrl };
            foreach (string link in portfolioLinks)
            {
                if (StudentDocumentService.IsExternalLink(link))
                {
                    Response.Redirect(link, false);
                    Context.ApplicationInstance.CompleteRequest();
                    return;
                }
            }

            ShowMessage(L.T("Company.ApplicantDocument.ThisStudentHasNotSharedA"));
        }

        private void SendPdf(string path, string fileName)
        {
            pdfResponse = true;
            Response.Clear();
            Response.ContentType = "application/pdf";
            // "inline" opens the PDF in the browser tab instead of downloading it.
            string disposition = Request.QueryString["download"] == "1" ? "attachment" : "inline";
            Response.AddHeader("Content-Disposition", disposition + "; filename=\"" + fileName + "\"");
            Response.AddHeader("X-Content-Type-Options", "nosniff");
            Response.TransmitFile(path);
            Response.Flush();
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowMessage(string message)
        {
            Response.StatusCode = 404;
            Response.TrySkipIisCustomErrors = true;
            MessageText.Text = message;
        }

        protected override void Render(System.Web.UI.HtmlTextWriter writer)
        {
            if (!pdfResponse) base.Render(writer);
        }
    }
}
