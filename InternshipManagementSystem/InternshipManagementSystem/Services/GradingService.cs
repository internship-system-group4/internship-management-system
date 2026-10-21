// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad  (Trello card A11)
//  Final grade calculation (card A11).
// =============================================================================

using System.Collections.Generic;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Services
{
    // Shared pass/fail calculation; policy values remain HYPOTHETICAL pending X01.
    public static class GradingService
    {
        /// <summary>Weighted percentage of a list of components.</summary>
        public static double PercentOf(List<GradeComponent> components)
        {
            if (components == null || components.Count == 0) return 0;

            double weightTotal = 0;
            double earned = 0;
            foreach (GradeComponent component in components)
            {
                weightTotal += component.Weight;
                earned += component.WeightedPoints;
            }

            // Unweighted components fall back to a plain average of ratios, so
            // a half-filled criteria list still yields a sensible number.
            if (weightTotal <= 0)
            {
                double sum = 0;
                foreach (GradeComponent component in components) sum += component.Ratio;
                return (sum / components.Count) * 100.0;
            }

            return (earned / weightTotal) * 100.0;
        }

        /// <summary>The task component: every graded task, weighted by its own
        /// Weight so a two-week task can count more than a one-hour one.</summary>
        public static double TaskComponentPercent(
            List<InternshipTask> tasks, List<TaskEvaluation> evaluations)
        {
            if (tasks == null || evaluations == null || evaluations.Count == 0) return 0;

            Dictionary<string, double> weightByTask = new Dictionary<string, double>();
            foreach (InternshipTask task in tasks)
            {
                if (!string.IsNullOrEmpty(task.Id))
                {
                    weightByTask[task.Id] = task.Weight <= 0 ? 1 : task.Weight;
                }
            }

            double weightTotal = 0;
            double earned = 0;
            foreach (TaskEvaluation evaluation in evaluations)
            {
                if (evaluation.RevisionRequested) continue;   // not a grade yet

                double weight;
                if (!weightByTask.TryGetValue(evaluation.TaskId ?? string.Empty, out weight)) weight = 1;

                weightTotal += weight;
                earned += (evaluation.Percentage / 100.0) * weight;
            }

            return weightTotal <= 0 ? 0 : (earned / weightTotal) * 100.0;
        }

        /// <summary>
        /// Combines the three components into the student's final result.
        /// Throws when the weights in GradingPolicy do not add up to 100,
        /// because silently producing a wrong grade is far worse than failing
        /// loudly during development.
        /// </summary>
        public static double FinalPercent(
            double taskPercent, double companyPercent, double academicPercent)
        {
            if (!GradingPolicy.WeightsAreValid())
            {
                throw new System.InvalidOperationException(
                    "GradingPolicy weights must add up to 100. Fix Common/GradingPolicy.cs.");
            }

            return (taskPercent * GradingPolicy.TaskComponentWeight
                    + companyPercent * GradingPolicy.CompanyFinalWeight
                    + academicPercent * GradingPolicy.AcademicFinalWeight) / 100.0;
        }

        /// <summary>Fills the score fields of a completion record in one call
        /// (card A11), leaving Status and approval alone - only a coordinator
        /// changes those.</summary>
        public static void Apply(CompletionRecord record,
                                 double taskPercent, double companyPercent, double academicPercent)
        {
            if (record == null) return;
            record.TaskScorePercent = taskPercent;
            record.CompanyScorePercent = companyPercent;
            record.AcademicScorePercent = academicPercent;
            record.FinalScore = FinalPercent(taskPercent, companyPercent, academicPercent);
            record.Result = IsPassing(record.FinalScore) ? "Pass" : "Fail";
        }

        public static bool IsPassing(double finalPercent)
        {
            return finalPercent >= GradingPolicy.PassMarkPercent;
        }
    }
}
