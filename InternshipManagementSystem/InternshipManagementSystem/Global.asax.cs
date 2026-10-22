// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad
//  Application start-up. The TLS line below is the important one.
// =============================================================================
using System;
using System.Net;
using System.Web;

namespace InternshipManagementSystem
{
    public class Global : HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Firebase refuses anything below TLS 1.2. .NET Framework picks its
            // protocol from the OS, and on some Windows installs that still means
            // TLS 1.0 - which shows up as a vague "could not create SSL/TLS
            // secure channel" on every single Firebase call and costs hours to
            // track down. Setting it explicitly removes the whole class of bug.
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            // Firebase hands back self-describing JSON; no extra setup needed.
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception error = Server.GetLastError();
            if (error == null) return;

            // A form posted after the session changed (expired, app restarted,
            // signed out in another tab) fails the viewstate check. Instead of
            // the yellow error page, just reload the same page fresh.
            if (IsViewStateError(error) && Request.HttpMethod == "POST")
            {
                Server.ClearError();
                Response.Redirect(Request.RawUrl, false);
                Context.ApplicationInstance.CompleteRequest();
                return;
            }

            // TODO(card X06): during integration testing it helps to log these
            // somewhere you can read them. System.Diagnostics.Trace shows up in
            // the Visual Studio Output window.
            System.Diagnostics.Trace.TraceError(error.ToString());
        }

        private static bool IsViewStateError(Exception error)
        {
            for (Exception e = error; e != null; e = e.InnerException)
            {
                if (e is System.Web.UI.ViewStateException) return true;
            }
            return false;
        }

        protected void Session_Start(object sender, EventArgs e)
        {
        }
    }
}
