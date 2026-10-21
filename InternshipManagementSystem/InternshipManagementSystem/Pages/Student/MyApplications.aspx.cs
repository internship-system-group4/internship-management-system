using System;
using System.Collections.Generic;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyApplications : Security.StudentPage
    {
        protected List<InternshipApplication> ApplicationsList = new List<InternshipApplication>();
        protected string LoadError;
        protected bool Submitted;
        protected void Page_Load(object sender, EventArgs e)
        {
            try { ApplicationsList = new ApplicationRepository().GetByStudent(CurrentStudent.Id); }
            catch (FirebaseException) { LoadError = "We could not load applications. Please refresh to try again."; }
            catch (InvalidOperationException) { LoadError = "The application service is not configured. Please contact the coordinator."; }
            Submitted = Session["ApplicationSubmitted"] is bool && (bool)Session["ApplicationSubmitted"]; Session.Remove("ApplicationSubmitted");
        }
    }
}
