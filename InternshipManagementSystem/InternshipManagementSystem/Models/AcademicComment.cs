namespace InternshipManagementSystem.Models
{
    public class AcademicComment
    {
        public string Id { get; set; }
        public string PlacementId { get; set; }
        public string StudentId { get; set; }
        public string AcademicSupervisorId { get; set; }
        public string Comment { get; set; }
        public bool IsVisibleToStudent { get; set; }
        public long CreatedAt { get; set; }

        public AcademicComment()
        {
            CreatedAt = Common.Time.NowMs();
        }
    }
}
