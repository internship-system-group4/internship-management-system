using System.Collections.Generic;
using InternshipManagementSystem.Common;

namespace InternshipManagementSystem.Models
{
    /// <summary>
    /// A scheduled Zoom meeting with access limited to its creator and participants.
    /// </summary>
    public class Meeting
    {
        public string Id { get; set; }

        public string Title { get; set; }

        public string Agenda { get; set; }

        public string CreatedById { get; set; }

        public string PlacementId { get; set; }

        public List<string> ParticipantIds { get; set; }

        public long ScheduledAt { get; set; }

        public int DurationMinutes { get; set; }

        public string JoinUrl { get; set; }
        public string ZoomMeetingId { get; set; }

        public MeetingStatus Status { get; set; }

        public long CreatedAt { get; set; }

        // الشخص المطلوب منه الموافقة على الميتنج.
        public string RequestedToId { get; set; }

        // Pending = بانتظار الموافقة
        // Accepted = تمت الموافقة
        // Rejected = تم الرفض
        public string ApprovalState { get; set; }

        public long RespondedAt { get; set; }

        public Meeting()
        {
            ParticipantIds = new List<string>();

            Status = MeetingStatus.Scheduled;

            DurationMinutes = 30;

            CreatedAt = Time.NowMs();
        }

        // صاحب الطلب والمدعو فقط يستطيعان مشاهدة الميتنج.
        public bool CanBeViewedBy(string personId)
        {
            return !string.IsNullOrEmpty(personId)
                && (
                    personId == CreatedById
                    || personId == RequestedToId
                );
        }

        // وقت انتهاء الميتنج.
        public long EndsAt()
        {
            return ScheduledAt
                + (long)DurationMinutes * 60000L;
        }

        // الميتنج مقبول ولم يتم إلغاؤه أو إنهاؤه.
        public bool IsApproved()
        {
            return ApprovalState == "Accepted"
                && Status == MeetingStatus.Scheduled;
        }

        // هل يجب أن يظهر في الهيستوري؟
        public bool IsHistory(long now)
        {
            return Status != MeetingStatus.Scheduled
                || ApprovalState == "Rejected"
                || EndsAt() <= now;
        }

        // النص الذي يظهر للمستخدم حسب حالة الميتنج.
        public string DisplayStatus(long now)
        {
            if (Status == MeetingStatus.Cancelled)
            {
                return "Cancelled";
            }

            if (Status == MeetingStatus.Completed)
            {
                return "Completed";
            }

            if (ApprovalState == "Rejected")
            {
                return "Declined";
            }

            if (string.IsNullOrEmpty(ApprovalState))
            {
                return "Legacy meeting";
            }

            if (ApprovalState == "Pending")
            {
                return EndsAt() <= now
                    ? "Expired without approval"
                    : "Pending approval";
            }

            if (EndsAt() <= now)
            {
                return "Past - completion not recorded";
            }

            return ApprovalState == "Accepted"
                ? "Approved"
                : "Unavailable";
        }
    }
}