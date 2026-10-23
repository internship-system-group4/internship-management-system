# Rocketbox seated-figure converter (development only)

Converts Microsoft Rocketbox avatars (MIT) into the static seated GLBs in
`InternshipManagementSystem/InternshipManagementSystem/Assets/models/people/`. Nothing here is deployed.

## Inputs (not committed)

Download the files below from https://github.com/microsoft/Microsoft-Rocketbox, keeping the repository paths, into a
scratch folder outside the project:

- `Assets/Avatars/Adults/<name>/Export/<name>.fbx` and its `Textures/*_body_color.tga`, `*_head_color.tga`
  and `*_opacity_color.tga` (when present)
- `Assets/Animations/all_animations_max_motextr_static/f_sit_table_idle_neutral_01.max.fbx` and `m_sit_table_idle_neutral_01.max.fbx`

`vendor/` holds unchanged three@0.180.0 example modules (MIT) from jsDelivr: FBXLoader, TGALoader, fflate,
NURBSCurve, NURBSUtils and GLTFExporter.

## Run

Serve two roots from one localhost server: `/repo` for this repository and `/raw` for the scratch downloads.
Then open `/repo/tools/rocketbox/convert.html` and call `converter.download('<avatar>')` for each avatar.
Save each download as `Assets/models/people/<avatar>.glb`. `converter.preview(url)` renders a saved GLB.

The seated frames (female 1.5 s, male 12 s) were chosen by sampling the clips for an upright posture with the
forearms on the desk. The hall places the desk's near edge 12 cm in front of the pelvis to match.
