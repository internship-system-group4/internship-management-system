// =============================================================================
//  Contact Us
//  Owner : Sara Dolat
//  Cards : D01
//
//  Name, email, subject and message, validated and saved to Firebase, with confirmation feedback. The saved message must appear in the coordinator's inbox.
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
    public partial class Contact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Sara Dolat, D01): build this page.
        }
    }
}
