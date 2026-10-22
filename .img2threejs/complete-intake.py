import json,subprocess,sys
from pathlib import Path
r=Path.cwd();d=r/'.img2threejs';skill=Path('C:/Users/user/.codex/skills/img2threejs');s=json.loads((d/'waterwheel-spec.json').read_text())
for id in ['stone','timber']:
 subprocess.run([sys.executable,str(skill/'forge/stage1_intake/extract_pbr_evidence.py'),str(d/(id+'-crop.png')),'--out-dir',str(d/('pbr-'+id)),'--material-id',id,'--multi-view-reference','--spec',str(d/'waterwheel-spec.json'),'--in-place','--size','256'],check=True,stdout=subprocess.DEVNULL)
s=json.loads((d/'waterwheel-spec.json').read_text());s['preSpecAssessment']['unknownsToResolveBeforeImplementation']=[]
s['lightingFromPhoto']=['Key directional warm sunlight (7,11,8), intensity 2.3; shadows 1024 PCF soft contact shadow.','Sky/ground hemisphere fill .9 with cool sky and muted warm ground.','Environment pale blue-gray, ACES tone mapping exposure 1.05; no HDR download.']
for c in s['componentTree']:
 col=c['colorMaterialRecipe']['baseColor'];rgb=tuple(int(col[i:i+2],16) for i in (1,3,5));c['colorMaterialRecipe'].update(dominantAlbedo='rgba(%d, %d, %d, 1)'%rgb,secondaryAlbedo='rgba(%d, %d, %d, 1)'%tuple(max(0,n-15) for n in rgb),materialClass={'timber':'wood','tile':'ceramic','water':'glass','glass':'glass','stone':'stone','metal':'metal'}[c['material']],materialClassConfidence=.8)
 if c['parent']:c['attachment']={'parentSocket':c['parent']+'-mount','localStart':[0,0,0],'localEnd':[0,.1,0],'contactType':'overlap','overlap':.02,'embedDepth':.02,'gapTolerance':.03}
for m in s['materials']:
 if m['id'] not in ['stone','timber']:m['qualityTier']='utility';m['notes']='Simplified contextual material, not a reference-exact surface reconstruction.'
(d/'waterwheel-spec.json').write_text(json.dumps(s,indent=2),encoding='utf-8')
for step,ev in [('image-analysis','intake.md'),('reference-suitability','intake.md'),('reference-admission','admission.json'),('local-spec-search','assessment.json'),('pre-spec-assessment','assessment.json'),('detail-inventory','waterwheel-spec.json'),('spec-authoring','waterwheel-spec.json'),('material-evidence','pbr-stone/stone_pbr_report.json'),('material-spec-wiring','waterwheel-spec.json')]:
 evidence=d/ev
 if not evidence.exists():evidence=d/'waterwheel-spec.json'
 subprocess.run([sys.executable,str(skill/'forge/state.py'),'mark',step,'--state',str(d/'state.json'),'--evidence',str(evidence)],check=True,stdout=subprocess.DEVNULL)
subprocess.run([sys.executable,str(skill/'forge/state.py'),'mark','projection-route','--state',str(d/'state.json'),'--status','skipped','--reason','No painted graphic or exact pixel-pattern requested; procedural approximations documented in intake.'],check=True,stdout=subprocess.DEVNULL)
