using System.Linq;
using System.Web.UI;
using Newtonsoft.Json;
using InternshipManagementSystem.Data;
namespace InternshipManagementSystem.Layout {
 public partial class WorkspaceChart : UserControl {
  public WorkspaceChartData Model {get;set;}
  protected string SafeJson {get{return JsonConvert.SerializeObject(Model,new JsonSerializerSettings{StringEscapeHandling=StringEscapeHandling.EscapeHtml});}}
  // Opt-in layout used by the coordinator's Students by Major chart; every other dashboard keeps the vertical bars.
  protected bool Horizontal {get{return Model!=null&&Model.BarLayout=="horizontal";}}
  protected string Share(long value){long total=Model==null||Model.Bars==null?0:Model.Bars.Sum(b=>b.Value);return total<=0?"—":(value*100.0/total).ToString("0.#",System.Globalization.CultureInfo.InvariantCulture)+"%";}
 }
}
