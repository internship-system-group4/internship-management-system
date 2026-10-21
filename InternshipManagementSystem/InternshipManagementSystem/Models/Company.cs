// =============================================================================
//  UIMS - Group 4   |   Owner: Ahmad (Trello card X02 - shared data model)
//  A company that offers internships.
//  Add fields freely; never rename or delete one without telling the team.
// =============================================================================

namespace InternshipManagementSystem.Models
{
    public class Company
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Industry { get; set; }
        public string Website { get; set; }
        public string Address { get; set; }
        public string ContactEmail { get; set; }
        public string ContactPhone { get; set; }
        public string LogoUrl { get; set; }
        public bool IsActive { get; set; }
        public long CreatedAt { get; set; }

        public Company()
        {
            IsActive = true;
            CreatedAt = Common.Time.NowMs();
        }
    }
}
