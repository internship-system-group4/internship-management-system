using System;
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

                // Opened from a notification: open that student's evaluation.
                string fromLink = Request.QueryString["id"];
                if (!string.IsNullOrEmpty(fromLink)) OpenEvaluation(fromLink);
            }
        }

        private void LoadStudentsTable()
        {
            // جلب الطلاب المخصصين للمشرف لعرضهم في الجدول
            UserRepository userRepo = new UserRepository();
            List<Student> myStudents = userRepo.GetStudentsBySupervisor(CurrentSupervisor.Id);

            if (myStudents != null && myStudents.Count > 0)
            {
                rptStudents.DataSource = myStudents;
                rptStudents.DataBind();
                litNoData.Visible = false;
            }
            else
            {
                litNoData.Visible = true;
            }
        }

        // هذا الحدث يعمل عندما يضغط الدكتور على زر View لأي طالب
        protected void btnOpenModal_Click(object sender, EventArgs e)
        {
            // إخفاء رسالة النجاح السابقة إن وجدت
            pnlSuccessMessage.Visible = false;

            // أخذ الـ ID الخاص بالطالب الذي تم الضغط عليه
            System.Web.UI.WebControls.LinkButton btn = (System.Web.UI.WebControls.LinkButton)sender;
            OpenEvaluation(btn.CommandArgument);
        }

        private void OpenEvaluation(string studentId)
        {
            pnlSuccessMessage.Visible = false;
            if (!CanEvaluate(studentId)) { Response.Redirect("FinalEvaluation.aspx", false); Context.ApplicationInstance.CompleteRequest(); return; }
            // حفظه في Hidden Field لنستخدمه عند الضغط على إرسال التقييم
            hfSelectedStudentId.Value = studentId;

            // 1. جلب اسم الطالب
            UserRepository userRepo = new UserRepository();
            Student student = userRepo.GetStudent(studentId);
            litModalStudentName.Text = student != null ? student.FullName : L.T("Academic.FinalEvaluation.UnknownStudent");

            // 2. جلب تقييم الشركة إن وجد
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

            // 3. التحقق إذا كان التقييم الأكاديمي محفوظ مسبقاً لهذا الطالب
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
                // إذا لم يتم التقييم بعد، نفتح النموذج
                ddlPassFail.SelectedValue = "";
                ddlPassFail.Enabled = true;
                txtAcademicComments.Text = "";
                txtAcademicComments.Enabled = true;
                btnSubmitEvaluation.Visible = true;
                pnlAlreadySubmitted.Visible = false;
            }

            // 4. كود جافاسكريبت متطور لإظهار النافذة المنبثقة (Modal) بأمان
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

        // هذا الحدث يعمل عندما يضغط الدكتور "إرسال" من داخل النافذة المنبثقة
        protected void btnSubmitEvaluation_Click(object sender, EventArgs e)
        {
            string studentId = hfSelectedStudentId.Value;

            if (string.IsNullOrEmpty(studentId) || string.IsNullOrEmpty(ddlPassFail.SelectedValue))
            {
                return;
            }

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
            evalRepo.SaveAcademicFinal(eval);

            // إظهار رسالة النجاح في الشاشة الرئيسية (لأن النافذة ستغلق تلقائياً بعد الإرسال)
            pnlSuccessMessage.Visible = true;
            litSuccessMessage.Text = L.T("Academic.FinalEvaluation.EvaluationForTheSelectedStudentHas");
        }
        private bool CanEvaluate(string studentId)
        {
            if (!ApplicationRepository.IsValidKey(studentId)) return false;
            var student = new UserRepository().GetStudent(studentId);
            var placement = new PlacementRepository().GetById(studentId);
            return student != null && student.AcademicSupervisorId == CurrentSupervisor.Id
                && placement != null && placement.StudentId == studentId
                && placement.AcademicSupervisorId == CurrentSupervisor.Id;
        }
    }
}