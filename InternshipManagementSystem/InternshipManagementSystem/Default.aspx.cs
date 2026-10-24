using System;
using System.Collections.Generic;
using System.IO;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Pages.PublicArea
{
    // Home shows explicitly illustrative examples; live opportunities remain in the student portal.
    public partial class Default : System.Web.UI.Page
    {
        protected sealed class DemoOpportunity
        {
            public string Title, CompanyName, Location, Specialization, Summary, IconPath;
        }
        protected List<DemoOpportunity> Previews = new List<DemoOpportunity>();
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
            string[] icons = {
                "m8 7-5 5 5 5m8-10 5 5-5 5M14 4l-4 16",
                "M3 4h18v16H3zM3 9h18M7 6.5h.01M10 6.5h.01",
                "M4 20V10m8 10V4m8 16v-7M2 20h20",
                "M8 4h12v17H4V4h1M8 2h8v5H8zM8 12l2 2 5-5",
                "m12 2 8 4v6c0 5-8 10-8 10S4 17 4 12V6zM9 12l2 2 4-5",
                "M6 6h12v12H6zM9 9h6v6H9zM9 2v4m6-4v4M9 18v4m6-4v4M2 9h4m-4 6h4m12-6h4m-4 6h4"
            };
            for (int i = 1; i <= 6; i++)
            {
                string prefix = "Public.Home.Demo" + i;
                Previews.Add(new DemoOpportunity {
                    Title = L.T(prefix + "Title"), CompanyName = L.T(prefix + "Company"),
                    Location = L.T(prefix + "Location"), Specialization = L.T(prefix + "Field"),
                    Summary = L.T(prefix + "Summary"), IconPath = icons[i - 1]
                });
            }
        }
    }
}
