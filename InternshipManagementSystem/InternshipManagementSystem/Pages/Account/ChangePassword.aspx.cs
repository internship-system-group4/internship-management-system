// =============================================================================
//  Change Password
//  Owner : Ahmad
//  Cards : A04
//
//  Forced on first login. This is the one page that overrides AllowWhilePasswordChangePending, otherwise the guard would redirect to itself for ever. After AuthService.ChangePassword succeeds, call UserRepository.ClearMustChangePassword and refresh the session copy.
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

namespace InternshipManagementSystem.Pages.AccountArea
{
    public partial class ChangePassword : InternshipManagementSystem.Security.SecurePage
    {
        /// <summary>This page must stay reachable while the user still has a
        /// temporary password - it is the page that clears the flag.</summary>
        protected override bool AllowWhilePasswordChangePending
        {
            get { return true; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Ahmad, A04): build this page.
        }
    }
}
