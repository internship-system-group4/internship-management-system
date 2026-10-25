using System;
using System.Collections.Generic;
using System.IO;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class Default : System.Web.UI.Page
    {
        protected List<PublicOpportunityPreview> Previews = new List<PublicOpportunityPreview>();
        protected string PreviewError;
        protected bool ProcessVideoAvailable, ProcessCaptionsAvailable;
        protected string[] TracksFor(string program)
        {
            if (program == "Computer Engineering") return Common.Constants.ComputerEngineeringTracks;
            if (program == "Computer Science") return Common.Constants.ComputerScienceTracks;
            return new string[0];
        }
        protected void Page_Load(object sender, EventArgs e)
        {
            ProcessVideoAvailable = File.Exists(Server.MapPath("~/Assets/video/internship-process.mp4"));
            ProcessCaptionsAvailable = File.Exists(Server.MapPath("~/Assets/video/internship-process.en.vtt"));
            try { Previews = new OpportunityRepository().GetPublicPreviews(int.MaxValue); }
            catch (FirebaseAuthExpiredException) { PreviewError = L.T("Public.Home.PreviewUnavailable"); }
            catch (FirebaseException) { PreviewError = L.T("Public.Home.PreviewUnavailable"); }
            catch (InvalidOperationException) { PreviewError = L.T("Public.Home.PreviewUnavailable"); }
        }
    }
}
