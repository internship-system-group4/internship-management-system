namespace InternshipManagementSystem.Common
{
    public static class Constants
    {
        public const string UniversityName = "German Jordanian University";
        public const string UniversityNameArabic = "الجامعة الألمانية الأردنية";
        public const string CollegeName = "School of Computing";
        public const string UniversityWebsite = "https://www.gju.edu.jo";
        // Main campus on Amman Madaba Street: the "Location map" link published on gju.edu.jo
        // (Google Maps place "German Jordanian University - New Campus", 31.776843, 35.802555).
        // Official main-campus map pin from gju.edu.jo (OpenStreetMap's campus area, way 588418001, centres ~120 m away).
        public const string CampusLatitude = "31.776843";
        public const string CampusLongitude = "35.802555";
        public const string UniversityDirectionsUrl = "https://www.google.com/maps/dir/?api=1&destination=31.776843,35.802555";
        // Google's keyless embed endpoint for the same point; it allows framing, unlike the place page above.
        public const string UniversityMapEmbedUrl = "https://www.google.com/maps/embed?origin=mfe&pb=!1m3!2m1!1s31.776843,35.802555!6i15!3m1!1sen!5m1!1sen";
        public const string UniversityMapUrl = "https://www.google.jo/maps/place/German+Jordanian+University+-+New+Campus/@31.776843,35.802555,17z/data=!3m1!4b1!4m2!3m1!1s0x151cac23316fd607:0xbcc3e00aab7f6fa9";
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
            public const string Notifications = "notifications";
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
