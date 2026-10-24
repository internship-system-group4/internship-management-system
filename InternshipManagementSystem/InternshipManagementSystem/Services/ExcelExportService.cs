// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Builds a real Excel workbook (.xlsx) with one sheet, using only the
//  built-in zip library. No NuGet package is needed.
//
//  An .xlsx file is a zip of small XML files. We write the minimum Excel
//  needs: the sheet, a bold header style, column widths and a frozen header.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.IO.Compression;
using System.Security;
using System.Text;

namespace InternshipManagementSystem.Services
{
    public static class ExcelExportService
    {
        public const string ContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";

        /// <summary>Builds the workbook. Each row value may be a string, a
        /// number (written as a real number cell) or null (empty cell).</summary>
        public static byte[] Build(string sheetName, string[] headers, List<object[]> rows, bool rightToLeft)
        {
            using (MemoryStream memory = new MemoryStream())
            {
                using (ZipArchive zip = new ZipArchive(memory, ZipArchiveMode.Create, true))
                {
                    Add(zip, "[Content_Types].xml",
                        "<Types xmlns=\"http://schemas.openxmlformats.org/package/2006/content-types\">"
                        + "<Default Extension=\"rels\" ContentType=\"application/vnd.openxmlformats-package.relationships+xml\"/>"
                        + "<Default Extension=\"xml\" ContentType=\"application/xml\"/>"
                        + "<Override PartName=\"/xl/workbook.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml\"/>"
                        + "<Override PartName=\"/xl/worksheets/sheet1.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml\"/>"
                        + "<Override PartName=\"/xl/styles.xml\" ContentType=\"application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml\"/>"
                        + "</Types>");

                    Add(zip, "_rels/.rels",
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                        + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument\" Target=\"xl/workbook.xml\"/>"
                        + "</Relationships>");

                    Add(zip, "xl/workbook.xml",
                        "<workbook xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\" xmlns:r=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships\">"
                        + "<sheets><sheet name=\"" + Escape(SafeSheetName(sheetName)) + "\" sheetId=\"1\" r:id=\"rId1\"/></sheets>"
                        + "</workbook>");

                    Add(zip, "xl/_rels/workbook.xml.rels",
                        "<Relationships xmlns=\"http://schemas.openxmlformats.org/package/2006/relationships\">"
                        + "<Relationship Id=\"rId1\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet\" Target=\"worksheets/sheet1.xml\"/>"
                        + "<Relationship Id=\"rId2\" Type=\"http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles\" Target=\"styles.xml\"/>"
                        + "</Relationships>");

                    // Style 0 = normal, style 1 = bold header with a light fill.
                    Add(zip, "xl/styles.xml",
                        "<styleSheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">"
                        + "<fonts count=\"2\"><font><sz val=\"11\"/><name val=\"Calibri\"/></font><font><b/><sz val=\"11\"/><name val=\"Calibri\"/></font></fonts>"
                        + "<fills count=\"3\"><fill><patternFill patternType=\"none\"/></fill><fill><patternFill patternType=\"gray125\"/></fill>"
                        + "<fill><patternFill patternType=\"solid\"><fgColor rgb=\"FFE7EEF7\"/><bgColor indexed=\"64\"/></patternFill></fill></fills>"
                        + "<borders count=\"1\"><border><left/><right/><top/><bottom/><diagonal/></border></borders>"
                        + "<cellStyleXfs count=\"1\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\"/></cellStyleXfs>"
                        + "<cellXfs count=\"2\"><xf numFmtId=\"0\" fontId=\"0\" fillId=\"0\" borderId=\"0\" xfId=\"0\"/>"
                        + "<xf numFmtId=\"0\" fontId=\"1\" fillId=\"2\" borderId=\"0\" xfId=\"0\" applyFont=\"1\" applyFill=\"1\"/></cellXfs>"
                        + "</styleSheet>");

                    Add(zip, "xl/worksheets/sheet1.xml", Sheet(headers, rows, rightToLeft));
                }
                return memory.ToArray();
            }
        }

        private static string Sheet(string[] headers, List<object[]> rows, bool rightToLeft)
        {
            StringBuilder xml = new StringBuilder();
            xml.Append("<worksheet xmlns=\"http://schemas.openxmlformats.org/spreadsheetml/2006/main\">");

            // Freeze the header row so it stays visible while scrolling.
            xml.Append("<sheetViews><sheetView workbookViewId=\"0\"" + (rightToLeft ? " rightToLeft=\"1\"" : "") + ">"
                + "<pane ySplit=\"1\" topLeftCell=\"A2\" activePane=\"bottomLeft\" state=\"frozen\"/></sheetView></sheetViews>");

            // Column width = longest text in that column (within limits).
            xml.Append("<cols>");
            for (int c = 0; c < headers.Length; c++)
            {
                int width = headers[c].Length;
                foreach (object[] row in rows)
                    if (c < row.Length && row[c] != null) width = Math.Max(width, Text(row[c]).Length);
                width = Math.Min(Math.Max(width + 2, 10), 50);
                xml.Append("<col min=\"" + (c + 1) + "\" max=\"" + (c + 1) + "\" width=\"" + width + "\" customWidth=\"1\"/>");
            }
            xml.Append("</cols><sheetData>");

            WriteRow(xml, 1, headers, 1);
            for (int r = 0; r < rows.Count; r++) WriteRow(xml, r + 2, rows[r], 0);

            xml.Append("</sheetData>");
            if (rows.Count > 0)
                xml.Append("<autoFilter ref=\"A1:" + Column(headers.Length - 1) + (rows.Count + 1) + "\"/>");
            xml.Append("</worksheet>");
            return xml.ToString();
        }

        private static void WriteRow(StringBuilder xml, int rowNumber, object[] values, int style)
        {
            xml.Append("<row r=\"" + rowNumber + "\">");
            for (int c = 0; c < values.Length; c++)
            {
                object value = values[c];
                if (value == null) continue;
                string cell = Column(c) + rowNumber;
                string styleAttr = style > 0 ? " s=\"" + style + "\"" : "";

                if (value is int || value is long || value is double || value is decimal)
                {
                    string number = Convert.ToDouble(value).ToString("0.##", CultureInfo.InvariantCulture);
                    xml.Append("<c r=\"" + cell + "\"" + styleAttr + "><v>" + number + "</v></c>");
                }
                else
                {
                    xml.Append("<c r=\"" + cell + "\" t=\"inlineStr\"" + styleAttr + "><is><t xml:space=\"preserve\">"
                        + Escape(Text(value)) + "</t></is></c>");
                }
            }
            xml.Append("</row>");
        }

        /// <summary>0 -> A, 25 -> Z, 26 -> AA.</summary>
        private static string Column(int index)
        {
            string name = "";
            index++;
            while (index > 0)
            {
                int rest = (index - 1) % 26;
                name = (char)('A' + rest) + name;
                index = (index - 1) / 26;
            }
            return name;
        }

        private static string Text(object value)
        {
            return Convert.ToString(value, CultureInfo.InvariantCulture) ?? "";
        }

        /// <summary>XML-escapes text and drops control characters Excel rejects.</summary>
        private static string Escape(string value)
        {
            StringBuilder clean = new StringBuilder();
            foreach (char ch in value ?? "")
                if (ch >= 0x20 || ch == '\t' || ch == '\n' || ch == '\r') clean.Append(ch);
            return SecurityElement.Escape(clean.ToString());
        }

        /// <summary>Excel sheet names: max 31 chars, none of : \ / ? * [ ].</summary>
        private static string SafeSheetName(string name)
        {
            string safe = string.IsNullOrWhiteSpace(name) ? "Sheet1" : name;
            foreach (char bad in new[] { ':', '\\', '/', '?', '*', '[', ']' }) safe = safe.Replace(bad, ' ');
            return safe.Length > 31 ? safe.Substring(0, 31) : safe;
        }

        private static void Add(ZipArchive zip, string path, string xml)
        {
            ZipArchiveEntry entry = zip.CreateEntry(path, CompressionLevel.Optimal);
            using (StreamWriter writer = new StreamWriter(entry.Open(), new UTF8Encoding(false)))
            {
                writer.Write("<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>");
                writer.Write(xml);
            }
        }
    }
}
