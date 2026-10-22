# Creates the small team photos used by Pages/Public/PoweredBy.aspx.
# Originals in Assets/images/team/ stay untouched; each becomes a square JPEG in
# Assets/images/team/small/ with the same base name. The page uses the small copy when
# it exists and falls back to the original otherwise. Re-run after adding a photo.
param([int]$Size = 240, [int]$Quality = 84)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$team = Join-Path (Split-Path $PSScriptRoot -Parent) 'InternshipManagementSystem/InternshipManagementSystem/Assets/images/team'
$small = Join-Path $team 'small'
New-Item -ItemType Directory -Force $small | Out-Null
$jpeg = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$parameters = New-Object System.Drawing.Imaging.EncoderParameters 1
$parameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter ([System.Drawing.Imaging.Encoder]::Quality), ([long]$Quality)
Get-ChildItem $team -File | Where-Object { $_.Extension -match '^\.(png|jpe?g)$' } | ForEach-Object {
    $source = [System.Drawing.Image]::FromFile($_.FullName)
    try {
        # Centre-crop to a square, then flatten onto white so transparent areas do not turn black.
        $side = [Math]::Min($source.Width, $source.Height)
        $crop = New-Object System.Drawing.Rectangle ([int](($source.Width - $side) / 2)), ([int](($source.Height - $side) / 2)), $side, $side
        $target = New-Object System.Drawing.Bitmap $Size, $Size
        $graphics = [System.Drawing.Graphics]::FromImage($target)
        $graphics.Clear([System.Drawing.Color]::White)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
        $graphics.DrawImage($source, (New-Object System.Drawing.Rectangle 0, 0, $Size, $Size), $crop, [System.Drawing.GraphicsUnit]::Pixel)
        $output = Join-Path $small ($_.BaseName + '.jpg')
        $target.Save($output, $jpeg, $parameters)
        $graphics.Dispose(); $target.Dispose()
        [pscustomobject]@{ Photo = $_.Name; OriginalKB = [int]($_.Length / 1KB); SmallKB = [int]((Get-Item $output).Length / 1KB) }
    }
    finally { $source.Dispose() }
}
