// =============================================================================
//  UIMS - Group 4
//  One set of rules for the Add Opportunity form (Company/Opportunities.aspx)
//  and the Edit Opportunity form (Company/ManageOpportunities.aspx?edit=...).
//  Every field is checked at once and each message is kept next to its field,
//  so the supervisor sees all problems together instead of one at a time.
//  Assets/js/opportunity-form.js repeats the same rules in the browser.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Collections.Specialized;
using System.Globalization;
using System.Linq;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Services
{
    public class OpportunityFormRules
    {
        public const int MaxSeats = 500;
        /// <summary>Every internship lasts exactly 3 months. The supervisor picks the
        /// start date and the end date is set for them.</summary>
        public const int TrainingMonths = 3;

        public string Title = "";
        public string Department = "";
        public string Location = "";
        public string Mode = "";
        public string Description = "";
        public string Requirements = "";
        public string Technologies = "";
        public List<string> Majors = new List<string>();
        public bool HasUnknownMajor;

        public int Seats;
        public bool HasSeats;
        public DateTime Deadline;
        public DateTime Start;
        public DateTime End;
        public bool HasDeadline;
        public bool HasStart;
        public bool HasEnd;

        /// <summary>Error message per field: Title, Department, Location, Majors,
        /// Description, Requirements, Technologies, Mode, Seats, Deadline, Start, End.</summary>
        public Dictionary<string, string> Errors = new Dictionary<string, string>();

        public bool IsValid { get { return Errors.Count == 0; } }

        /// <summary>3 months in whole weeks (about 13), saved for older pages that read weeks.</summary>
        public int DurationWeeks
        {
            get { return HasStart ? (int)Math.Round((End - Start).TotalDays / 7.0) : 0; }
        }

        /// <summary>The end date for a start date: exactly 3 months later.</summary>
        public static DateTime EndFor(DateTime start)
        {
            return start.Date.AddMonths(TrainingMonths);
        }

        /// <summary>Reads the posted form. Field names are prefix + name,
        /// for example "opTitle" on the Add page and "moTitle" on the Edit page.</summary>
        public static OpportunityFormRules Read(NameValueCollection form, string prefix, string[] allowedMajors)
        {
            var rules = new OpportunityFormRules();
            Func<string, string> text = name => (form[prefix + name] ?? "").Trim();

            rules.Title = text("Title");
            rules.Department = text("Department");
            rules.Location = text("Location");
            rules.Mode = text("Mode");
            rules.Description = text("Description");
            rules.Requirements = text("Requirements");
            rules.Technologies = text("Technologies");

            string[] posted = form.GetValues(prefix + "Majors") ?? new string[0];
            rules.Majors = posted.Where(m => allowedMajors.Contains(m)).Distinct().ToList();
            rules.HasUnknownMajor = posted.Any(m => !allowedMajors.Contains(m));

            rules.HasSeats = int.TryParse(text("Seats"), NumberStyles.None, CultureInfo.InvariantCulture, out rules.Seats);
            rules.HasDeadline = ReadDate(text("Deadline"), out rules.Deadline);
            rules.HasStart = ReadDate(text("Start"), out rules.Start);
            // The end date is never typed: it is always start + 3 months.
            rules.HasEnd = rules.HasStart;
            rules.End = rules.HasStart ? EndFor(rules.Start) : DateTime.MinValue;
            return rules;
        }

        /// <summary>Checks every field. A draft only needs a title; publishing or
        /// editing needs everything. The "not in the past" rule for the last date to
        /// apply is skipped when an edit keeps the date that was already saved.</summary>
        public void Check(bool complete, bool deadlineMustBeFuture, int filledSeats)
        {
            Errors.Clear();
            DateTime today = DateTime.Today;

            if (Title.Length < 3) Add("Title", "TitleRequired");
            if (Title.Length > 160) Add("Title", "TooLong");
            if (Department.Length > 120) Add("Department", "TooLong");
            if (Location.Length > 160) Add("Location", "TooLong");
            if (Description.Length > 5000) Add("Description", "TooLong");
            if (Requirements.Length > 3000) Add("Requirements", "TooLong");
            if (Technologies.Length > 1000) Add("Technologies", "TooLong");
            if (HasUnknownMajor) Add("Majors", "MajorsRequired");
            if (Mode != "On-site" && Mode != "Hybrid" && Mode != "Remote") Add("Mode", "ModeRequired");

            if (complete)
            {
                if (Department.Length == 0) Add("Department", "DepartmentRequired");
                if (Location.Length < 2) Add("Location", "LocationRequired");
                if (Majors.Count == 0) Add("Majors", "MajorsRequired");
                if (Description.Length < 20) Add("Description", "DescriptionRequired");
                if (Requirements.Length < 2) Add("Requirements", "RequirementsRequired");
                if (!HasSeats) Add("Seats", "SeatsInvalid");
                if (!HasDeadline) Add("Deadline", "DeadlineRequired");
                if (!HasStart) Add("Start", "StartRequired");
            }

            if (HasSeats && (Seats < 1 || Seats > MaxSeats)) Add("Seats", "SeatsInvalid");
            else if (HasSeats && Seats < filledSeats)
                AddText("Seats", L.F("Company.OpportunityForm.SeatsBelowFilled", filledSeats));

            if (HasDeadline && deadlineMustBeFuture && Deadline.Date < today)
                Add("Deadline", "DeadlinePast");

            // Order: last date to apply -> start -> end. Starting on the last day to apply is allowed.
            if (HasDeadline && HasStart && Start.Date < Deadline.Date)
                AddText("Start", L.F("Company.OpportunityForm.StartBeforeDeadline", Show(Deadline)));

        }

        /// <summary>The first message for a field, or "".</summary>
        public string ErrorFor(string field)
        {
            string message;
            return Errors.TryGetValue(field, out message) ? message : "";
        }

        /// <summary>Start of a day in Unix milliseconds (start and end dates).</summary>
        public static long DayStartMs(DateTime date)
        {
            return new DateTimeOffset(date.Date).ToUnixTimeMilliseconds();
        }

        /// <summary>Last moment of a day: students can still apply on the last date to apply.</summary>
        public static long DayEndMs(DateTime date)
        {
            return new DateTimeOffset(date.Date.AddDays(1)).ToUnixTimeMilliseconds() - 1;
        }

        /// <summary>yyyy-MM-dd for date inputs, or "" when there is no date.</summary>
        public static string DateText(long ms)
        {
            if (ms <= 0) return "";
            return DateTimeOffset.FromUnixTimeMilliseconds(ms).ToLocalTime().ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }

        /// <summary>How long an internship lasts, for display: "3 months" for every
        /// new posting (about 13 weeks), otherwise the number of weeks of older postings.</summary>
        public static string DurationLabel(int weeks)
        {
            if (weeks <= 0) return L.T("Shared.Duration.NotSpecified");
            if (weeks >= 12 && weeks <= 14) return L.T("Shared.Duration.ThreeMonths");
            return L.F("Shared.Duration.Weeks", weeks);
        }

        /// <summary>Messages for the browser checks in opportunity-form.js.</summary>
        public static Dictionary<string, string> ScriptMessages()
        {
            var keys = new[] { "TitleRequired", "DepartmentRequired", "LocationRequired", "MajorsRequired",
                "DescriptionRequired", "RequirementsRequired", "SeatsInvalid", "SeatsBelowFilled",
                "DeadlineRequired", "DeadlinePast", "StartRequired", "StartBeforeDeadline",
                "Duration", "FixErrors" };
            return keys.ToDictionary(k => k, k => L.T("Company.OpportunityForm." + k));
        }

        private static bool ReadDate(string value, out DateTime date)
        {
            return DateTime.TryParseExact(value, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, out date);
        }

        public static string Show(DateTime date)
        {
            return date.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
        }

        private void Add(string field, string key)
        {
            AddText(field, L.T("Company.OpportunityForm." + key));
        }

        private void AddText(string field, string message)
        {
            if (!Errors.ContainsKey(field)) Errors[field] = message;
        }
    }
}
