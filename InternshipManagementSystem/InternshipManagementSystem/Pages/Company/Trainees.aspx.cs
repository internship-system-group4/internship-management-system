// =============================================================================
//  My Trainees
//  Owner : Nada
//  Cards : N06
//
//  Students with a confirmed placement at this company. Read placements through PlacementRepository.GetByCompany; each placement Id is its student UID.
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

namespace InternshipManagementSystem.Pages.CompanyArea
{
    public partial class Trainees : InternshipManagementSystem.Security.CompanyPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Nada, N06): build this page.
        }
    }
}
