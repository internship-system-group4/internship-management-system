using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Data;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Services;
using Newtonsoft.Json;

namespace InternshipManagementSystem.Pages.CoordinatorArea
{
    /// <summary>One academic supervisor in the coordinator's directory and pop-ups.</summary>
    public class SupervisorDirectoryRow
    {
        public string Id, FullName, Email, Phone, Department, AcademicRank, Initials, StatusText, CreatedText, SearchText, ProfileUrl;
        public List<string> GroupNames = new List<string>();
        public int GroupCount, StudentCount;
        public bool IsActive;
        /// <summary>Only a supervisor with no groups and no students can be deleted.</summary>
        public bool CanDelete { get { return GroupCount == 0 && StudentCount == 0; } }
    }

    public partial class AcademicSupervisors : CoordinatorPage
    {
        protected bool ShowCreationModal { get; private set; }
        protected List<SupervisorDirectoryRow> Rows = new List<SupervisorDirectoryRow>();

        protected string RowsJson
        {
            get { return JsonConvert.SerializeObject(Rows, new JsonSerializerSettings { StringEscapeHandling = StringEscapeHandling.EscapeHtml }); }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            // The table is rebuilt on every request (it is not kept in ViewState).
            BindSupervisors();
        }

        protected void btnCreate_Click(object sender, EventArgs e)
        {
            pnlDetails.Visible = false;
            string name = InternshipManagementSystem.Common.Validators.Clean(txtFullName.Text);
            string email = (txtEmail.Text ?? "").Trim();
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtPhone.Text);
            string department = InternshipManagementSystem.Common.Validators.Clean(txtDepartment.Text);
            string rank = InternshipManagementSystem.Common.Validators.Clean(txtAcademicRank.Text);

            if (name == null || email.Length == 0 || department == null)
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.EnterANameLoginEmailAnd"), false);
                return;
            }
            if (name.Length > 120 || email.Length > 254 || department.Length > 120
                || (phone != null && phone.Length > 40) || (rank != null && rank.Length > 80))
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.OneOrMoreFieldsAreToo"), false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsEmail(email))
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.EnterAValidEmailAddress"), false);
                return;
            }
            // The phone is required: exactly 10 digits (e.g. 0791234567).
            if (!InternshipManagementSystem.Common.Validators.IsPhone10(phone))
            {
                ShowCreateMessage(L.T("Coordinator.Phone.Invalid"), false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsStrongEnoughPassword(txtPassword.Text))
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.TheTemporaryPasswordMustBeAt"), false);
                return;
            }
            if (txtPassword.Text != txtConfirmPassword.Text)
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.ThePasswordsDoNotMatch"), false);
                return;
            }
            if (!FirebaseContext.IsConfigured)
            {
                ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.FirebaseIsNotConfiguredAskThe"), false);
                return;
            }

            AuthResult account = AuthService.CreateAccount(email, txtPassword.Text);
            if (!account.Success || string.IsNullOrEmpty(account.Uid) || string.IsNullOrEmpty(account.IdToken))
            {
                ShowCreateMessage(account.ErrorMessage ?? L.T("Coordinator.AcademicSupervisors.CouldNotCreateTheAccount"), false);
                return;
            }

            AcademicSupervisor supervisor = new AcademicSupervisor
            {
                Id = account.Uid,
                FullName = name,
                Email = email,
                PhoneNumber = phone,
                Department = department,
                AcademicRank = rank,
                GroupIds = new List<string>(),
                MustChangePassword = true
            };

            try
            {
                new UserRepository().SavePerson(supervisor);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Trace.TraceError("Academic supervisor profile save failed for UID {0}: {1}", account.Uid, ex);
                AuthResult rollback = AuthService.DeleteAccount(account.IdToken);
                if (!rollback.Success)
                {
                    System.Diagnostics.Trace.TraceError("Academic supervisor Auth rollback failed for UID {0}: {1}", account.Uid, rollback.ErrorCode);
                    ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.TheAccountWasCreatedButIts"), false);
                }
                else
                {
                    ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.TheSupervisorCouldNotBeSaved"), false);
                }
                return;
            }

            ShowCreateMessage(L.T("Coordinator.AcademicSupervisors.AcademicSupervisorAccountCreatedShareThe"), true);
            txtFullName.Text = txtEmail.Text = txtPhone.Text = txtDepartment.Text = txtAcademicRank.Text = "";
            txtPassword.Text = txtConfirmPassword.Text = "";
            BindSupervisors();
        }

        protected void btnEdit_Click(object sender, EventArgs e)
        {
            var button = sender as System.Web.UI.WebControls.LinkButton;
            if (button == null || !IsValidSupervisorId(button.CommandArgument)) return;
            try
            {
                AcademicSupervisor supervisor = new UserRepository().GetAcademicSupervisor(button.CommandArgument);
                if (supervisor == null)
                {
                    ShowListMessage(L.T("Coordinator.AcademicSupervisors.SupervisorRecordNotFound"), false);
                    return;
                }
                ShowDetails(supervisor);
            }
            catch (FirebaseException)
            {
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.CouldNotLoadThisSupervisorPlease"), false);
            }
        }

        /// <summary>The row's Active / Inactive switch (after the confirm pop-up).
        /// Turns the supervisor's sign-in on or off; nothing is deleted.</summary>
        protected void btnConfirmToggle_Click(object sender, EventArgs e)
        {
            string id = hfToggleId.Value;
            hfToggleId.Value = "";
            pnlDetails.Visible = false;
            if (!IsValidSupervisorId(id))
            {
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.SupervisorRecordNotFound"), false);
                return;
            }
            try
            {
                UserRepository users = new UserRepository();
                AcademicSupervisor supervisor = users.GetAcademicSupervisor(id);
                if (supervisor == null)
                {
                    ShowListMessage(L.T("Coordinator.AcademicSupervisors.SupervisorRecordNotFound"), false);
                    BindSupervisors();
                    return;
                }
                bool activate = !supervisor.IsActive;
                users.SetActive(id, activate);
                BindSupervisors();
                ShowListMessage(L.F(activate ? "Coordinator.Toggle.NowActive" : "Coordinator.Toggle.NowInactive", supervisor.FullName), true);
            }
            catch (FirebaseException)
            {
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.CouldNotChangeSupervisorAccessPlease"), false);
            }
        }

        protected void btnSaveDetails_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingSupervisorId"] as string;
            pnlDetails.Visible = IsValidSupervisorId(id);
            if (!pnlDetails.Visible)
            {
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.SelectASupervisorBeforeSavingChanges"), false);
                return;
            }

            string name = InternshipManagementSystem.Common.Validators.Clean(txtEditFullName.Text);
            string phone = InternshipManagementSystem.Common.Validators.Clean(txtEditPhone.Text);
            string department = InternshipManagementSystem.Common.Validators.Clean(txtEditDepartment.Text);
            string rank = InternshipManagementSystem.Common.Validators.Clean(txtEditAcademicRank.Text);
            if (name == null || department == null)
            {
                ShowDetailsMessage(L.T("Coordinator.AcademicSupervisors.EnterANameAndDepartment"), false);
                return;
            }
            if (!InternshipManagementSystem.Common.Validators.IsPhone10(phone))
            {
                ShowDetailsMessage(L.T("Coordinator.Phone.Invalid"), false);
                return;
            }
            if (name.Length > 120 || department.Length > 120
                || (phone != null && phone.Length > 40) || (rank != null && rank.Length > 80))
            {
                ShowDetailsMessage(L.T("Coordinator.AcademicSupervisors.OneOrMoreFieldsAreToo"), false);
                return;
            }

            try
            {
                UserRepository users = new UserRepository();
                AcademicSupervisor supervisor = users.GetAcademicSupervisor(id);
                if (supervisor == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingSupervisorId"] = null;
                    BindSupervisors();
                    ShowListMessage(L.T("Coordinator.AcademicSupervisors.SupervisorRecordNotFound"), false);
                    return;
                }

                // The login email and group assignments have separate workflows.
                users.Update(id, new Dictionary<string, object>
                {
                    { "FullName", name },
                    { "PhoneNumber", phone },
                    { "Department", department },
                    { "AcademicRank", rank }
                });

                supervisor.FullName = name;
                supervisor.PhoneNumber = phone;
                supervisor.Department = department;
                supervisor.AcademicRank = rank;
                ShowDetails(supervisor);
                BindSupervisors();
                ShowDetailsMessage(L.T("Coordinator.AcademicSupervisors.SupervisorInformationSaved"), true);
            }
            catch (FirebaseException)
            {
                ShowDetailsMessage(L.T("Coordinator.AcademicSupervisors.CouldNotSaveSupervisorInformationPlease"), false);
            }
        }

        protected void btnToggleAccess_Click(object sender, EventArgs e)
        {
            string id = ViewState["EditingSupervisorId"] as string;
            if (!IsValidSupervisorId(id))
            {
                pnlDetails.Visible = false;
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.SelectASupervisorBeforeChangingAccess"), false);
                return;
            }
            try
            {
                UserRepository users = new UserRepository();
                AcademicSupervisor supervisor = users.GetAcademicSupervisor(id);
                if (supervisor == null)
                {
                    pnlDetails.Visible = false;
                    ViewState["EditingSupervisorId"] = null;
                    BindSupervisors();
                    ShowListMessage(L.T("Coordinator.AcademicSupervisors.SupervisorRecordNotFound"), false);
                    return;
                }
                bool activate = !supervisor.IsActive;
                users.SetActive(id, activate);
                supervisor.IsActive = activate;
                ShowDetails(supervisor);
                BindSupervisors();
                ShowDetailsMessage(activate ? L.T("Coordinator.AcademicSupervisors.SupervisorAccessRestored") : L.T("Coordinator.AcademicSupervisors.SupervisorAccessRemovedAssignedGroupsAnd"), true);
            }
            catch (FirebaseException)
            {
                pnlDetails.Visible = true;
                ShowDetailsMessage(L.T("Coordinator.AcademicSupervisors.CouldNotChangeSupervisorAccessPlease"), false);
            }
        }

        private void BindSupervisors()
        {
            try
            {
                List<Person> people = new UserRepository().GetAllPeople();
                List<StudentGroup> groups = new GroupRepository().GetAll();
                List<Student> students = people.OfType<Student>().ToList();
                string none = L.T("Coordinator.ManageStudents.NotRecorded");
                string profileBase = ResolveUrl("~/Pages/Coordinator/SupervisorProfile.aspx?id=");
                Rows = people.OfType<AcademicSupervisor>()
                    .OrderBy(s => s.FullName ?? "", StringComparer.OrdinalIgnoreCase)
                    .Select(s =>
                    {
                        List<string> groupNames = groups.Where(g => g.AcademicSupervisorId == s.Id)
                            .Select(g => g.Name).OrderBy(n => n).ToList();
                        return new SupervisorDirectoryRow
                        {
                            Id = s.Id,
                            FullName = s.FullName ?? none,
                            Email = s.Email ?? none,
                            Phone = string.IsNullOrWhiteSpace(s.PhoneNumber) ? none : s.PhoneNumber,
                            Department = string.IsNullOrWhiteSpace(s.Department) ? none : s.Department,
                            AcademicRank = string.IsNullOrWhiteSpace(s.AcademicRank) ? none : s.AcademicRank,
                            Initials = StudentDirectoryRow.MakeInitials(s.FullName),
                            IsActive = s.IsActive,
                            StatusText = s.IsActive ? L.T("Coordinator.ManageStudents.StatusActive") : L.T("Coordinator.ManageStudents.StatusInactive"),
                            CreatedText = s.CreatedAt > 0 ? s.CreatedAtUtc.ToString("dd MMM yyyy") : none,
                            GroupNames = groupNames,
                            GroupCount = groupNames.Count,
                            StudentCount = students.Count(st => st.AcademicSupervisorId == s.Id),
                            ProfileUrl = profileBase + Uri.EscapeDataString(s.Id),
                            SearchText = string.Join(" ", new[] { s.FullName, s.Email, s.Department, s.AcademicRank }).ToLowerInvariant()
                        };
                    }).ToList();
                rptSupervisors.DataSource = Rows;
                rptSupervisors.DataBind();
                lblNoSupervisors.Text = L.T("Coordinator.AcademicSupervisors.NoAcademicSupervisorsFound");
                lblNoSupervisors.Visible = Rows.Count == 0;
            }
            catch (FirebaseException)
            {
                Rows = new List<SupervisorDirectoryRow>();
                rptSupervisors.DataSource = Rows;
                rptSupervisors.DataBind();
                lblNoSupervisors.Visible = false;
                ShowListMessage(L.T("Coordinator.AcademicSupervisors.CouldNotLoadSupervisorsPleaseTry"), false);
            }
        }

        private static bool IsValidSupervisorId(string id)
        {
            return !string.IsNullOrEmpty(id) && Regex.IsMatch(id, @"\A[A-Za-z0-9_-]{1,128}\z");
        }

        private void ShowDetails(AcademicSupervisor supervisor)
        {
            ViewState["EditingSupervisorId"] = supervisor.Id;
            pnlDetails.Visible = true;
            lblDetailsMessage.Visible = false;
            litInitials.Text = InternshipManagementSystem.Common.Validators.Safe(StudentDirectoryRow.MakeInitials(supervisor.FullName));
            lblDetailsName.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.FullName);
            lblDetailsEmail.Text = InternshipManagementSystem.Common.Validators.Safe(supervisor.Email);
            lblGroupCount.Text = supervisor.GroupIds == null ? "0" : supervisor.GroupIds.Count.ToString();
            txtEditFullName.Text = supervisor.FullName;
            txtEditPhone.Text = supervisor.PhoneNumber;
            txtEditDepartment.Text = supervisor.Department;
            txtEditAcademicRank.Text = supervisor.AcademicRank;
            btnToggleAccess.Text = supervisor.IsActive ? L.T("Coordinator.AcademicSupervisors.RemoveAccess") : L.T("Coordinator.AcademicSupervisors.RestoreAccess");
            btnToggleAccess.CssClass = supervisor.IsActive ? "btn btn-outline-danger" : "btn btn-outline-success";
            btnToggleAccess.OnClientClick = supervisor.IsActive
                ? "return confirm(" + JsonConvert.ToString(L.T("Coordinator.AcademicSupervisors.ConfirmRemoveAccess")) + ");"
                : "";
            lblAccessDescription.Text = supervisor.IsActive
                ? L.T("Coordinator.AcademicSupervisors.RemovingAccessBlocksSignInAssigned")
                : L.T("Coordinator.AcademicSupervisors.ThisSupervisorCannotSignInRestore");
        }

        private void ShowCreateMessage(string message, bool success)
        {
            ShowCreationModal = !success;
            var label = success ? lblCreateSuccess : lblCreateMessage;
            label.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            label.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            label.Visible = true;
        }

        private void ShowListMessage(string message, bool success)
        {
            lblListMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblListMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblListMessage.Visible = true;
        }

        private void ShowDetailsMessage(string message, bool success)
        {
            lblDetailsMessage.Text = InternshipManagementSystem.Common.Validators.Safe(message);
            lblDetailsMessage.CssClass = success ? "alert alert-success d-block" : "alert alert-danger d-block";
            lblDetailsMessage.Visible = true;
        }
    }
}
