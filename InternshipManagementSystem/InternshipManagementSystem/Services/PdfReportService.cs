// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello cards A13, A14)
//  The internship completion report and certificate (cards A13, A14).
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
    /// the released result - never the company or academic scores.
    ///
    /// Honesty rules: the documents are UIMS project records. They carry a
    /// static "UIMS - APPROVED" status mark, never a university seal or a
    /// signature, and say plainly that they are not issued by GJU.
    /// Values are read from the snapshot saved at approval, so every download
    /// of the same record prints the same details.
    /// </summary>
    public static class PdfReportService
    {
        private const string ReportPage = "~/Pages/Account/CompletionReport.aspx";

        // Colours (0-1 RGB). Navy matches --ui-primary #264f73; green is the approval tone.
        private static readonly double[] Navy = { 0.149, 0.31, 0.451 };
        private static readonly double[] Ink = { 0.075, 0.24, 0.38 };
        private static readonly double[] Muted = { 0.31, 0.4, 0.48 };
        private static readonly double[] Green = { 0.125, 0.376, 0.267 };
        private static readonly double[] Gold = { 0.784, 0.639, 0.286 };

        public static string ReportUrl(string completionId)
        {
            return ReportPage + "?id=" + Uri.EscapeDataString(completionId ?? "");
        }

        public static string CertificateUrl(string completionId)
        {
            return ReportUrl(completionId) + "&doc=certificate";
        }

        /// <summary>Same document, sent as a file download instead of opening in the browser.</summary>
        public static string DownloadUrl(string url)
        {
            return url + "&download=1";
        }

        /// <summary>The Internship Completion Report (card A13).
        /// Returns null while the record is not approved.</summary>
        public static byte[] GenerateCompletionReport(CompletionRecord record, Student student,
                                                      Placement placement, string coordinatorName)
        {
            if (record == null || student == null || placement == null) return null;
            if (record.Status != CompletionStatus.Approved) return null;
            Details d = Details.From(record, student, placement, coordinatorName);

            SimplePdf pdf = new SimplePdf(595, 842);   // A4 portrait
            double left = 56, right = 539;

            // Header band
            pdf.FillRect(0, 760, 595, 82, Navy[0], Navy[1], Navy[2]);
            pdf.FillRect(0, 757, 595, 3, Gold[0], Gold[1], Gold[2]);
            pdf.Text(left, 812, 17, true, Constants.UniversityName, 1, 1, 1);
            pdf.Text(left, 794, 10.5, false, Constants.CollegeName, 0.88, 0.92, 0.97);
            pdf.Text(left, 777, 9, false, "University Internship Management System (UIMS)", 0.78, 0.85, 0.93);

            pdf.Text(left, 718, 20, true, "Internship Completion Report", Ink[0], Ink[1], Ink[2]);
            pdf.Text(left, 699, 9.5, false, "Reference " + Reference(record) + "     Approved " + LongDate(record.ApprovedAt),
                Muted[0], Muted[1], Muted[2]);
            pdf.Line(left, 688, 420, 688, 0.6);

            // Approval mark, top right, static (never animated in a PDF).
            Stamp(pdf, 486, 708, record.ApprovedAt, 0.82);

            double y = 660;
            y = Section(pdf, left, y, "Student");
            y = Row(pdf, left, y, "Full name", d.StudentName);
            y = Row(pdf, left, y, "Student number", d.StudentNumber);
            y = Row(pdf, left, y, "Academic programme", d.ProgramLine);

            y = Section(pdf, left, y - 12, "Internship");
            y = Row(pdf, left, y, "Internship type", d.TypeLine);
            y = Row(pdf, left, y, "Company", d.CompanyName);
            y = Row(pdf, left, y, "Position", d.OpportunityTitle);
            y = Row(pdf, left, y, "Training period", LongDate(d.Start) + "  to  " + LongDate(d.End));
            y = Row(pdf, left, y, d.International ? "Verified duration" : "Verified training hours", d.VerifiedLine);

            // Outcome
            y = Section(pdf, left, y - 12, "Outcome");
            pdf.FillRect(left, y - 52, right - left, 64, 0.94, 0.97, 0.95);
            pdf.Rect(left, y - 52, right - left, 64, 0.6, 0.78, 0.87, 0.81);
            pdf.Text(left + 16, y - 10, 10, false, "Released final result", Muted[0], Muted[1], Muted[2]);
            bool pass = record.Result == "Pass";
            pdf.Text(left + 16, y - 40, 26, true, Clean(record.Result), pass ? Green[0] : 0.65, pass ? Green[1] : 0.17, pass ? Green[2] : 0.21);
            pdf.Text(left + 200, y - 10, 10, false, "Supporting score", Muted[0], Muted[1], Muted[2]);
            pdf.Text(left + 200, y - 38, 17, true, record.FinalScore.ToString("0.##", CultureInfo.InvariantCulture) + "%", Ink[0], Ink[1], Ink[2]);
            pdf.Text(left + 320, y - 10, 10, false, "Completion decision", Muted[0], Muted[1], Muted[2]);
            pdf.Text(left + 320, y - 38, 15, true, "Approved", Green[0], Green[1], Green[2]);
            y -= 72;
            y = Paragraph(pdf, left, y, 9, right - left,
                "The supporting score uses the UIMS project-proposed evaluation method " + Clean(record.EvaluationMethod ?? EvaluationMethod.Id)
                + " (graded tasks " + GradingPolicy.TaskComponentWeight + "%, company final evaluation " + GradingPolicy.CompanyFinalWeight
                + "%, academic final evaluation " + GradingPolicy.AcademicFinalWeight + "%, pass mark " + GradingPolicy.PassMarkPercent
                + "%). These weights are a project proposal, not a published GJU grading policy. The coordinator's completion decision is "
                + "recorded separately from the score.", Muted);

            if (!string.IsNullOrWhiteSpace(record.CoordinatorNote))
            {
                y = Section(pdf, left, y - 12, "Coordinator remarks");
                y = Paragraph(pdf, left, y, 11.5, right - left, record.CoordinatorNote, Ink, 4);
            }

            y = Section(pdf, left, y - 12, "Coordinator decision");
            y = Row(pdf, left, y, "Decision", "Internship completion approved in UIMS");
            y = Row(pdf, left, y, "Recorded by", d.CoordinatorName + " (University Internship Coordinator, UIMS role)");
            y = Row(pdf, left, y, "Recorded on", LongDate(record.ApprovedAt));
            y = Paragraph(pdf, left, y - 6, 10, right - left,
                "Before approval the coordinator reviewed the company and academic final evaluations, the approved training record "
                + "and the requirements listed for this internship type, each with a written evidence reference.", Muted);

            Footer(pdf, left, right, record);
            return pdf.ToBytes("Internship Completion Report - " + d.StudentName);
        }

        /// <summary>The printable completion certificate (card A14).</summary>
        public static byte[] GenerateCertificate(CompletionRecord record, Student student,
                                                 Placement placement, string coordinatorName)
        {
            if (record == null || student == null || placement == null) return null;
            if (record.Status != CompletionStatus.Approved) return null;
            Details d = Details.From(record, student, placement, coordinatorName);

            SimplePdf pdf = new SimplePdf(842, 595);   // A4 landscape
            double centre = 421;

            pdf.FillRect(0, 0, 842, 595, 0.988, 0.984, 0.972);
            pdf.Rect(22, 22, 798, 551, 2.5, Navy[0], Navy[1], Navy[2]);
            pdf.Rect(31, 31, 780, 533, 0.8, Gold[0], Gold[1], Gold[2]);

            pdf.CentredText(centre, 520, 14, true, Constants.UniversityName.ToUpperInvariant(), Navy[0], Navy[1], Navy[2]);
            pdf.CentredText(centre, 502, 10, false, Constants.CollegeName + "  -  University Internship Management System (UIMS)", Muted[0], Muted[1], Muted[2]);
            pdf.LineColour(centre - 60, 488, centre + 60, 488, 1.2, Gold[0], Gold[1], Gold[2]);

            pdf.CentredText(centre, 444, 30, true, "Certificate of Internship Completion", Ink[0], Ink[1], Ink[2]);
            pdf.CentredText(centre, 408, 12, false, "This UIMS record certifies that", Muted[0], Muted[1], Muted[2]);
            pdf.CentredText(centre, 370, 26, true, d.StudentName, Navy[0], Navy[1], Navy[2]);
            pdf.Line(centre - 210, 360, centre + 210, 360, 0.6);
            pdf.CentredText(centre, 341, 11, false, "Student number " + d.StudentNumber + "  -  " + d.ProgramLine, Muted[0], Muted[1], Muted[2]);

            pdf.CentredText(centre, 304, 13, false, "has completed " + d.CompletedLine + " as");
            pdf.CentredText(centre, 284, 13, true, d.OpportunityTitle + "  at  " + d.CompanyName);
            pdf.CentredText(centre, 264, 13, false, "from " + LongDate(d.Start) + " to " + LongDate(d.End) + ", with a released result of " + Clean(record.Result) + ".");

            Stamp(pdf, centre, 172, record.ApprovedAt, 1);

            pdf.Line(96, 132, 316, 132, 0.6);
            pdf.CentredText(206, 116, 10, true, d.CoordinatorName);
            pdf.CentredText(206, 102, 8.5, false, "Approved in UIMS by the University Internship Coordinator", Muted[0], Muted[1], Muted[2]);

            pdf.Line(526, 132, 746, 132, 0.6);
            pdf.CentredText(636, 116, 10, true, LongDate(record.ApprovedAt));
            pdf.CentredText(636, 102, 8.5, false, "Date of approval  -  Reference " + Reference(record), Muted[0], Muted[1], Muted[2]);

            pdf.CentredText(centre, 58, 7.5, false,
                "UIMS-generated project record. It is not an official GJU certificate or transcript and carries no university seal or signature.",
                0.45, 0.5, 0.56);
            pdf.CentredText(centre, 46, 7.5, false, "Record " + Clean(record.Id) + "  -  " + Constants.UniversityWebsite, 0.45, 0.5, 0.56);

            return pdf.ToBytes("Internship Completion Certificate - " + d.StudentName);
        }

        /// <summary>Authorisation gate for card A16. Call this before serving
        /// any report file.</summary>
        public static bool MayDownload(CompletionRecord record, Models.Person requester)
        {
            if (record == null || requester == null) return false;
            if (requester.Role == Common.UserRole.Coordinator) return record.Status == CompletionStatus.Approved;
            return requester.Role == Common.UserRole.Student
                   && record.IsReleasedToStudent() && record.StudentId == requester.Id;
        }

        public static string Reference(CompletionRecord record)
        {
            string id = (record.Id ?? "").ToUpperInvariant();
            return "UIMS-" + (id.Length > 8 ? id.Substring(id.Length - 8) : id);
        }

        // ---- the static approval mark ---------------------------------------
        /// <summary>A circular "UIMS - APPROVED" status mark. Plain shapes and
        /// text only: not a seal, crest or signature.</summary>
        private static void Stamp(SimplePdf pdf, double cx, double cy, long approvedAt, double k)
        {
            const double angle = -9;
            double r = Green[0], g = Green[1], b = Green[2];
            pdf.Circle(cx, cy, 52 * k, 2.2 * k, r, g, b);
            pdf.Circle(cx, cy, 46 * k, 0.7, r, g, b);
            pdf.RotatedLine(cx, cy, -38 * k, 9 * k, 38 * k, 9 * k, angle, 0.7, r, g, b);
            pdf.RotatedLine(cx, cy, -38 * k, -10 * k, 38 * k, -10 * k, angle, 0.7, r, g, b);
            pdf.RotatedCentredText(cx, cy, 20 * k, 8 * k, true, "UIMS", angle, r, g, b);
            pdf.RotatedCentredText(cx, cy, -4.5 * k, 11.5 * k, true, "APPROVED", angle, r, g, b);
            pdf.RotatedCentredText(cx, cy, -26 * k, 6.5 * k, false, approvedAt > 0 ? ShortDate(approvedAt) : "COMPLETION", angle, r, g, b);
        }

        private static void Footer(SimplePdf pdf, double left, double right, CompletionRecord record)
        {
            pdf.Line(left, 66, right, 66, 0.5);
            pdf.Text(left, 52, 7.5, false,
                "UIMS-generated project record (reference " + Reference(record) + "). Not an official GJU transcript or certificate;",
                0.45, 0.5, 0.56);
            pdf.Text(left, 41, 7.5, false,
                "it carries no university seal or signature. Final confidential evaluation forms are not included.", 0.45, 0.5, 0.56);
        }

        /// <summary>Values printed on the documents: the approval snapshot
        /// first, live profile data only for records approved before snapshots existed.</summary>
        private class Details
        {
            public string StudentName, StudentNumber, ProgramLine, TypeLine, CompanyName, OpportunityTitle, CoordinatorName;
            public string VerifiedLine, CompletedLine;
            public long Start, End;
            public bool International;

            public static Details From(CompletionRecord r, Student s, Placement p, string coordinatorName)
            {
                Details d = new Details();
                d.StudentName = Clean(r.StudentName ?? s.FullName);
                d.StudentNumber = Clean(r.StudentNumber ?? s.StudentNumber);
                string programName = r.Program ?? s.Major;
                AcademicProgram program = AcademicPrograms.Find(programName);
                d.International = (r.InternshipType ?? InternshipTypes.Of(p)) == InternshipTypes.International;
                d.ProgramLine = program == null ? Clean(programName)
                    : program.Name + (d.International ? "" : "  (local training course " + program.LocalCourse + ")");
                d.TypeLine = d.International ? "International internship (German Year)" : "Local field training";
                d.CompanyName = Clean(r.CompanyName ?? p.CompanyName);
                d.OpportunityTitle = Clean(r.OpportunityTitle ?? p.OpportunityTitle);
                d.Start = r.TrainingStart > 0 ? r.TrainingStart : p.StartDate;
                d.End = r.TrainingEnd > 0 ? r.TrainingEnd : p.EndDate;
                d.CoordinatorName = Clean(r.CoordinatorName ?? coordinatorName ?? "Internship Coordinator");
                double weeks = d.Start > 0 && d.End > d.Start ? (d.End - d.Start) / (7.0 * 24 * 3600 * 1000) : 0;
                if (d.International)
                {
                    d.VerifiedLine = weeks > 0 ? weeks.ToString("0.#", CultureInfo.InvariantCulture) + " weeks (minimum "
                        + InternshipRules.InternationalMinimumWeeks + " weeks full time)" : "-";
                    d.CompletedLine = weeks > 0 ? weeks.ToString("0.#", CultureInfo.InvariantCulture) + " weeks of full-time internship" : "a full-time internship";
                }
                else
                {
                    d.VerifiedLine = r.ApprovedHours + " approved of " + r.RequiredHours + " required contact hours";
                    d.CompletedLine = r.ApprovedHours + " approved training hours";
                }
                return d;
            }
        }

        // ---- layout helpers ------------------------------------------------
        private static double Section(SimplePdf pdf, double x, double y, string title)
        {
            pdf.Text(x, y, 13, true, title, Navy[0], Navy[1], Navy[2]);
            pdf.LineColour(x, y - 6, x + 28, y - 6, 1.6, Gold[0], Gold[1], Gold[2]);
            return y - 26;
        }

        private static double Row(SimplePdf pdf, double x, double y, string label, string value)
        {
            pdf.Text(x, y, 10.5, false, label, Muted[0], Muted[1], Muted[2]);
            pdf.Text(x + 160, y, 11.5, false, Clean(value), Ink[0], Ink[1], Ink[2]);
            return y - 21;
        }

        /// <summary>Wrapped text. maxLines keeps long remarks from running into the footer.</summary>
        private static double Paragraph(SimplePdf pdf, double x, double y, double size, double width, string text, double[] colour, int maxLines = 0)
        {
            List<string> lines = SimplePdf.Wrap(text, size, width);
            if (maxLines > 0 && lines.Count > maxLines)
            {
                lines = lines.GetRange(0, maxLines);
                lines[maxLines - 1] = lines[maxLines - 1].TrimEnd() + " ...";
            }
            foreach (string line in lines)
            {
                pdf.Text(x, y, size, false, line, colour[0], colour[1], colour[2]);
                y -= size * 1.5;
            }
            return y;
        }

        private static string LongDate(long ms)
        {
            return ms > 0 ? Time.FromUnixMs(ms).ToLocalTime().ToString("d MMMM yyyy", CultureInfo.InvariantCulture) : "-";
        }

        private static string ShortDate(long ms)
        {
            return Time.FromUnixMs(ms).ToLocalTime().ToString("dd MMM yyyy", CultureInfo.InvariantCulture).ToUpperInvariant();
        }

        private static string Clean(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? "-" : value.Trim();
        }
    }

    /// <summary>
    /// A very small PDF writer: text in the built-in Helvetica fonts, lines,
    /// rectangles and circles. Enough for a one-page report, with no NuGet
    /// package. Coordinates are in points from the bottom-left of the page.
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

        /// <summary>Text centred on (cx, cy + offset) in a frame rotated by
        /// <paramref name="degrees"/> around (cx, cy).</summary>
        public void RotatedCentredText(double cx, double cy, double offsetY, double size, bool bold, string text,
                                       double degrees, double r, double g, double b)
        {
            double a = degrees * Math.PI / 180, cos = Math.Cos(a), sin = Math.Sin(a);
            double lx = -TextWidth(text, size, bold) / 2, ly = offsetY;
            double x = cx + lx * cos - ly * sin, y = cy + lx * sin + ly * cos;
            content.AppendFormat("BT {0} rg /{1} {2} Tf {3} {4} {5} {6} {7} {8} Tm ({9}) Tj ET\n",
                Colour(r, g, b), bold ? "F2" : "F1", N(size), N(cos), N(sin), N(-sin), N(cos), N(x), N(y), Escape(text));
        }

        public void Line(double x1, double y1, double x2, double y2, double lineWidth)
        {
            content.AppendFormat("0.6 0.65 0.7 RG {0} w {1} {2} m {3} {4} l S\n",
                N(lineWidth), N(x1), N(y1), N(x2), N(y2));
        }

        public void LineColour(double x1, double y1, double x2, double y2, double lineWidth, double r, double g, double b)
        {
            content.AppendFormat("{0} RG {1} w {2} {3} m {4} {5} l S\n",
                Colour(r, g, b), N(lineWidth), N(x1), N(y1), N(x2), N(y2));
        }

        /// <summary>A line given in a frame rotated around (cx, cy).</summary>
        public void RotatedLine(double cx, double cy, double x1, double y1, double x2, double y2,
                                double degrees, double lineWidth, double r, double g, double b)
        {
            double a = degrees * Math.PI / 180, cos = Math.Cos(a), sin = Math.Sin(a);
            LineColour(cx + x1 * cos - y1 * sin, cy + x1 * sin + y1 * cos,
                       cx + x2 * cos - y2 * sin, cy + x2 * sin + y2 * cos, lineWidth, r, g, b);
        }

        /// <summary>A stroked circle drawn with four Bezier curves.</summary>
        public void Circle(double cx, double cy, double radius, double lineWidth, double r, double g, double b)
        {
            double k = 0.5523 * radius;
            content.AppendFormat("{0} RG {1} w {2} {3} m ", Colour(r, g, b), N(lineWidth), N(cx + radius), N(cy));
            content.AppendFormat("{0} {1} {2} {3} {4} {5} c ", N(cx + radius), N(cy + k), N(cx + k), N(cy + radius), N(cx), N(cy + radius));
            content.AppendFormat("{0} {1} {2} {3} {4} {5} c ", N(cx - k), N(cy + radius), N(cx - radius), N(cy + k), N(cx - radius), N(cy));
            content.AppendFormat("{0} {1} {2} {3} {4} {5} c ", N(cx - radius), N(cy - k), N(cx - k), N(cy - radius), N(cx), N(cy - radius));
            content.AppendFormat("{0} {1} {2} {3} {4} {5} c S\n", N(cx + k), N(cy - radius), N(cx + radius), N(cy - k), N(cx + radius), N(cy));
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
