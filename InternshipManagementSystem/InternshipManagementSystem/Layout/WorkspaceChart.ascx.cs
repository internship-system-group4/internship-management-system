using System.Web.UI;
using Newtonsoft.Json;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Layout {
 public partial class WorkspaceChart : UserControl {
  public WorkspaceChartData Model {get;set;}
  protected string SafeJson {get{return JsonConvert.SerializeObject(Model,new JsonSerializerSettings{StringEscapeHandling=StringEscapeHandling.EscapeHtml});}}
 }
}
