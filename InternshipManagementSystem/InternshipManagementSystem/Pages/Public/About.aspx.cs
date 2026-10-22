// =============================================================================
//  About Us
//  Owner : Nada
//  Cards : N02
//
//  Information about the university, the system and its objectives.
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
    public partial class About : System.Web.UI.Page
    {
        // The university introduction film supplied with the project (H.264/AAC MP4, 1280x538, 1 min 48 s).
        // It is served in place; the internship-process video slot on Home is separate (~/Assets/video/).
        protected const string FilmPath = "~/Assets/images/university/materials/-578791943103387727.mp4";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;
        }
    }
}
