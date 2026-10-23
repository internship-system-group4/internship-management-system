// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello cards A13, A14)
//  The official completion report and certificate (cards A13, A14).
// =============================================================================

using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// Builds real PDF files on the server with no extra package. The PDF is
    /// created when it is opened, through Pages/Account/CompletionReport.aspx,
    /// which checks MayDownload first. So the file never sits at a public URL
    /// and only the coordinator and the student it belongs to can fetch it.
    ///
    /// The final evaluation forms are confidential, so the report shows only
    /// the final score and result - never the company or academic scores.
    /// </summary>
    public static class PdfReportService
    {
        private const string ReportPage = "~/Pages/Account/CompletionReport.aspx";

        public static string ReportUrl(string completionId)
        {
            return ReportPage + "?id=" + Uri.EscapeDataString(completionId ?? "");
        }

        public static string CertificateUrl(string completionId)
        {
            return ReportUrl(completionId) + "&doc=certificate";
        }

        /// <summary>The official Internship Completion Report (card A13).
        /// Returns null while the record is not approved.</summary>
        public static byte[] GenerateCompletionReport(CompletionRecord record, Student student,
                                                      Placement placement, string coordinatorName)
        {
            if (record == null || student == null || placement == null) return null;
            if (record.Status != CompletionStatus.Approved) return null;

            SimplePdf pdf = new SimplePdf(595, 842);   // A4 portrait
            double left = 56, right = 539;

            // Header band
            pdf.FillRect(0, 752, 595, 90, 0.10, 0.23, 0.42);
            pdf.Text(left, 806, 18, true, Constants.UniversityName, 1, 1, 1);
            pdf.Text(left, 786, 11, false, Constants.CollegeName + "  -  Internship Office", 1, 1, 1);
            pdf.Text(left, 768, 9, false, Constants.UniversityWebsite, 0.85, 0.9, 1);

            pdf.Text(left, 712, 18, true, "Official Internship Completion Report");
            pdf.Text(left, 692, 10, false, "Reference: " + Reference(record) + "     Issued: " + Date(record.ApprovedAt), 0.35, 0.42, 0.5);
            pdf.Line(left, 680, right, 680, 0.8);

            double y = 652;
            y = Section(pdf, left, y, "Student");
            y = Row(pdf, left, y, "Full name", student.FullName);
            y = Row(pdf, left, y, "Student number", student.StudentNumber);
            y = Row(pdf, left, y, "Programme", student.Major);
            y = Row(pdf, left, y, "Email", student.Email);

            y = Section(pdf, left, y - 10, "Internship");
            y = Row(pdf, left, y, "Company", placement.CompanyName);
            y = Row(pdf, left, y, "Position", placement.OpportunityTitle);
            y = Row(pdf, left, y, "Company supervisor", placement.CompanySupervisorName);
            y = Row(pdf, left, y, "Training period", Date(placement.StartDate) + "  to  " + Date(placement.EndDate));
            y = Row(pdf, left, y, "Approved training hours", record.ApprovedHours + " of " + record.RequiredHours + " required hours");

            y = Section(pdf, left, y - 10, "Final result");
            pdf.FillRect(left, y - 46, right - left, 56, 0.94, 0.96, 0.99);
            pdf.Text(left + 16, y - 12, 10, false, "Final score", 0.35, 0.42, 0.5);
            pdf.Text(left + 16, y - 36, 22, true, record.FinalScore.ToString("0.##", CultureInfo.InvariantCulture) + "%");
            pdf.Text(left + 220, y - 12, 10, false, "Result", 0.35, 0.42, 0.5);
            bool pass = record.Result == "Pass";
            pdf.Text(left + 220, y - 36, 22, true, record.Result ?? "-", pass ? 0.09 : 0.65, pass ? 0.45 : 0.15, pass ? 0.24 : 0.15);
            y -= 66;
            y = Paragraph(pdf, left, y, 9, right - left,
                "The final score combines graded tasks (" + GradingPolicy.TaskComponentWeight + "%), the company final evaluation ("
                + GradingPolicy.CompanyFinalWeight + "%) and the academic final evaluation (" + GradingPolicy.AcademicFinalWeight
                + "%). The pass mark is " + GradingPolicy.PassMarkPercent + "%.");

            if (!string.IsNullOrWhiteSpace(record.CoordinatorNote))
            {
                y = Section(pdf, left, y - 10, "Coordinator remarks");
                y = Paragraph(pdf, left, y, 10, right - left, record.CoordinatorNote);
            }

            y = Section(pdf, left, y - 10, "Approval");
            y = Paragraph(pdf, left, y, 10, right - left,
                "The University Internship Coordinator reviewed the company and academic final evaluations and the university's "
                + "requirements, and approved the completion of this internship on " + Date(record.ApprovedAt) + ".");

            // Signature
            double signY = Math.Min(y - 40, 150);
            pdf.Line(left, signY, left + 200, signY, 0.6);
            pdf.Text(left, signY - 14, 10, true, coordinatorName);
            pdf.Text(left, signY - 28, 9, false, "University Internship Coordinator", 0.35, 0.42, 0.5);

            pdf.Line(left, 60, right, 60, 0.5);
            pdf.Text(left, 46, 8, false, "Issued by the University Internship Management System. Reference " + Reference(record) + ".", 0.45, 0.5, 0.56);

            return pdf.ToBytes("Internship Completion Report - " + student.FullName);
        }

        /// <summary>The printable completion certificate (card A14).</summary>
        public static byte[] GenerateCertificate(CompletionRecord record, Student student,
                                                 Placement placement, string coordinatorName)
        {
            if (record == null || student == null || placement == null) return null;
            if (record.Status != CompletionStatus.Approved) return null;

            SimplePdf pdf = new SimplePdf(842, 595);   // A4 landscape
            double centre = 421;

            pdf.Rect(24, 24, 794, 547, 3, 0.10, 0.23, 0.42);
            pdf.Rect(34, 34, 774, 527, 0.8, 0.72, 0.6, 0.3);

            pdf.CentredText(centre, 510, 15, true, Constants.UniversityName.ToUpperInvariant(), 0.10, 0.23, 0.42);
            pdf.CentredText(centre, 490, 10, false, Constants.CollegeName, 0.35, 0.42, 0.5);

            pdf.CentredText(centre, 430, 30, true, "Certificate of Internship Completion");
            pdf.CentredText(centre, 390, 12, false, "This is to certify that", 0.35, 0.42, 0.5);
            pdf.CentredText(centre, 352, 26, true, student.FullName, 0.10, 0.23, 0.42);
            pdf.Line(centre - 200, 342, centre + 200, 342, 0.6);
            pdf.CentredText(centre, 322, 11, false, "Student number " + Clean(student.StudentNumber) + "  -  " + Clean(student.Major), 0.35, 0.42, 0.5);

            pdf.CentredText(centre, 284, 13, false, "has successfully completed " + record.ApprovedHours + " approved training hours as");
            pdf.CentredText(centre, 264, 13, true, Clean(placement.OpportunityTitle) + "  at  " + Clean(placement.CompanyName));
            pdf.CentredText(centre, 244, 13, false, "from " + Date(placement.StartDate) + " to " + Date(placement.EndDate) + ", with a final result of "
                + (record.Result ?? "-") + ".");

            pdf.Line(110, 140, 330, 140, 0.6);
            pdf.CentredText(220, 124, 10, true, coordinatorName);
            pdf.CentredText(220, 110, 9, false, "University Internship Coordinator", 0.35, 0.42, 0.5);

            pdf.Line(512, 140, 732, 140, 0.6);
            pdf.CentredText(622, 124, 10, true, Date(record.ApprovedAt));
            pdf.CentredText(622, 110, 9, false, "Date of approval", 0.35, 0.42, 0.5);

            pdf.CentredText(centre, 60, 8, false, "Reference " + Reference(record) + "  -  " + Constants.UniversityWebsite, 0.45, 0.5, 0.56);

            return pdf.ToBytes("Internship Completion Certificate - " + student.FullName);
        }

        /// <summary>Authorisation gate for card A16. Call this before serving
        /// any report file.</summary>
        public static bool MayDownload(CompletionRecord record, Models.Person requester)
        {
            if (record == null || requester == null) return false;
            if (requester.Role == Common.UserRole.Coordinator) return record.Status == CompletionStatus.Approved;
            return record.IsReleasedToStudent() && record.StudentId == requester.Id;
        }

        public static string Reference(CompletionRecord record)
        {
            string id = (record.Id ?? "").ToUpperInvariant();
            return "UIMS-" + (id.Length > 8 ? id.Substring(id.Length - 8) : id);
        }

        // ---- layout helpers ------------------------------------------------
        private static double Section(SimplePdf pdf, double x, double y, string title)
        {
            pdf.Text(x, y, 12, true, title, 0.10, 0.23, 0.42);
            return y - 20;
        }

        private static double Row(SimplePdf pdf, double x, double y, string label, string value)
        {
            pdf.Text(x, y, 10, false, label, 0.35, 0.42, 0.5);
            pdf.Text(x + 160, y, 10, false, Clean(value));
            return y - 17;
        }

        private static double Paragraph(SimplePdf pdf, double x, double y, double size, double width, string text)
        {
            foreach (string line in SimplePdf.Wrap(text, size, width))
            {
                pdf.Text(x, y, size, false, line);
                y -= size * 1.5;
            }
            return y;
        }

        private static string Date(long ms)
        {
            return ms > 0 ? Time.DisplayDate(ms) : "-";
        }

        private static string Clean(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value.Trim();
        }
    }

    /// <summary>
    /// A very small PDF writer: text in the built-in Helvetica fonts, lines and
    /// rectangles. Enough for a one-page report, with no NuGet package.
    /// Coordinates are in points from the bottom-left corner of the page.
    /// </summary>
    public class SimplePdf
    {
        private readonly double width;
        private readonly double height;
        private readonly StringBuilder content = new StringBuilder();

        public SimplePdf(double width, double height)
        {
            this.width = width;
            this.height = height;
        }

        public void Text(double x, double y, double size, bool bold, string text,
                         double r = 0.08, double g = 0.12, double b = 0.18)
        {
            content.AppendFormat("BT {0} rg /{1} {2} Tf {3} {4} Td ({5}) Tj ET\n",
                Colour(r, g, b), bold ? "F2" : "F1", N(size), N(x), N(y), Escape(text));
        }

        public void CentredText(double centreX, double y, double size, bool bold, string text,
                                double r = 0.08, double g = 0.12, double b = 0.18)
        {
            Text(centreX - TextWidth(text, size, bold) / 2, y, size, bold, text, r, g, b);
        }

        public void Line(double x1, double y1, double x2, double y2, double lineWidth)
        {
            content.AppendFormat("0.6 0.65 0.7 RG {0} w {1} {2} m {3} {4} l S\n",
                N(lineWidth), N(x1), N(y1), N(x2), N(y2));
        }

        public void Rect(double x, double y, double w, double h, double lineWidth, double r, double g, double b)
        {
            content.AppendFormat("{0} RG {1} w {2} {3} {4} {5} re S\n",
                Colour(r, g, b), N(lineWidth), N(x), N(y), N(w), N(h));
        }

        public void FillRect(double x, double y, double w, double h, double r, double g, double b)
        {
            content.AppendFormat("{0} rg {1} {2} {3} {4} re f\n", Colour(r, g, b), N(x), N(y), N(w), N(h));
        }

        /// <summary>Approximate Helvetica width - good enough to centre and wrap text.</summary>
        public static double TextWidth(string text, double size, bool bold)
        {
            return Ascii(text).Length * size * (bold ? 0.5 : 0.47);
        }

        public static List<string> Wrap(string text, double size, double maxWidth)
        {
            List<string> lines = new List<string>();
            foreach (string paragraph in (text ?? "").Replace("\r", "").Split('\n'))
            {
                string line = "";
                foreach (string word in paragraph.Split(' '))
                {
                    string candidate = line.Length == 0 ? word : line + " " + word;
                    if (line.Length > 0 && TextWidth(candidate, size, false) > maxWidth)
                    {
                        lines.Add(line);
                        line = word;
                    }
                    else
                    {
                        line = candidate;
                    }
                }
                lines.Add(line);
            }
            return lines;
        }

        public byte[] ToBytes(string title)
        {
            string stream = content.ToString();
            List<string> objects = new List<string>
            {
                "<< /Type /Catalog /Pages 2 0 R >>",
                "<< /Type /Pages /Kids [5 0 R] /Count 1 >>",
                "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>",
                "<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>",
                "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 " + N(width) + " " + N(height) + "] "
                    + "/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> /Contents 6 0 R >>",
                "<< /Length " + stream.Length + " >>\nstream\n" + stream + "endstream",
                "<< /Title (" + Escape(title) + ") /Producer (UIMS) >>"
            };

            StringBuilder pdf = new StringBuilder("%PDF-1.4\n");
            List<int> offsets = new List<int>();
            for (int i = 0; i < objects.Count; i++)
            {
                offsets.Add(pdf.Length);
                pdf.Append(i + 1).Append(" 0 obj\n").Append(objects[i]).Append("\nendobj\n");
            }

            int xref = pdf.Length;
            pdf.Append("xref\n0 ").Append(objects.Count + 1).Append("\n0000000000 65535 f \n");
            foreach (int offset in offsets) pdf.Append(offset.ToString("D10")).Append(" 00000 n \n");
            pdf.Append("trailer\n<< /Size ").Append(objects.Count + 1).Append(" /Root 1 0 R /Info 7 0 R >>\n");
            pdf.Append("startxref\n").Append(xref).Append("\n%%EOF");

            // Everything above is plain ASCII, so one character is one byte.
            return Encoding.ASCII.GetBytes(pdf.ToString());
        }

        private static string Escape(string text)
        {
            return Ascii(text).Replace("\\", "\\\\").Replace("(", "\\(").Replace(")", "\\)");
        }

        /// <summary>The built-in fonts cannot draw non-Latin letters, so they
        /// become '?'. Common typographic marks are mapped to plain ones.</summary>
        private static string Ascii(string text)
        {
            if (string.IsNullOrEmpty(text)) return "";
            StringBuilder result = new StringBuilder(text.Length);
            foreach (char c in text)
            {
                if (c >= 32 && c < 127) result.Append(c);
                else if (c == '–' || c == '—' || c == '·') result.Append('-');
                else if (c == '‘' || c == '’') result.Append('\'');
                else if (c == '“' || c == '”') result.Append('"');
                else if (c == '\t') result.Append(' ');
                else if (!char.IsControl(c)) result.Append('?');
            }
            return result.ToString();
        }

        private static string Colour(double r, double g, double b)
        {
            return N(r) + " " + N(g) + " " + N(b);
        }

        private static string N(double value)
        {
            return value.ToString("0.###", CultureInfo.InvariantCulture);
        }
    }
}
