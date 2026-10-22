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
