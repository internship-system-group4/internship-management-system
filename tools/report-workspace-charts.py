"""Collect only completed local chart/typography verification outputs."""
import json
import re
from pathlib import Path

results = {}
for name in ('functional', 'routes', 'workflows', 'captures', 'motion'):
    path = Path(f'tests/artifacts/charts-{name}.txt')
    match = re.search(r'^### Result\s*\n(\{[^\n]+\})', path.read_text(encoding='utf-8-sig'), re.M)
    if not match:
        raise SystemExit(f'No completed result in {path}')
    results[name] = json.loads(match[1])
    Path(f'tests/artifacts/charts-{name}-results.json').write_text(json.dumps(results[name], indent=2) + '\n', encoding='utf-8')
report = {'date': '2026-10-23', 'environment': 'Disposable Web Forms host + local Postman dependencies; no live verification',
          'results': results, 'rolesWithCharts': ['Student', 'Company', 'Academic', 'Coordinator'],
          'chartViewsByRole': {'Student': 3, 'Company': 2, 'Academic': 2, 'Coordinator': 3}}
Path('docs/workspace-charts-verification.json').write_text(json.dumps(report, indent=2) + '\n', encoding='utf-8')
print(json.dumps({'checks': {k: v.get('passed') for k, v in results.items() if 'passed' in v},
                  'routeFiles': len({r['route'].split('?')[0] for r in results['routes']['routes']}),
                  'routeVisits': len(results['routes']['routes']), 'extraCaptures': results['captures']['captures']}))
