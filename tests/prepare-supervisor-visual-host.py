"""Populate display-only states in a disposable IIS copy. Never run against the application checkout."""
import json, os, re, tempfile
from pathlib import Path

host = Path(json.loads(Path('tests/artifacts/supervisor-host.json').read_text(encoding='utf-8-sig'))['TestRoot']).resolve()
temp = Path(tempfile.gettempdir()).resolve()
if host.parent != temp or not host.name.startswith('uims-o01-') or not (host/'__fixture.aspx').exists():
    raise SystemExit('Expected a disposable uims-o01-* host under the temporary directory')

opportunity = '''new Opportunities.CompanyOpportunity {
 Id="visual-opportunity-one", CompanyId="company-one", CompanyName="Synthetic UI company",
 Title="Software engineering internship", Description="A synthetic opportunity used only to verify readable layouts, complete action labels, and form spacing. " + new string('x', 180),
 Requirements="Programming fundamentals.\\nTeamwork and clear communication.", Location="Amman, Jordan", Department="Engineering",
 EligibleCollege=Constants.CollegeName, EligibleMajors=new List<string>{"Computer Science", "Computer Engineering"},
 TotalSeats=10, FilledSeats=2, DurationWeeks=12, StartDate=Time.NowMs()+86400000, EndDate=Time.NowMs()+864000000,
 ApplicationDeadline=Time.NowMs()+86400000, Status=OpportunityStatus.Open, TrainingMode="Hybrid", TechnologiesUsed="C#, ASP.NET, JavaScript"
}'''

def insert(relative, method, code):
    p=host/relative
    text=p.read_text(encoding='utf-8-sig')
    marker='// SUPERVISOR_VISUAL_FIXTURE_ONLY'
    pattern=r'('+method+r'\s*\{)'
    match=re.search(pattern,text)
    if match and marker in text[match.end():match.end()+100]: return
    text,n=re.subn(pattern,lambda m:m[1]+'\n'+marker+'\n'+code+'\n',text,count=1)
    if n!=1: raise SystemExit('Fixture insertion point not found: '+relative)
    p.write_text(text,encoding='utf-8-sig')

insert('Pages/Company/ManageOpportunities.aspx.cs',r'protected void Page_Load\(object sender, EventArgs e\)', '''
if(Request.QueryString["ui-visual-fixture"]=="1") {
 var sample='''+opportunity+''';
 OpportunityItems=new List<Opportunity>{sample,
 new Opportunity{Id="visual-draft",Title="Data analysis internship",CompanyId="company-one",Status=OpportunityStatus.Draft,TotalSeats=4,EligibleMajors=new List<string>{"Computer Science"}},
 new Opportunity{Id="visual-closed",Title="Frontend development internship",CompanyId="company-one",Status=OpportunityStatus.Closed,TotalSeats=3,EligibleMajors=new List<string>{"Computer Engineering"}}};
 OpenCount=DraftCount=ClosedCount=1;
 if(!string.IsNullOrEmpty(Request.QueryString["edit"]))Editing=sample;
 return;
}''')
insert('Pages/Company/ViewOpportunity.aspx.cs',r'protected void Page_Load\(object sender, EventArgs e\)', '''
if(Request.QueryString["ui-visual-fixture"]=="1") { Item='''+opportunity.replace('new List<string>','new System.Collections.Generic.List<string>')+''';return;}
''')
insert('Pages/Meetings/MyMeetings.aspx.cs',r'protected void Page_Load\(object sender, EventArgs e\)', '''
if(Request.QueryString["ui-visual-fixture"]=="1"&&!IsPostBack) {
 Recipient.Items.Clear();Recipient.Items.Add(new ListItem("Select a person", ""));Recipient.Items.Add(new ListItem("Synthetic linked contact", "visual-person"));
 SendRequest.Enabled=true;var initialView=MeetingFilter.Items.FindByValue(Request.QueryString["view"]??"all");if(initialView!=null)MeetingFilter.SelectedValue=initialView.Value;BindMeetings();
 DetailTitle.Text="Internship progress review";DetailPeople.Text="Synthetic student / supervisor";DetailTime.Text="25 Oct 2026, 15:00 (Jordan time) - 45 minutes";DetailState.Text="Approved";DetailAgenda.Text="Review training progress and discuss the next tasks.";
 return;
}''')
insert('Pages/Meetings/MyMeetings.aspx.cs',r'private void BindMeetings\(\)', '''
if(Request.QueryString["ui-visual-fixture"]=="1") {
 IncomingCount.Text="1";SentCount.Text="1";UpcomingCount.Text="1";HistoryCount.Text="1";
 MeetingGrid.DataSource=new[]{
 new {Id="visual-approved",Title="Internship progress review",FromName="Synthetic student",ToName="Synthetic supervisor",DateText="25 Oct 2026, 15:00",DurationText="45 min",StateText="Approved",ViewGroups="all upcoming",MatchesView=MeetingFilter.SelectedValue=="all"||MeetingFilter.SelectedValue=="upcoming",CanRespond=false,CanJoin=false,CanComplete=false,CanCancel=true},
 new {Id="visual-pending",Title="Discuss task feedback",FromName="أحمد الحسن",ToName="Synthetic student",DateText="26 Oct 2026, 10:30",DurationText="30 min",StateText="Pending",ViewGroups="all incoming",MatchesView=MeetingFilter.SelectedValue=="all"||MeetingFilter.SelectedValue=="incoming",CanRespond=true,CanJoin=false,CanComplete=false,CanCancel=false},
 new {Id="visual-sent",Title="Planning next steps",FromName="Synthetic supervisor",ToName="Synthetic student",DateText="27 Oct 2026, 10:30",DurationText="30 min",StateText="Pending",ViewGroups="all sent",MatchesView=MeetingFilter.SelectedValue=="all"||MeetingFilter.SelectedValue=="sent",CanRespond=false,CanJoin=false,CanComplete=false,CanCancel=true},
 new {Id="visual-history",Title="Weekly follow-up",FromName="Synthetic student",ToName="Synthetic supervisor",DateText="20 Oct 2026, 11:00",DurationText="30 min",StateText="Completed",ViewGroups="all history",MatchesView=MeetingFilter.SelectedValue=="all"||MeetingFilter.SelectedValue=="history",CanRespond=false,CanJoin=false,CanComplete=false,CanCancel=false}};
 MeetingGrid.DataBind();return;
}''')
print('Display fixtures installed only in '+str(host))
