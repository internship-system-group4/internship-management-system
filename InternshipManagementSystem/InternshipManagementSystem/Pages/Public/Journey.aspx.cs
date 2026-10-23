using System;
using System.Collections.Generic;
using System.IO;
using System.Web;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.PublicArea
{
    // Owner: Ahmad. The Jisr homepage: 3D story, public opportunity summaries (no login),
    // academic directory, the internship process and its video.
    public partial class Journey : System.Web.UI.Page
    {
        protected List<PublicOpportunityPreview> Previews = new List<PublicOpportunityPreview>();
        protected string PreviewError;
        protected bool ProcessVideoAvailable, ProcessCaptionsAvailable;

        protected class School
        {
            public string Name, Short, Line, ProgramLabel;
            public string[] Programs;
            public bool OnUims;
        }

        // Official names and programmes from gju.edu.jo (checked 23 October 2026).
        // UIMS currently supports the School of Computing only (Constants.CollegeName).
        protected readonly School[] Schools =
        {
            new School { Name = "School of Computing", Short = "SC", Line = "Where ideas become technology.", ProgramLabel = "Programmes",
                Programs = new[] { "Computer Science", "Computer Engineering", "MSc Computer Engineering", "MSc Enterprise Software Engineering" }, OnUims = true },
            new School { Name = "School of Applied Technical Sciences", Short = "SATS", Line = "Engineering that works on the factory floor.", ProgramLabel = "Programmes",
                Programs = new[] { "Mechanical and Maintenance Engineering", "Industrial Engineering", "Mechatronics Engineering" } },
            new School { Name = "School of Sustainable Systems Engineering", Short = "SSSE", Line = "Engineering a sustainable tomorrow.", ProgramLabel = "Programmes",
                Programs = new[] { "Civil and Environmental Engineering", "Electrical and Energy Engineering" } },
            new School { Name = "School of Architecture and Built Environment", Short = "SABE", Line = "Designing the spaces we live in.", ProgramLabel = "Programmes",
                Programs = new[] { "Architecture and Interior Architecture" } },
            new School { Name = "Business School", Short = "BS", Line = "Ideas that grow into enterprises.", ProgramLabel = "Programmes",
                Programs = new[] { "International Accounting", "Logistics Sciences", "Digital Marketing", "MBA", "Master in Logistics Management" } },
            new School { Name = "School of Applied Medical Sciences", Short = "SAMS", Line = "Science in the service of health.", ProgramLabel = "Programmes",
                Programs = new[] { "Biomedical Engineering", "Pharmaceutical and Chemical Engineering" } },
            new School { Name = "School of Applied Humanities and Social Sciences", Short = "SAHSS", Line = "Languages, people and society.", ProgramLabel = "Departments",
                Programs = new[] { "Applied Humanities", "Social Work", "Basic Education" } },
            new School { Name = "School of Nursing", Short = "SN", Line = "Care, grounded in science.", ProgramLabel = "Programmes",
                Programs = new[] { "Nursing" } }
        };

        protected string[] TracksFor(string program)
        {
            if (program == "Computer Engineering") return Constants.ComputerEngineeringTracks;
            if (program == "Computer Science") return Constants.ComputerScienceTracks;
            return new string[0];
        }

        // Anonymous visitors are sent to Login by the student page guard, which returns them here after sign-in.
        protected string ApplyUrl(string opportunityId)
        {
            return ResolveUrl("~/Pages/Student/Apply.aspx") + "?opportunityId=" + HttpUtility.UrlEncode(opportunityId);
        }

        protected static string DeadlineText(long deadline)
        {
            if (deadline <= 0) return null;
            return "Apply by " + DateTimeOffset.FromUnixTimeMilliseconds(deadline).ToLocalTime().ToString("d MMMM yyyy");
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            ProcessVideoAvailable = File.Exists(Server.MapPath("~/Assets/video/internship-process.mp4"));
            ProcessCaptionsAvailable = File.Exists(Server.MapPath("~/Assets/video/internship-process.en.vtt"));
            try { Previews = new OpportunityRepository().GetPublicPreviews(6); }
            catch (FirebaseAuthExpiredException) { PreviewError = "Internship summaries are not available to visitors yet. Please try again later, or log in to see opportunities in your portal."; }
            catch (FirebaseException) { PreviewError = "We could not load internship summaries. Please refresh to try again."; }
            catch (InvalidOperationException) { PreviewError = "Internship summaries are not configured yet."; }
        }
    }
}
