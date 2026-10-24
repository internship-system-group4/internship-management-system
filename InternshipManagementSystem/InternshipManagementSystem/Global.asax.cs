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

        // Interface language (Common/Localization.cs): a GET with ?ui-lang=en|ar saves the choice and redirects to the
        // same page; every request then renders in the cookie's language, before any page code runs.
        protected void Application_BeginRequest(object sender, EventArgs e)
        {
            if (Common.L.HandleSwitch(Context)) return;
            Common.L.Apply(Context);
        }

        // Applied again just before the page runs, in case anything in the pipeline reset the thread culture.
        protected void Application_PreRequestHandlerExecute(object sender, EventArgs e)
        {
            Common.L.Apply(Context);
            // Page titles come from each page directive (English); the translated title is looked up by route.
            var page = Context.Handler as System.Web.UI.Page;
            // Pages without <head runat="server"> (standalone documents) have no Title to set.
            if (page != null) page.PreRenderComplete += (s, args) => { if (page.Header != null) page.Title = Common.L.PageTitle(page); };
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception error = Server.GetLastError();
            if (error == null) return;

            // ASP.NET 404s (including missing .aspx pages). Native/static 404s are
            // executed by IIS httpErrors. Both paths keep the browser's original URL.
            var httpError = error as HttpException;
            if (httpError != null && httpError.GetHttpCode() == 404 &&
                Context.Items["Uims.NotFound"] == null &&
                !Request.Path.StartsWith(VirtualPathUtility.ToAbsolute("~/Assets/"), StringComparison.OrdinalIgnoreCase) &&
                !Request.CurrentExecutionFilePath.Equals(VirtualPathUtility.ToAbsolute("~/Pages/Public/NotFound.aspx"), StringComparison.OrdinalIgnoreCase))
            {
                Context.Items["Uims.NotFound"] = true;
                Server.ClearError();
                Response.Clear();
                Server.Transfer("~/Pages/Public/NotFound.aspx", false);
                return;
            }

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
