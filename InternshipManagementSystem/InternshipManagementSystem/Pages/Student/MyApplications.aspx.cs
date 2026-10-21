// =============================================================================
//  My Applications
//  Owner : Osama
//  Cards : O02, O03
//
//  List the student's applications with status and rejection reasons, and let them confirm one accepted offer. Use PlacementRepository.Confirm(studentUid, placement); Exists(studentUid) checks for an internship and GetById(studentUid) loads it. Confirmation never replaces an existing placement.
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

namespace InternshipManagementSystem.Pages.StudentArea
{
    public partial class MyApplications : InternshipManagementSystem.Security.StudentPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack) return;

            // TODO(Osama, O02, O03): build this page.
        }
    }
}
