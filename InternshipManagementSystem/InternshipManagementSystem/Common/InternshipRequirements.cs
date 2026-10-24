// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  School of Computing programmes, internship types and the requirements the
//  coordinator checks before approving completion.
//
//  Every rule below carries a Source so the interface never presents a project
//  proposal as official GJU policy. Sources were checked on 2026-10-23:
//    - Local training:  https://gju.edu.jo/content/local-training-14477
//    - CS FAQ:          https://gju.edu.jo/content/faqs-14846
//    - Programmes:      https://www.gju.edu.jo/content/undergraduate-programs-3413
//    - German Year:     https://www.gju.edu.jo/content/about-german-year-14761
//    - Internship sem.: https://www.gju.edu.jo/content/internship-semester-15909
//    - MyGJU workflow:  https://www.gju.edu.jo/ar/news/12303 (24 Feb 2021)
//  See docs/35-progress-and-completion-review.md for the full comparison.
// =============================================================================

using System;
using System.Collections.Generic;
using System.Linq;

namespace InternshipManagementSystem.Common
{
    /// <summary>Where a rule comes from. Shown next to the rule in the UI.</summary>
    public enum RuleSource
    {
        /// <summary>Published on an official GJU page (see the header).</summary>
        VerifiedGju = 0,
        /// <summary>Required by the UIMS project brief.</summary>
        ProjectBrief = 1,
        /// <summary>A project choice, not verified as university policy.</summary>
        ProjectProposal = 2,
        /// <summary>Official pages disagree; the coordinator checks it manually.</summary>
        Unresolved = 3
    }

    /// <summary>A School of Computing undergraduate programme.</summary>
    public class AcademicProgram
    {
        public string Key;            // stable id used in URLs: cs, ce, gdmi
        public string Name;           // canonical English name from gju.edu.jo
        public string LocalCourse;    // local field training course code
        public string[] Aliases;      // other spellings already seen in records
    }

    /// <summary>Result of reading a student's free-text Major field.</summary>
    public enum MajorQuality { Recognized = 0, Missing = 1, Unrecognized = 2 }

    public static class AcademicPrograms
    {
        public const string MissingKey = "missing";
        public const string UnrecognizedKey = "unverified";

        /// <summary>The three verified SC programmes. Course codes come from the
        /// local training page (CE391, CS391, DMI3900).</summary>
        public static readonly AcademicProgram[] All =
        {
            new AcademicProgram { Key = "cs", Name = "Computer Science", LocalCourse = "CS391",
                Aliases = new[] { "CS", "Computer Science (CS)", "BSc Computer Science", "B.Sc. Computer Science" } },
            new AcademicProgram { Key = "ce", Name = "Computer Engineering", LocalCourse = "CE391",
                Aliases = new[] { "CE", "Computer Engineering (CE)", "BSc Computer Engineering", "B.Sc. Computer Engineering" } },
            new AcademicProgram { Key = "gdmi", Name = "Game Design and Media Informatics", LocalCourse = "DMI3900",
                Aliases = new[] { "GDMI", "Game Design & Media Informatics", "Game Design and Media Informatics (GDMI)" } }
        };

        /// <summary>Matches a stored Major to a programme. Case, extra spaces and
        /// "&amp;"/"and" differences are ignored; anything else is NOT guessed.
        /// The stored value is never changed.</summary>
        public static AcademicProgram Find(string major)
        {
            string value = Normalise(major);
            if (value.Length == 0) return null;
            foreach (AcademicProgram program in All)
            {
                if (Normalise(program.Name) == value || Normalise(program.Key) == value) return program;
                if (program.Aliases.Any(a => Normalise(a) == value)) return program;
            }
            return null;
        }

        public static AcademicProgram ByKey(string key)
        {
            return All.FirstOrDefault(p => string.Equals(p.Key, key, StringComparison.OrdinalIgnoreCase));
        }

        public static MajorQuality Quality(string major)
        {
            if (Normalise(major).Length == 0) return MajorQuality.Missing;
            return Find(major) == null ? MajorQuality.Unrecognized : MajorQuality.Recognized;
        }

        /// <summary>Placeholder text such as "......" or "-" counts as missing
        /// letters, so it is reported as unrecognised rather than a programme.</summary>
        private static string Normalise(string value)
        {
            if (string.IsNullOrWhiteSpace(value)) return "";
            string text = value.Trim().ToLowerInvariant().Replace("&", " and ");
            return string.Join(" ", text.Split(new[] { ' ', '\t', '\r', '\n' }, StringSplitOptions.RemoveEmptyEntries));
        }
    }

    /// <summary>Internship types stored on Placement.InternshipType.</summary>
    public static class InternshipTypes
    {
        public const string Local = "Local";
        public const string International = "International";

        /// <summary>Placements created before this field existed have no
        /// value. UIMS opportunities are Jordanian companies, so the default
        /// is local training; the page labels it as a default.</summary>
        public static string Of(Models.Placement placement)
        {
            if (placement != null && string.Equals(placement.InternshipType, International, StringComparison.OrdinalIgnoreCase))
                return International;
            return Local;
        }

        public static bool IsSet(Models.Placement placement)
        {
            return placement != null && !string.IsNullOrWhiteSpace(placement.InternshipType);
        }

        public static bool IsValid(string value)
        {
            return value == Local || value == International;
        }
    }

    /// <summary>One requirement on the completion checklist.</summary>
    public class RequirementDefinition
    {
        public string Key;
        public string TitleKey;       // resource id, e.g. Coordinator.Req.PriorApproval
        public string HintKey;        // resource id describing what to check
        public RuleSource Source;
        public bool Manual;           // true: the coordinator records the evidence
        public bool Mandatory = true;
        public bool StudentVisible = true;
    }

    public static class InternshipRules
    {
        // ---- verified numbers ---------------------------------------------
        /// <summary>Local field training: 160 contact hours (verified).</summary>
        public const int LocalContactHours = 160;

        /// <summary>German Year internship: at least 20 weeks full time (verified).</summary>
        public const int InternationalMinimumWeeks = 20;

        // Automatic checks, computed from Firebase data.
        public const string KeyCompanyEvaluation = "company-evaluation";
        public const string KeyAcademicEvaluation = "academic-evaluation";
        public const string KeyHours = "hours";
        public const string KeyDuration = "duration";
        public const string KeyTasks = "tasks";
        public const string KeyResult = "result";

        /// <summary>Checks the coordinator verifies by hand, per internship type.
        /// Keys are stored in CompletionRecord.Checks, so never rename one.</summary>
        public static List<RequirementDefinition> ManualChecks(string internshipType)
        {
            List<RequirementDefinition> list = new List<RequirementDefinition>();
            if (internshipType == InternshipTypes.International)
            {
                list.Add(Manual("contract-approval", "PriorContract", RuleSource.VerifiedGju));
                list.Add(Manual("full-time", "FullTime", RuleSource.VerifiedGju));
                list.Add(Manual("local-training-done", "LocalTrainingDone", RuleSource.VerifiedGju));
                list.Add(Manual("certificate", "Certificate", RuleSource.VerifiedGju));
                list.Add(Manual("report", "InternationalReport", RuleSource.VerifiedGju));
                list.Add(Manual("faculty-validation", "FacultyValidation", RuleSource.VerifiedGju));
                return list;
            }

            list.Add(Manual("prior-approval", "PriorApproval", RuleSource.VerifiedGju));
            list.Add(Manual("prerequisites", "Prerequisites", RuleSource.Unresolved));
            list.Add(Manual("major-relevance", "MajorRelevance", RuleSource.VerifiedGju));
            list.Add(Manual("schedule", "Schedule", RuleSource.Unresolved));
            list.Add(Manual("company-eligibility", "CompanyEligibility", RuleSource.VerifiedGju));
            list.Add(Manual("training-forms", "TrainingForms", RuleSource.VerifiedGju));
            list.Add(Manual("training-report", "TrainingReport", RuleSource.VerifiedGju));
            list.Add(Manual("endorsement", "Endorsement", RuleSource.VerifiedGju));
            return list;
        }

        public static RequirementDefinition FindManual(string internshipType, string key)
        {
            return ManualChecks(internshipType).FirstOrDefault(d => d.Key == key);
        }

        private static RequirementDefinition Manual(string key, string name, RuleSource source)
        {
            return new RequirementDefinition
            {
                Key = key, Manual = true, Source = source,
                TitleKey = "Coordinator.Req." + name, HintKey = "Coordinator.Req." + name + "Hint"
            };
        }

        public static string SourceKey(RuleSource source)
        {
            switch (source)
            {
                case RuleSource.VerifiedGju: return "Coordinator.Req.SourceVerified";
                case RuleSource.ProjectBrief: return "Coordinator.Req.SourceBrief";
                case RuleSource.Unresolved: return "Coordinator.Req.SourceUnresolved";
                default: return "Coordinator.Req.SourceProposal";
            }
        }

        public static string SourceCss(RuleSource source)
        {
            switch (source)
            {
                case RuleSource.VerifiedGju: return "is-verified";
                case RuleSource.ProjectBrief: return "is-brief";
                case RuleSource.Unresolved: return "is-unresolved";
                default: return "is-proposal";
            }
        }

        /// <summary>Whole weeks between the placement's start and end dates.</summary>
        public static double Weeks(Models.Placement placement)
        {
            if (placement == null || placement.StartDate <= 0 || placement.EndDate <= placement.StartDate) return 0;
            return (placement.EndDate - placement.StartDate) / (7.0 * 24 * 60 * 60 * 1000);
        }

        /// <summary>The hours a local internship needs. A stored target can be
        /// higher than 160, but never lower: an old or mistyped value such as 40
        /// must not let a student finish early.</summary>
        public static int RequiredHours(int placementHours, int studentHours)
        {
            int configured = placementHours > 0 ? placementHours : studentHours;
            return Math.Max(LocalContactHours, configured);
        }

        /// <summary>True when the training part is done: 160+ approved hours for a
        /// local internship, or 20+ weeks for an international one.</summary>
        public static bool TrainingDone(Models.Placement placement, long approvedHours, int requiredHours)
        {
            if (placement == null) return false;
            if (InternshipTypes.Of(placement) == InternshipTypes.International)
                return Weeks(placement) >= InternationalMinimumWeeks;
            return approvedHours >= requiredHours;
        }
    }

    /// <summary>
    /// The evaluation method used to calculate the provisional result. The
    /// weights live in GradingPolicy.cs and are a PROJECT PROPOSAL: GJU has not
    /// published internship component weights. The id is stored on every
    /// decision so a later change of method is traceable.
    /// </summary>
    public static class EvaluationMethod
    {
        public const string Id = "UIMS-PROPOSED-2026.1";
        public const RuleSource Source = RuleSource.ProjectProposal;

        /// <summary>The released result is Pass/Fail (docs/01-university-rules.md;
        /// GJU's grading page defines P and F grades). The score is supporting data.</summary>
        public const string ResultMode = "PassFail";
    }
}
