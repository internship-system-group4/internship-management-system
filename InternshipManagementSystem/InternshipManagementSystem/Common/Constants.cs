namespace InternshipManagementSystem.Common
{
    public static class Constants
    {
        public const string UniversityName = "German Jordanian University";
        public const string UniversityNameArabic = "الجامعة الألمانية الأردنية";
        public const string CollegeName = "School of Computing";
        public const string UniversityWebsite = "https://www.gju.edu.jo";
        public const string LogoPath = "~/Assets/images/logo.png";

        public const int DefaultRequiredHours = 160;

        // TODO(X01): confirm program and track names against the official study plan before the demo.
        // Credit-hour eligibility is HYPOTHETICAL until X01 confirms it; no minimum is enforced here.
        public static readonly string[] Programs = { "Computer Engineering", "Computer Science" };
        public static readonly string[] ComputerEngineeringTracks =
            { "General", "Computer Vision and Robotics", "Artificial Intelligence and Machine Learning" };
        public static readonly string[] ComputerScienceTracks =
            { "General", "Cyber Security", "Data Science" };

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
            public const string AcademicComments = "academicComments";
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

        public const string SessionUserKey = "UIMS_CurrentUser";
        public const string SessionRefreshTokenKey = "UIMS_RefreshToken";
        public const string SessionTokenKey = "UIMS_IdToken";
    }
}
