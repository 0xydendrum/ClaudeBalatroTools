param([string]$In, [int]$X, [int]$Y, [int]$W, [int]$H, [int]$Scale = 4, [string]$Out)
# Crop a region of a sprite sheet and upscale it with nearest-neighbour, on a grey checker so transparency is visible.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile($In)
if ($W -le 0) { $W = $src.Width - $X }
if ($H -le 0) { $H = $src.Height - $Y }
$W = [Math]::Min($W, $src.Width - $X); $H = [Math]::Min($H, $src.Height - $Y)
$dst = New-Object System.Drawing.Bitmap(($W * $Scale), ($H * $Scale))
$g = [System.Drawing.Graphics]::FromImage($dst)
$c1 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 70, 70, 80))
$c2 = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 90, 90, 100))
$t = 8 * $Scale
for ($yy = 0; $yy -lt $dst.Height; $yy += $t) { for ($xx = 0; $xx -lt $dst.Width; $xx += $t) {
    $b = if ((($xx + $yy) / $t) % 2 -eq 0) { $c1 } else { $c2 }; $g.FillRectangle($b, $xx, $yy, $t, $t) } }
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$g.DrawImage($src, (New-Object System.Drawing.Rectangle(0, 0, $dst.Width, $dst.Height)), (New-Object System.Drawing.Rectangle($X, $Y, $W, $H)), [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose(); $src.Dispose()
$dst.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png); $dst.Dispose()
