// =============================================================================
//  Access Denied
//  Owner : Ahmad
//  Cards : A02
//
//  Shown when a signed-in user opens a page their role may not see. Already wired up by Security/SecurePage.cs - this page only needs a message and a link back to the user's own dashboard.
//
//  Namespace note: these page namespaces end in "Area" on purpose. A namespace
//  called ...Pages.Student would hide the Student model class and every file in
//  the folder would fail to compile with "Student is a namespace but is used
//  like a type". Keep the suffix.
// =============================================================================
using System;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;

namespace InternshipManagementSystem.Pages.PublicArea
{
    public partial class AccessDenied : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A02): build this page.
        }
    }
}
