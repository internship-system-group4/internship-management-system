using System;
using System.Linq;
using InternshipManagementSystem.Common;
using System.Collections.Generic;
using InternshipManagementSystem.Models;
using InternshipManagementSystem.Security;
using InternshipManagementSystem.Data;

namespace InternshipManagementSystem.Pages.Academic
{
    public partial class FinalEvaluation : AcademicPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadStudentsTable();

                // Opened from a notification (FinalEvaluation.aspx?id={studentId}): open that student's evaluation.
                string fromLink = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(fromLink)) OpenEvaluation(fromLink);
            }
        }

        // دالة عرض الطلاب مع فلترة الطلاب الجاهزين للتقييم فقط + البحث والتخصص
        private void LoadStudentsTable()
        {
            UserRepository userRepo = new UserRepository();
            // 1. جلب كل طلاب المشرف
            List<Student> allMyStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);

            if (allMyStudents != null && allMyStudents.Count > 0)
            {
                // 2. الفلترة المنطقية: إبقاء الطلاب اللي عندهم تدريب وجاهزين للتقييم فقط
                var validStudentsForEvaluation = allMyStudents.Where(s => CanEvaluate(s.Id)).ToList();

                // 3. تطبيق فلتر التخصص (Major)
                string selectedFilter = ddlMajorFilter.SelectedValue;
                if (selectedFilter != "All")
                {
                    validStudentsForEvaluation = validStudentsForEvaluation.Where(s => s.Major == selectedFilter).ToList();
                }

                // 4. تطبيق البحث بالاسم أو الرقم الجامعي
                string searchQuery = txtSearch.Text.Trim().ToLower();
                if (!string.IsNullOrEmpty(searchQuery))
                {
                    validStudentsForEvaluation = validStudentsForEvaluation.Where(s =>
                        (s.FullName ?? "").ToLower().Contains(searchQuery) ||
                        (s.StudentNumber ?? "").ToLower().Contains(searchQuery)
                    ).ToList();
                }

                // 5. ربط البيانات بالجدول
                rptStudents.DataSource = validStudentsForEvaluation;
                rptStudents.DataBind();
                litNoData.Visible = validStudentsForEvaluation.Count == 0;
            }
            else
            {
                litNoData.Visible = true;
            }
        }

        protected void ddlMajorFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            LoadStudentsTable();
        }

        protected void btnSearch_Click(object sender, EventArgs e)
        {
            LoadStudentsTable();
        }

        protected void btnOpenModal_Click(object sender, EventArgs e)
        {
            System.Web.UI.WebControls.LinkButton btn = (System.Web.UI.WebControls.LinkButton)sender;
            OpenEvaluation(btn.CommandArgument);
        }

        private void OpenEvaluation(string studentId)
        {
            pnlSuccessMessage.Visible = false;

            // حماية منطقية: التأكد من إمكانية التقييم
            if (!CanEvaluate(studentId)) { Response.Redirect("FinalEvaluation.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }

            hfSelectedStudentId.Value = studentId;

            UserRepository userRepo = new UserRepository();
            Student student = userRepo.GetStudent(studentId);
            litModalStudentName.Text = student != null ? student.FullName : L.T("Academic.FinalEvaluation.UnknownStudent");

            EvaluationRepository evalRepo = new EvaluationRepository();
            FinalCompanyEvaluation companyEval = evalRepo.GetCompanyFinalForPlacement(studentId);

            if (companyEval != null && companyEval.IsSubmitted)
            {
                pnlCompanyEvalExists.Visible = true;
                pnlNoCompanyEval.Visible = false;

                litCompanyScore.Text = companyEval.TotalScore.ToString();
                litCompanyMaxScore.Text = companyEval.MaxScore.ToString();
                litStrengths.Text = string.IsNullOrEmpty(companyEval.Strengths) ? "N/A" : companyEval.Strengths;
                litImprovements.Text = string.IsNullOrEmpty(companyEval.AreasForImprovement) ? "N/A" : companyEval.AreasForImprovement;
                litCompanyComment.Text = string.IsNullOrEmpty(companyEval.OverallComment) ? "N/A" : companyEval.OverallComment;
            }
            else
            {
                pnlCompanyEvalExists.Visible = false;
                pnlNoCompanyEval.Visible = true;
            }

            FinalAcademicEvaluation academicEval = evalRepo.GetAcademicFinalForPlacement(studentId);

            if (academicEval != null && academicEval.IsSubmitted)
            {
                ddlPassFail.SelectedValue = academicEval.TotalScore > 0 ? "100" : "0";
                ddlPassFail.Enabled = false;
                txtAcademicComments.Text = academicEval.AcademicComments;
                txtAcademicComments.Enabled = false;

                btnSubmitEvaluation.Visible = false;
                pnlAlreadySubmitted.Visible = true;

                DateTime submitDate = new DateTime(1970, 1, 1, 0, 0, 0, DateTimeKind.Utc).AddMilliseconds(academicEval.SubmittedAt).ToLocalTime();
                litAlreadySubmittedText.Text = L.F("Academic.FinalEvaluation.DecisionSubmittedSuccessfullyOn", submitDate.ToString("dd/MM/yyyy"));
            }
            else
            {
                ddlPassFail.SelectedValue = "";
                ddlPassFail.Enabled = true;
                txtAcademicComments.Text = "";
                txtAcademicComments.Enabled = true;
                btnSubmitEvaluation.Visible = true;
                pnlAlreadySubmitted.Visible = false;
            }

            string script = @"
        setTimeout(function() {
            var modalEl = document.getElementById('evaluationModal');
            if(modalEl) {
                var myModal = new bootstrap.Modal(modalEl);
                myModal.show();
            }
        }, 100);
    ";
            ClientScript.RegisterStartupScript(this.GetType(), "ShowEvaluationModal", script, true);
        }

        protected void btnSubmitEvaluation_Click(object sender, EventArgs e)
        {
            string studentId = hfSelectedStudentId.Value;

            if (string.IsNullOrEmpty(studentId) || string.IsNullOrEmpty(ddlPassFail.SelectedValue))
            {
                return;
            }

            // حماية منطقية قبل الحفظ
            if (!CanEvaluate(studentId)) { Response.Redirect("FinalEvaluation.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            var existing = new EvaluationRepository().GetAcademicFinalForPlacement(studentId);
            if (existing != null && existing.IsSubmitted) return;
            double totalScore = double.Parse(ddlPassFail.SelectedValue);

            FinalAcademicEvaluation eval = new FinalAcademicEvaluation
            {
                StudentId = studentId,
                PlacementId = studentId,
                AcademicSupervisorId = CurrentSupervisor.Id,
                TotalScore = totalScore,
                MaxScore = 100,
                AcademicComments = txtAcademicComments.Text,
                IsSubmitted = true,
                SubmittedAt = Common.Time.NowMs()
            };

            EvaluationRepository evalRepo = new EvaluationRepository();
            try { evalRepo.SaveAcademicFinal(eval); }
            catch (InvalidOperationException) { ShowSaveFailure(); return; }
            catch (UnauthorizedAccessException) { ShowSaveFailure(); return; }
            catch (FirebaseException) { ShowSaveFailure(); return; }

            pnlSuccessMessage.Visible = true;
            litSuccessMessage.Text = L.T("Academic.FinalEvaluation.EvaluationForTheSelectedStudentHas");
        }

        private void ShowSaveFailure()
        {
            pnlSuccessMessage.Visible = true;
            pnlSuccessMessage.CssClass = "alert alert-danger";
            litSuccessMessage.Text = L.T("Academic.FinalEvaluation.SaveFailedRetry");
        }

        private bool CanEvaluate(string studentId)
        {
            if (!ApplicationRepository.IsValidKey(studentId)) return false;
            var student = new UserRepository().GetStudent(studentId);
            var placement = new PlacementRepository().GetById(studentId);
            bool assigned = student != null && student.AcademicSupervisorId == CurrentSupervisor.Id
                && placement != null && placement.StudentId == studentId
                && placement.AcademicSupervisorId == CurrentSupervisor.Id;
            if (!assigned) return false;
            var company = new EvaluationRepository().GetCompanyFinalForPlacement(placement.Id);
            return company != null && company.IsSubmitted;
        }
    }
}
