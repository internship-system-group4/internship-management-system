using System;
using System.Web;
using System.Web.UI;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Pages.PublicArea
{
    // Public, service-independent error document. No SecurePage, session or database calls.
    public class NotFound : Page
    {
        protected override void OnInit(EventArgs e)
        {
            L.Apply(Context);
            base.OnInit(e);
            Response.StatusCode = 404;
            Response.SubStatusCode = 0;
            Response.TrySkipIisCustomErrors = true;
            Response.ContentType = "text/html";
            Response.Headers["X-Content-Type-Options"] = "nosniff";
            Response.Headers["X-Robots-Tag"] = "noindex";
            Response.Cache.SetCacheability(HttpCacheability.NoCache);
            Response.Cache.SetNoStore();
            Title = L.T("Shared.Title.Pages.Public.NotFound");
        }
    }
}
