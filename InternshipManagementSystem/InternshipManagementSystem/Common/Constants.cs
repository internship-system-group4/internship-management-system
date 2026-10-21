// =============================================================================
//  University Internship Management System (UIMS)  -  Group 4
//  University identity and Firebase paths. Fill the TODOs from docs/01-university-rules.md.
//  Owner: Ahmad  (Trello card X02 - Shared Firebase Data Structure)
//  Do not edit without telling the owner: every page in the system depends on
//  these types. Add new fields, never rename or remove existing ones.
// =============================================================================

namespace InternshipManagementSystem.Common
{
    public static class Constants
    {
        // ------------------------------------------------------------------
        //  UNIVERSITY IDENTITY  -  TODO(Suja, card X01): replace with the real
        //  university assigned to Group 4, then update Assets/css/site.css
        //  brand variables and Assets/images/logo.png to match.
        // ------------------------------------------------------------------
        public const string UniversityName = "TODO: University Name";
        public const string UniversityNameArabic = "TODO: اسم الجامعة";
        public const string CollegeName = "TODO: College Name";
        public const string UniversityWebsite = "https://example.edu";
        public const string LogoPath = "~/Assets/images/logo.png";

        /// <summary>Default required training hours. The coordinator can still
        /// set a different value per student on the Manage Students page.</summary>
        public const int DefaultRequiredHours = 240;

        // ------------------------------------------------------------------
        //  FIREBASE REALTIME DATABASE PATHS
        //  One constant per collection. Never hard-code a path in a page:
        //  a typo in one page silently writes to a node nobody reads.
        // ------------------------------------------------------------------
        public static class Paths
        {
            public const string Users = "users";
            public const string Companies = "companies";
            public const string Groups = "studentGroups";
            public const string Opportunities = "opportunities";
            public const string Applications = "applications";
            public const string Placements = "placements";
            public const string Tasks = "tasks";
            public const string Submissions = "submissions";
            public const string TaskEvaluations = "taskEvaluations";
            public const string CompanyEvaluations = "companyFinalEvaluations";
            public const string AcademicEvaluations = "academicFinalEvaluations";
            public const string TrainingHours = "trainingHours";
            public const string Completions = "completions";
            public const string ContactMessages = "contactMessages";
            public const string Meetings = "meetings";
        }

        public static class Routes
        {
            public const string Home = "~/Default.aspx";
            public const string Login = "~/Pages/Account/Login.aspx";
            public const string ChangePassword = "~/Pages/Account/ChangePassword.aspx";
            public const string AccessDenied = "~/Pages/Public/AccessDenied.aspx";
        }

        /// <summary>Session key for the signed-in Person. Use SessionHelper
        /// instead of touching Session directly.</summary>
        public const string SessionUserKey = "UIMS_CurrentUser";
        public const string SessionTokenKey = "UIMS_IdToken";
    }
}
