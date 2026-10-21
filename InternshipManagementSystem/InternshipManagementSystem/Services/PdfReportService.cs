// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A13)
//  The official completion report and certificate (cards A13, A14).
// =============================================================================

using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// TODO(Ahmad, cards A13 and A14): pick one of the two routes below and
    /// delete the other. Both satisfy "download and print"; they differ in
    /// cost and in how much control you get.
    ///
    /// Route 1 - a print-styled page (no dependency, ~1 hour)
    ///   Build Reports/CompletionReport.aspx with the university header, the
    ///   student's details and the final result, plus a stylesheet with
    ///   @media print rules and a Print button calling window.print(). The
    ///   browser's own "Save as PDF" produces the file. Nothing to install,
    ///   nothing to break on anyone's machine.
    ///
    /// Route 2 - a real server-side PDF (one NuGet package, ~3 hours)
    ///   Install-Package iTextSharp  (or PdfSharp + MigraDoc), build the
    ///   document in GenerateCompletionReport below, write the bytes to
    ///   Response with content type application/pdf, and store the file
    ///   through StorageService so CompletionRecord.ReportFileUrl can point at
    ///   it. Choose this if the demo should show a file appearing in Firebase
    ///   Storage rather than a browser print dialog.
    ///
    /// Whichever route you take, the gate is the same and it is a requirement:
    /// nothing is generated or downloadable until the coordinator has approved
    /// completion, and only the student the report belongs to may fetch it.
    /// </summary>
    public static class PdfReportService
    {
        /// <summary>Returns the stored report URL, generating it if needed.
        /// Returns null when the record is not approved yet.</summary>
        public static string GenerateCompletionReport(CompletionRecord record, Student student)
        {
            if (record == null || student == null) return null;
            if (record.Status != Common.CompletionStatus.Approved) return null;

            throw new System.NotImplementedException(
                "Card A13: implement the completion report. See the comment above this method.");
        }

        public static string GenerateCertificate(CompletionRecord record, Student student)
        {
            if (record == null || student == null) return null;
            if (record.Status != Common.CompletionStatus.Approved) return null;

            throw new System.NotImplementedException(
                "Card A14: implement the completion certificate.");
        }

        /// <summary>Authorisation gate for card A16. Call this before serving
        /// any report file.</summary>
        public static bool MayDownload(CompletionRecord record, Models.Person requester)
        {
            if (record == null || requester == null) return false;
            if (requester.Role == Common.UserRole.Coordinator) return true;
            return record.IsReleasedToStudent() && record.StudentId == requester.Id;
        }
    }
}
