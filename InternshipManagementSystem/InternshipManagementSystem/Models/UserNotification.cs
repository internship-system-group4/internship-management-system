namespace InternshipManagementSystem.Models
{
    public class UserNotification
    {
        public string Id { get; set; }
        public string RecipientId { get; set; }
        public string SenderId { get; set; }
        public string Title { get; set; }
        public string Detail { get; set; }
        public string Page { get; set; }
        public string Message { get; set; }
        public string Link { get; set; }
        public string Type { get; set; }
        public long CreatedAt { get; set; }
        public bool IsRead { get; set; }
        public string EmailStatus { get; set; }
    }
}
