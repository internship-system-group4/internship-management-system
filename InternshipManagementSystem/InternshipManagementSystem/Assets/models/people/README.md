# Seated people for the Powered by lecture hall

Source: Microsoft Rocketbox avatar library, https://github.com/microsoft/Microsoft-Rocketbox
Licence: MIT (Copyright (c) 2020 Microsoft). See LICENSE.md in this folder.

Each GLB is one Rocketbox adult avatar (`Assets/Avatars/Adults/<name>`), frozen in a frame of
Rocketbox's own seated-at-table motion (`f_sit_table_idle_neutral_01` at 1.5 s for female avatars,
`m_sit_table_idle_neutral_01` at 12 s for male avatars). Each figure is a static mesh with 512 px
textures, in metres, facing +z, with the feet on y = 0 and the pelvis over the origin.

Avatars: Female_Adult_04, 06, 08, 09, 14 and Male_Adult_06, 09, 11, 17, 18.
Changes from the originals: posed, skinning baked, vertices welded, textures downscaled
(hair opacity kept in the PNG alpha). Normal and specular maps are not used.

Regenerate with tools/rocketbox (see its README). Team members are shown with these same generic
figures, chosen by seat; they are not likenesses of anyone.

# Animated student for the Jisr homepage

`Male_Adult_17_Animated.glb` is the Rocketbox avatar `Male_Adult_17` (MIT, same source and licence as
above) kept as a skinned mesh with its full skeleton and three Rocketbox motion-capture clips:
`walk` (`m_walk_neutral_01`, root motion removed, 1.215 m per 1.2 s cycle), `stop` (`m_walk_stop`) and
`look` (`m_idle_look_around_01`). Metres, facing +z, feet on y = 0; 1024 px colour and normal maps.
Scale tracks were dropped and redundant keys removed to keep the file at about 3.2 MB.
Regenerate with `tools/rocketbox/convert-animated.html` (see tools/rocketbox/README.md).

## Login checkpoint reuse

The login scene reuses this same animated GLB for two fictional adults with independent
80-bone skeletons. The guard has a navy fabric shader and small cap/radio/badge accessories;
skin and face textures retain their original treatment. Distance-driven walking, gaze and
two-bone arm posing adapt the existing clips for a fictional university ID-reader interaction.
No new third-party character assets were downloaded. These are generic characters, not
likenesses of university staff or students. The existing MIT licence remains applicable.

## Web build (`Male_Adult_17_Animated.web.glb`)

The Login checkpoint and the Jisr homepage load `Male_Adult_17_Animated.web.glb`, derived from the file above by
`python -I tools/rocketbox/optimize-animated.py` (3.24 MB -> 1.46 MB). Same avatar, skeleton and `walk`/`look` motion:
- the unused `stop` clip is dropped;
- normals, UVs, skin weights/joints and rotation keyframes are stored as normalized integers (`KHR_mesh_quantization`,
  read natively by three.js GLTFLoader: no decoder download, no extra decode step);
- colour and normal maps are downscaled from 1024 to 512 px JPEG (quality 88).
Positions and indices are unchanged. The original file is kept as the conversion source. The MIT licence above applies
unchanged to the derived file. Never overwrite either file in place: `Assets/models` is served with a 30-day browser
cache (Web.config), so a changed model needs a new file name.
