using System;
using System.Collections.Generic;
using System.IO;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.PublicArea
{
    // Owner: Osama. Anonymous reads use only the published public projection.
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
            try { Previews = new OpportunityRepository().GetPublicPreviews(); }
            catch (FirebaseAuthExpiredException) { PreviewError = "Public opportunity previews are not available yet. Please try again later or log in to your portal."; }
            catch (FirebaseException) { PreviewError = "We could not load public opportunity previews. Please refresh to try again."; }
            catch (InvalidOperationException) { PreviewError = "Public opportunity previews are not configured yet."; }
        }
    }
}
