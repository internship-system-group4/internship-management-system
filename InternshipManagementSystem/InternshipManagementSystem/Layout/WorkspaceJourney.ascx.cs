using System.Web.UI;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Layout
{
    public partial class WorkspaceJourney : UserControl
    {
        public WorkspaceJourneyData Model { get; set; }
        protected string DialogId { get { return ClientID + "_dialog"; } }
    }
}
