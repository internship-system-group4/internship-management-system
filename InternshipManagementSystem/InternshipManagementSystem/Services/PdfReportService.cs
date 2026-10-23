using System;
using System.Collections.Generic;
using System.Drawing;
using System.Drawing.Imaging;
using System.Drawing.Text;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    /// <summary>
    /// Creates the two approved documents on demand. The URLs stored on the
    /// completion record point to role-protected pages that check approval
    /// again before returning application/pdf; no public file URL is needed.
    /// </summary>
    public static class PdfReportService
    {
        public const string StudentReportPath = "~/Pages/Student/Progress.aspx?report=1";

        public static string ReportUrl(string id) { return "~/Pages/Account/CompletionReport.aspx?id=" + Uri.EscapeDataString(id ?? ""); }
        public static string CertificateUrl(string id) { return ReportUrl(id) + "&doc=certificate"; }
        public static string Reference(CompletionRecord record) { return record == null ? "" : (record.Id ?? record.PlacementId ?? ""); }
        public static byte[] GenerateCompletionReport(CompletionRecord record, Student student, Placement placement, string coordinatorName)
        { return CreateCompletionReportPdf(record, student, placement); }
        public static byte[] GenerateCertificate(CompletionRecord record, Student student, Placement placement, string coordinatorName)
        { return CreateCertificatePdf(record, student, placement); }

        public static string GenerateCompletionReport(CompletionRecord record, Student student)
        {
            return IsApprovedFor(record, student) ? StudentReportPath : null;
        }

        public static string GenerateCertificate(CompletionRecord record, Student student)
        {
            return IsApprovedFor(record, student)
                ? "~/Pages/Coordinator/CompletionReview.aspx?certificate=" + Uri.EscapeDataString(student.Id)
                : null;
        }

        public static bool MayDownload(CompletionRecord record, Person requester)
        {
            if (record == null || requester == null || record.Status != CompletionStatus.Approved)
                return false;
            if (requester.Role == UserRole.Coordinator) return true;
            return requester.Role == UserRole.Student && record.IsReleasedToStudent() &&
                   record.StudentId == requester.Id;
        }

        public static byte[] CreateCompletionReportPdf(CompletionRecord record, Student student,
                                                        Placement placement)
        {
            if (!IsApprovedFor(record, student) || placement == null ||
                placement.Id != record.PlacementId || placement.StudentId != student.Id)
                throw new InvalidOperationException("An approved completion is required for the report.");
            return DrawDocument(record, student, placement, false);
        }

        public static byte[] CreateCertificatePdf(CompletionRecord record, Student student,
                                                   Placement placement)
        {
            if (!IsApprovedFor(record, student) || placement == null ||
                placement.Id != record.PlacementId || placement.StudentId != student.Id)
                throw new InvalidOperationException("An approved completion is required for the certificate.");
            return DrawDocument(record, student, placement, true);
        }

        private static bool IsApprovedFor(CompletionRecord record, Student student)
        {
            return record != null && student != null && record.Status == CompletionStatus.Approved &&
                   record.StudentId == student.Id && !string.IsNullOrEmpty(record.PlacementId);
        }

        private static byte[] DrawDocument(CompletionRecord record, Student student,
                                           Placement placement, bool certificate)
        {
            // Approved PDFs must not change when a profile or placement is edited later.
            if (record.DocumentSnapshot != null)
            {
                var snapshot = record.DocumentSnapshot;
                student = new Student { FullName = snapshot.StudentName, StudentNumber = snapshot.StudentNumber, Major = snapshot.Program };
                placement = new Placement { CompanyName = snapshot.CompanyName, StartDate = snapshot.StartDate, EndDate = snapshot.EndDate };
            }
            const int width = 1654;
            const int height = 2339;
            Color navy = Color.FromArgb(15, 76, 129);
            Color ink = Color.FromArgb(29, 39, 51);
            Color muted = Color.FromArgb(89, 101, 115);
            using (Bitmap page = new Bitmap(width, height, PixelFormat.Format24bppRgb))
            using (Graphics g = Graphics.FromImage(page))
            using (Font universityFont = new Font("Arial", 37, FontStyle.Bold, GraphicsUnit.Pixel))
            using (Font titleFont = new Font("Arial", 52, FontStyle.Bold, GraphicsUnit.Pixel))
            using (Font sectionFont = new Font("Arial", 34, FontStyle.Bold, GraphicsUnit.Pixel))
            using (Font bodyFont = new Font("Arial", 31, FontStyle.Regular, GraphicsUnit.Pixel))
            using (Font labelFont = new Font("Arial", 25, FontStyle.Regular, GraphicsUnit.Pixel))
            using (Font resultFont = new Font("Arial", 74, FontStyle.Bold, GraphicsUnit.Pixel))
            using (SolidBrush navyBrush = new SolidBrush(navy))
            using (SolidBrush inkBrush = new SolidBrush(ink))
            using (SolidBrush mutedBrush = new SolidBrush(muted))
            using (Pen divider = new Pen(Color.FromArgb(215, 225, 234), 2))
            {
                g.Clear(Color.White);
                g.TextRenderingHint = TextRenderingHint.AntiAliasGridFit;
                g.FillRectangle(navyBrush, 0, 0, width, 22);
                Draw(g, Constants.UniversityName, universityFont, navyBrush, 120, 100, 1400, 58);
                Draw(g, Constants.CollegeName + "  |  University Internship Management System",
                    labelFont, mutedBrush, 120, 162, 1400, 44);
                g.DrawLine(divider, 120, 230, width - 120, 230);

                Draw(g, certificate ? "INTERNSHIP COMPLETION CERTIFICATE" :
                    "INTERNSHIP COMPLETION REPORT", titleFont, inkBrush, 120, 310, 1410, 82);
                Draw(g, "Coordinator-approved digital record", bodyFont, mutedBrush, 120, 404, 1410, 55);

                if (certificate)
                {
                    Draw(g, "This certifies that the student named below completed the internship",
                        bodyFont, inkBrush, 120, 600, 1410, 52);
                    Draw(g, "recorded in the University Internship Management System.",
                        bodyFont, inkBrush, 120, 653, 1410, 52);
                }

                int fieldsY = certificate ? 790 : 560;
                DrawField(g, "STUDENT", student.FullName, labelFont, bodyFont, mutedBrush, inkBrush,
                    120, fieldsY, 1410);
                DrawField(g, "STUDENT NUMBER", student.StudentNumber, labelFont, bodyFont,
                    mutedBrush, inkBrush, 120, fieldsY + 128, 640);
                DrawField(g, "PROGRAM", student.Major, labelFont, bodyFont,
                    mutedBrush, inkBrush, 820, fieldsY + 128, 710);
                DrawField(g, "COMPANY", placement.CompanyName, labelFont, bodyFont,
                    mutedBrush, inkBrush, 120, fieldsY + 256, 1410);
                DrawField(g, "TRAINING PERIOD", Time.DisplayDate(placement.StartDate) + " to " +
                    Time.DisplayDate(placement.EndDate), labelFont, bodyFont, mutedBrush, inkBrush,
                    120, fieldsY + 384, 820);
                DrawField(g, "APPROVED HOURS", record.ApprovedHours.ToString(CultureInfo.InvariantCulture) +
                    " / " + record.RequiredHours.ToString(CultureInfo.InvariantCulture),
                    labelFont, bodyFont, mutedBrush, inkBrush, 1010, fieldsY + 384, 520);

                int resultY = certificate ? 1450 : 1260;
                g.DrawLine(divider, 120, resultY - 45, width - 120, resultY - 45);
                Draw(g, "APPROVED COMPLETION", sectionFont, navyBrush, 120, resultY, 1410, 55);
                Draw(g, record.Result == "Pass" ? "PASS" : record.Result == "Fail" ? "FAIL" :
                    record.Result == "Completed" ? "COMPLETED" : "RESULT NOT RECORDED", resultFont, navyBrush,
                    120, resultY + 85, 1410, 110);
                Draw(g, "Approved in UIMS by the coordinator on " +
                    Time.DisplayDate(record.ApprovedAt) + ".", bodyFont, inkBrush,
                    120, resultY + 235, 1410, 62);

                int noteY = certificate ? 1930 : 1810;
                g.DrawLine(divider, 120, noteY - 40, width - 120, noteY - 40);
                Draw(g, "Record ID: " + First(record.Id, record.PlacementId), labelFont,
                    mutedBrush, 120, noteY, 1410, 45);
                Draw(g, "Generated from the coordinator-approved system record. The university",
                    labelFont, mutedBrush, 120, noteY + 55, 1410, 43);
                Draw(g, "transcript and any required signed forms remain authoritative.",
                    labelFont, mutedBrush, 120, noteY + 96, 1410, 43);
                g.FillRectangle(navyBrush, 0, height - 22, width, 22);

                using (MemoryStream jpeg = new MemoryStream())
                {
                    page.Save(jpeg, ImageFormat.Jpeg);
                    return WrapJpegAsPdf(jpeg.ToArray(), width, height);
                }
            }
        }

        private static void DrawField(Graphics g, string label, string value, Font labelFont,
                                      Font valueFont, Brush labelBrush, Brush valueBrush,
                                      int x, int y, int width)
        {
            Draw(g, label, labelFont, labelBrush, x, y, width, 40);
            Draw(g, First(value, "Not recorded"), valueFont, valueBrush, x, y + 43, width, 75);
        }

        private static void Draw(Graphics g, string value, Font font, Brush brush,
                                 int x, int y, int width, int height)
        {
            using (StringFormat format = new StringFormat())
            {
                format.Trimming = StringTrimming.EllipsisWord;
                format.FormatFlags = StringFormatFlags.LineLimit;
                g.DrawString(value ?? "", font, brush, new RectangleF(x, y, width, height), format);
            }
        }

        private static string First(string value, string fallback)
        {
            return string.IsNullOrWhiteSpace(value) ? fallback : value;
        }

        // A single JPEG page in a standards-compliant PDF container. Rendering
        // through GDI+ retains non-Latin student names without a PDF font package.
        private static byte[] WrapJpegAsPdf(byte[] jpeg, int width, int height)
        {
            using (MemoryStream output = new MemoryStream())
            {
                List<long> offsets = new List<long> { 0 };
                Write(output, "%PDF-1.4\n");
                AddObject(output, offsets, "<< /Type /Catalog /Pages 2 0 R >>");
                AddObject(output, offsets, "<< /Type /Pages /Kids [3 0 R] /Count 1 >>");
                AddObject(output, offsets, "<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] " +
                    "/Resources << /XObject << /Im0 4 0 R >> >> /Contents 5 0 R >>");
                offsets.Add(output.Position);
                Write(output, "4 0 obj\n<< /Type /XObject /Subtype /Image /Width " + width +
                    " /Height " + height + " /ColorSpace /DeviceRGB /BitsPerComponent 8 " +
                    "/Filter /DCTDecode /Length " + jpeg.Length + " >>\nstream\n");
                output.Write(jpeg, 0, jpeg.Length);
                Write(output, "\nendstream\nendobj\n");
                byte[] commands = Encoding.ASCII.GetBytes("q\n595 0 0 842 0 0 cm\n/Im0 Do\nQ\n");
                offsets.Add(output.Position);
                Write(output, "5 0 obj\n<< /Length " + commands.Length + " >>\nstream\n");
                output.Write(commands, 0, commands.Length);
                Write(output, "endstream\nendobj\n");

                long xref = output.Position;
                Write(output, "xref\n0 6\n0000000000 65535 f \n");
                foreach (long offset in offsets.Skip(1))
                    Write(output, offset.ToString("D10", CultureInfo.InvariantCulture) + " 00000 n \n");
                Write(output, "trailer\n<< /Size 6 /Root 1 0 R >>\nstartxref\n" +
                    xref.ToString(CultureInfo.InvariantCulture) + "\n%%EOF\n");
                return output.ToArray();
            }
        }

        private static void AddObject(Stream output, List<long> offsets, string body)
        {
            int number = offsets.Count;
            offsets.Add(output.Position);
            Write(output, number.ToString(CultureInfo.InvariantCulture) + " 0 obj\n" + body + "\nendobj\n");
        }

        private static void Write(Stream output, string text)
        {
            byte[] bytes = Encoding.ASCII.GetBytes(text);
            output.Write(bytes, 0, bytes.Length);
        }
    }
}
