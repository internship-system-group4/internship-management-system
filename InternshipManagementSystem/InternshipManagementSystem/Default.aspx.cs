// =============================================================================
//  Home
//  Owner : Nada
//  Cards : N01, N02
//
//  University identity, system introduction, colleges and majors, the internship process section with its video, and opportunity previews. A visitor may read a preview but must log in for full details or to apply.
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
    public partial class Default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Nada, N01, N02): build this page.
        }
    }
}
