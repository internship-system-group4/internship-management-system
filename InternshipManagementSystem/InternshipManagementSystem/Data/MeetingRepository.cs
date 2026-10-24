using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using InternshipManagementSystem.Common;
using InternshipManagementSystem.Models;

namespace InternshipManagementSystem.Data
{
    public class MeetingRepository : NotifyingRepositoryBase<Meeting>
    {
        protected override string Collection
        {
            get
            {
                return Constants.Paths.Meetings;
            }
        }

        protected override void SetId(Meeting entity, string id)
        {
            entity.Id = id;
        }

        // تحميل الميتنجات التي أنشأها المستخدم
        // أو التي تم إرسالها إليه فقط.
        public List<Meeting> GetMine(string personId)
        {
            if (string.IsNullOrEmpty(personId))
            {
                return new List<Meeting>();
            }

            return GetWhere("CreatedById", personId)
                .Concat(GetWhere("RequestedToId", personId))
                .GroupBy(meeting => meeting.Id)
                .Select(group => group.First())
                .Where(meeting => meeting.CanBeViewedBy(personId))
                .OrderByDescending(meeting => meeting.ScheduledAt)
                .ToList();
        }

        public override string Insert(Meeting entity)
        {
            var actor =
                InternshipManagementSystem.Security.SessionHelper.Current;

            if (actor == null)
            {
                throw new InvalidOperationException(
                    "Please sign in again.");
            }

            return CreateRequest(entity, actor.Id);
        }

        // إنشاء طلب جديد بانتظار موافقة المدعو.
        public string CreateRequest(
            Meeting meeting,
            string actorId)
        {
            if (meeting == null
                || string.IsNullOrEmpty(actorId)
                || meeting.CreatedById != actorId
                || meeting.RequestedToId == actorId
                || string.IsNullOrEmpty(meeting.RequestedToId))
            {
                throw new InvalidOperationException(
                    "Choose another person to invite.");
            }

            UserRepository users = new UserRepository();
            Person requester = users.GetPerson(actorId);
            Person person = users.GetPerson(meeting.RequestedToId);
            Placement meetingPlacement;

            if (requester == null || !requester.CanLogin() ||
                requester.Id != actorId || person == null || !person.CanLogin())
            {
                throw new InvalidOperationException("This account is unavailable.");
            }

            if (!IsAllowedMeetingPair(requester, person, out meetingPlacement))
            {
                throw new InvalidOperationException(
                    "You can only request meetings with students or supervisors assigned to your account.");
            }

            meeting.PlacementId = meetingPlacement == null ? "" : meetingPlacement.Id;

            if (string.IsNullOrWhiteSpace(meeting.Title)
                || meeting.Title.Length > 150
                || (meeting.Agenda ?? "").Length > 3000)
            {
                throw new InvalidOperationException(
                    "Check the title and agenda lengths.");
            }

            if (meeting.ScheduledAt <= Time.NowMs())
            {
                throw new InvalidOperationException(
                    "Choose a future date and time.");
            }

            if (!new[] { 15, 30, 45, 60 }
                .Contains(meeting.DurationMinutes))
            {
                throw new InvalidOperationException(
                    "Choose a valid duration.");
            }

            if (string.IsNullOrEmpty(meeting.Id))
            {
                meeting.Id = Guid.NewGuid().ToString("N");
            }

            if (!System.Text.RegularExpressions.Regex.IsMatch(
                meeting.Id,
                "^[a-f0-9]{32}$"))
            {
                throw new InvalidOperationException(
                    "Invalid request identifier. Refresh the page.");
            }

            meeting.Agenda = meeting.Agenda ?? "";

            meeting.ParticipantIds = new List<string>
            {
                meeting.RequestedToId
            };

            meeting.ApprovalState = "Pending";

            meeting.Status = MeetingStatus.Scheduled;

            meeting.RespondedAt = 0;

            // غرفة مستقلة لكل طلب.
            meeting.JoinUrl =
                "https://meet.jit.si/UIMS-" + meeting.Id;

            meeting.CreatedAt = Time.NowMs();

            // نفس إرسال النموذج يستخدم نفس المفتاح،
            // لمنع إنشاء طلب مكرر عند إعادة الإرسال.
            bool created = FirebaseContext.PutIfEmpty(
                Collection + "/" + meeting.Id,
                meeting);

            if (!created)
            {
                Meeting existing = GetById(meeting.Id);

                if (existing == null
                    || existing.CreatedById != actorId)
                {
                    throw new InvalidOperationException(
                        "Could not save the request. Refresh and try again.");
                }

                return existing.Id;
            }

            Notify(
                meeting,
                actorId,
                meeting.RequestedToId,
                "New meeting request",
                "You have a meeting request: " + meeting.Title);

            return meeting.Id;
        }

        private static bool IsAllowedMeetingPair(
            Person requester,
            Person recipient,
            out Placement matchedPlacement)
        {
            matchedPlacement = null;
            PlacementRepository placements = new PlacementRepository();
            Student recipientStudent = recipient as Student;
            CompanySupervisor requesterCompany = requester as CompanySupervisor;
            if (requesterCompany != null && recipientStudent != null)
            {
                Placement placement = placements.GetById(recipientStudent.Id);
                if (!IsCurrentPlacement(placement) || placement.StudentId != recipientStudent.Id ||
                    placement.CompanyId != requesterCompany.CompanyId) return false;
                matchedPlacement = placement;
                return true;
            }

            AcademicSupervisor requesterAcademic = requester as AcademicSupervisor;
            if (requesterAcademic != null && recipientStudent != null)
            {
                Placement placement = placements.GetById(recipientStudent.Id);
                bool assigned = recipientStudent.AcademicSupervisorId == requesterAcademic.Id ||
                    (IsCurrentPlacement(placement) && placement.AcademicSupervisorId == requesterAcademic.Id);
                if (!assigned) return false;
                matchedPlacement = IsCurrentPlacement(placement) ? placement : null;
                return true;
            }

            Student requesterStudent = requester as Student;
            if (requesterStudent != null)
            {
                Placement placement = placements.GetById(requesterStudent.Id);
                bool hasCurrentPlacement = IsCurrentPlacement(placement) &&
                    placement.StudentId == requesterStudent.Id;

                AcademicSupervisor academicRecipient = recipient as AcademicSupervisor;
                if (academicRecipient != null)
                {
                    bool assigned = requesterStudent.AcademicSupervisorId == academicRecipient.Id ||
                        (hasCurrentPlacement && placement.AcademicSupervisorId == academicRecipient.Id);
                    if (!assigned) return false;
                    matchedPlacement = hasCurrentPlacement ? placement : null;
                    return true;
                }

                CompanySupervisor companyRecipient = recipient as CompanySupervisor;
                if (companyRecipient != null && hasCurrentPlacement &&
                    placement.CompanySupervisorId == companyRecipient.Id &&
                    placement.CompanyId == companyRecipient.CompanyId)
                {
                    matchedPlacement = placement;
                    return true;
                }
            }

            // Coordinators and unrelated roles cannot create meeting requests.
            return false;
        }

        private static bool IsCurrentPlacement(Placement placement)
        {
            return placement != null &&
                (placement.Status == PlacementStatus.Confirmed ||
                 placement.Status == PlacementStatus.Active ||
                 placement.Status == PlacementStatus.AwaitingCompletion);
        }

        // تنفيذ الموافقة أو الرفض أو الإنهاء أو الإلغاء.
        public void ApplyAction(
            string id,
            string actorId,
            string action)
        {
            string etag;

            string raw = FirebaseContext.GetWithEtag(
                Collection + "/" + id,
                out etag);

            Meeting meeting = Json.Deserialize<Meeting>(raw);

            if (meeting == null
                || !meeting.CanBeViewedBy(actorId))
            {
                throw new InvalidOperationException(
                    "Meeting not found or access denied.");
            }

            long now = Time.NowMs();

            string recipient;
            string title;

            if (action == "Accept" || action == "Reject")
            {
                // المدعو فقط يستطيع الرد،
                // طالما الطلب معلق ولم تنتهِ مدة الميتنج.
                if (meeting.RequestedToId != actorId
                    || meeting.ApprovalState != "Pending"
                    || meeting.Status != MeetingStatus.Scheduled
                    || meeting.EndsAt() <= now)
                {
                    throw new InvalidOperationException(
                        "This request is no longer awaiting your response.");
                }

                meeting.ApprovalState =
                    action == "Accept"
                        ? "Accepted"
                        : "Rejected";

                meeting.RespondedAt = now;

                recipient = meeting.CreatedById;

                title = action == "Accept"
                    ? "Meeting accepted"
                    : "Meeting declined";
            }
            else if (action == "Complete")
            {
                // صاحب الطلب فقط يسجل اكتمال الميتنج
                // بعد بداية موعده، بشرط أن يكون مقبولًا.
                if (meeting.CreatedById != actorId
                    || !meeting.IsApproved()
                    || meeting.ScheduledAt > now)
                {
                    throw new InvalidOperationException(
                        "Only the requester can complete an approved meeting after its start.");
                }

                meeting.Status = MeetingStatus.Completed;

                recipient = meeting.RequestedToId;

                title = "Meeting marked completed";
            }
            else if (action == "Cancel")
            {
                // صاحب الطلب يستطيع إلغاء الطلب المعلق
                // أو الميتنج المقبول قبل انتهاء مدته.
                if (meeting.CreatedById != actorId
                    || meeting.Status != MeetingStatus.Scheduled
                    || (
                        meeting.ApprovalState != "Pending"
                        && meeting.ApprovalState != "Accepted"
                    )
                    || meeting.EndsAt() <= now)
                {
                    throw new InvalidOperationException(
                        "This meeting can no longer be cancelled.");
                }

                meeting.Status = MeetingStatus.Cancelled;

                recipient = meeting.RequestedToId;

                title = "Meeting cancelled";
            }
            else
            {
                throw new InvalidOperationException(
                    "Unsupported meeting action.");
            }

            // يمنع استبدال قرار أحدث إذا حصل تعديل متزامن.
            bool updated = FirebaseContext.PutIfUnchanged(
                Collection + "/" + id,
                meeting,
                etag);

            if (!updated)
            {
                throw new InvalidOperationException(
                    "The meeting changed. Refresh and try again.");
            }

            Notify(
                meeting,
                actorId,
                recipient,
                title,
                title + ": " + meeting.Title);
        }

        // إرسال إشعار مرتبط بالميتنج للطرف الآخر.
        private void Notify(
            Meeting meeting,
            string actorId,
            string recipientId,
            string title,
            string message)
        {
            Services.NotificationService.Send(recipientId, "Meeting", title, message, "~/Pages/Meetings/MyMeetings.aspx");
        }
    }
}

