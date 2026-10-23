using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Text;
using System.Xml.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    // A native Open XML workbook. No Office installation or renamed HTML/CSV is needed.
    public static class ExcelExportService
    {
        private static readonly XNamespace Sheet = "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
        private static readonly XNamespace Relationships = "http://schemas.openxmlformats.org/package/2006/relationships";

        public static byte[] CreateGradesWorkbook(Person viewer, IList<GradeResultRow> rows, DateTime exportedAtUtc)
        {
            if (viewer == null || !viewer.IsActive ||
                (viewer.Role != UserRole.CompanySupervisor && viewer.Role != UserRole.AcademicSupervisor &&
                 viewer.Role != UserRole.Coordinator)) throw new UnauthorizedAccessException();
            bool showAcademic = viewer.Role != UserRole.CompanySupervisor;
            List<string> headers = new List<string> { "Student number", "Student name", "Company", "Placement status",
                "Graded tasks", "Assigned tasks", "Approved hours", "Task grade", "Company grade" };
            if (showAcademic) headers.Add("Academic grade");
            headers.AddRange(new[] { "Final grade", "Review status", "Result" });
            List<IList<object>> data = rows.Select(row =>
            {
                List<object> cells = new List<object> { row.StudentNumber, row.StudentName, row.CompanyName,
                    row.PlacementStatus, row.GradedTasks, row.AssignedTasks, row.ApprovedHours,
                    PercentCell(row.TaskPercent), PercentCell(row.CompanyPercent) };
                if (showAcademic) cells.Add(PercentCell(row.AcademicPercent));
                cells.AddRange(new[] { PercentCell(row.FinalPercent), row.ReviewStatus, row.Result });
                return (IList<object>)cells;
            }).ToList();
            List<IList<object>> notes = new List<IList<object>>
            {
                new object[] { "Exported at (UTC)", exportedAtUtc.ToUniversalTime().ToString("yyyy-MM-dd HH:mm:ss 'UTC'", CultureInfo.InvariantCulture) },
                new object[] { "Portal", viewer.RoleDisplayName },
                new object[] { "Students exported", rows.Count },
                new object[] { "Confidentiality", "For authorized supervisors and coordinators. Store this workbook securely." },
                new object[] { "Scope", viewer.Role == UserRole.Coordinator ? "All confirmed internships, excluding cancelled placements." :
                    "Only internships assigned to the signed-in supervisor." },
                new object[] { "Pending grades", "Missing, draft, invalid, revision-requested or outdated grades are Pending, not zero." },
                new object[] { "Task grade", "Available when every assigned task has a valid evaluation of its latest submission." },
                new object[] { "Final grade and result", "Only coordinator-approved results are included. Approved grades use the saved completion record." },
                new object[] { "Policy", "Current project weights and pass threshold are provisional; this export does not approve or release results." },
                new object[] { "Percentages", "Grades are numeric percentage cells and can be sorted or used in Excel calculations." }
            };
            using (MemoryStream stream = new MemoryStream())
            {
                using (ZipArchive archive = new ZipArchive(stream, ZipArchiveMode.Create, true))
                {
                    XNamespace types = "http://schemas.openxmlformats.org/package/2006/content-types";
                    Write(archive, "[Content_Types].xml", new XDocument(new XElement(types + "Types",
                        new XElement(types + "Default", new XAttribute("Extension", "rels"), new XAttribute("ContentType", "application/vnd.openxmlformats-package.relationships+xml")),
                        new XElement(types + "Default", new XAttribute("Extension", "xml"), new XAttribute("ContentType", "application/xml")),
                        Override(types, "/xl/workbook.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"),
                        Override(types, "/xl/styles.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"),
                        Override(types, "/xl/worksheets/sheet1.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"),
                        Override(types, "/xl/worksheets/sheet2.xml", "application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"))));
                    Write(archive, "_rels/.rels", new XDocument(new XElement(Relationships + "Relationships",
                        Relation("rId1", "officeDocument", "xl/workbook.xml"))));
                    XNamespace rel = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
                    Write(archive, "xl/workbook.xml", new XDocument(new XElement(Sheet + "workbook",
                        new XAttribute(XNamespace.Xmlns + "r", rel), new XElement(Sheet + "sheets",
                            new XElement(Sheet + "sheet", new XAttribute("name", "Grades & Results"), new XAttribute("sheetId", 1), new XAttribute(rel + "id", "rId1")),
                            new XElement(Sheet + "sheet", new XAttribute("name", "Export information"), new XAttribute("sheetId", 2), new XAttribute(rel + "id", "rId2"))))));
                    Write(archive, "xl/_rels/workbook.xml.rels", new XDocument(new XElement(Relationships + "Relationships",
                        Relation("rId1", "worksheet", "worksheets/sheet1.xml"), Relation("rId2", "worksheet", "worksheets/sheet2.xml"),
                        Relation("rId3", "styles", "styles.xml"))));
                    Write(archive, "xl/styles.xml", Styles());
                    Write(archive, "xl/worksheets/sheet1.xml", Worksheet(headers, data, false));
                    Write(archive, "xl/worksheets/sheet2.xml", Worksheet(new[] { "Export information", "Details" }, notes, true));
                }
                return stream.ToArray();
            }
        }

        private static object PercentCell(double? value)
        { return value.HasValue && !double.IsNaN(value.Value) && !double.IsInfinity(value.Value) &&
            value.Value >= 0 && value.Value <= 100 ? (object)(value.Value / 100.0) : "Pending"; }

        private static XDocument Worksheet(IList<string> headers, IList<IList<object>> rows, bool notes)
        {
            XElement data = new XElement(Sheet + "sheetData");
            data.Add(new XElement(Sheet + "row", new XAttribute("r", 1), new XAttribute("ht", 30), new XAttribute("customHeight", 1),
                headers.Select((h, i) => Cell(Column(i) + "1", h, 1))));
            for (int i = 0; i < rows.Count; i++)
            {
                int number = i + 2;
                data.Add(new XElement(Sheet + "row", new XAttribute("r", number), new XAttribute("ht", notes ? 44 : 25),
                    new XAttribute("customHeight", 1), rows[i].Select((value, column) => Cell(Column(column) + number,
                        value, value is double ? 2 : 0))));
            }
            XElement sheet = new XElement(Sheet + "worksheet",
                new XElement(Sheet + "dimension", new XAttribute("ref", "A1:" + Column(headers.Count - 1) + (rows.Count + 1))),
                new XElement(Sheet + "sheetViews", new XElement(Sheet + "sheetView", new XAttribute("workbookViewId", 0),
                    new XElement(Sheet + "pane", new XAttribute("ySplit", 1), new XAttribute("topLeftCell", "A2"),
                        new XAttribute("activePane", "bottomLeft"), new XAttribute("state", "frozen")))),
                new XElement(Sheet + "cols", headers.Select((h, i) => new XElement(Sheet + "col",
                    new XAttribute("min", i + 1), new XAttribute("max", i + 1),
                    new XAttribute("width", notes ? (i == 0 ? 27 : 105) : (i == 1 || i == 2 ? 28 : 21)),
                    new XAttribute("customWidth", 1)))), data);
            if (!notes) sheet.Add(new XElement(Sheet + "autoFilter", new XAttribute("ref", "A1:" + Column(headers.Count - 1) + (rows.Count + 1))));
            return new XDocument(sheet);
        }

        private static XElement Cell(string address, object value, int style)
        {
            XElement cell = new XElement(Sheet + "c", new XAttribute("r", address), new XAttribute("s", style));
            if (value is double || value is int)
                cell.Add(new XElement(Sheet + "v", Convert.ToString(value, CultureInfo.InvariantCulture)));
            else
            {
                // Inline text preserves student numbers, Unicode, and formula-like user input as text.
                cell.Add(new XAttribute("t", "inlineStr"), new XElement(Sheet + "is",
                    new XElement(Sheet + "t", new XAttribute(XNamespace.Xml + "space", "preserve"), CleanText(value as string))));
            }
            return cell;
        }

        private static string CleanText(string text)
        {
            StringBuilder result = new StringBuilder();
            text = text ?? "";
            for (int i = 0; i < text.Length && result.Length < 32767; i++)
            {
                char character = text[i];
                if (System.Xml.XmlConvert.IsXmlChar(character)) result.Append(character);
                else if (char.IsHighSurrogate(character) && i + 1 < text.Length &&
                         char.IsLowSurrogate(text[i + 1]) && result.Length < 32766)
                { result.Append(character).Append(text[++i]); }
            }
            return result.ToString();
        }

        private static string Column(int index)
        {
            string result = "";
            do { result = (char)('A' + index % 26) + result; index = index / 26 - 1; } while (index >= 0);
            return result;
        }
        private static XElement Override(XNamespace ns, string name, string type)
        { return new XElement(ns + "Override", new XAttribute("PartName", name), new XAttribute("ContentType", type)); }
        private static XElement Relation(string id, string type, string target)
        { return new XElement(Relationships + "Relationship", new XAttribute("Id", id), new XAttribute("Type", "http://schemas.openxmlformats.org/officeDocument/2006/relationships/" + type), new XAttribute("Target", target)); }
        private static void Write(ZipArchive archive, string path, XDocument document)
        { using (Stream entry = archive.CreateEntry(path).Open()) document.Save(entry); }

        private static XDocument Styles()
        {
            return XDocument.Parse(@"<styleSheet xmlns='http://schemas.openxmlformats.org/spreadsheetml/2006/main'>
                <fonts count='2'><font><sz val='11'/><color rgb='FF1D2733'/><name val='Calibri'/></font><font><b/><sz val='11'/><color rgb='FFFFFFFF'/><name val='Calibri'/></font></fonts>
                <fills count='3'><fill><patternFill patternType='none'/></fill><fill><patternFill patternType='gray125'/></fill><fill><patternFill patternType='solid'><fgColor rgb='FF0F4C81'/><bgColor indexed='64'/></patternFill></fill></fills>
                <borders count='1'><border><left/><right/><top/><bottom/><diagonal/></border></borders>
                <cellStyleXfs count='1'><xf numFmtId='0' fontId='0' fillId='0' borderId='0'/></cellStyleXfs>
                <cellXfs count='3'><xf numFmtId='0' fontId='0' fillId='0' borderId='0' xfId='0' applyAlignment='1'><alignment vertical='center' wrapText='1'/></xf><xf numFmtId='0' fontId='1' fillId='2' borderId='0' xfId='0' applyFont='1' applyFill='1' applyAlignment='1'><alignment vertical='center' wrapText='1'/></xf><xf numFmtId='10' fontId='0' fillId='0' borderId='0' xfId='0' applyNumberFormat='1' applyAlignment='1'><alignment vertical='center'/></xf></cellXfs>
                <cellStyles count='1'><cellStyle name='Normal' xfId='0' builtinId='0'/></cellStyles>
            </styleSheet>");
        }
    }
}
