param([string]$In1x, [string]$Out2x)
# Balatro's 2x textures are exactly 1x with every pixel doubled (verified on vanilla sheets).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$s = [System.Drawing.Bitmap]::FromFile($In1x)
$d = New-Object System.Drawing.Bitmap(($s.Width * 2), ($s.Height * 2), [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
for ($y = 0; $y -lt $s.Height; $y++) { for ($x = 0; $x -lt $s.Width; $x++) {
    $c = $s.GetPixel($x, $y)
    $d.SetPixel(2*$x, 2*$y, $c); $d.SetPixel(2*$x+1, 2*$y, $c); $d.SetPixel(2*$x, 2*$y+1, $c); $d.SetPixel(2*$x+1, 2*$y+1, $c) } }
$s.Dispose()
New-Item -ItemType Directory -Force (Split-Path $Out2x) | Out-Null
$d.Save($Out2x, [System.Drawing.Imaging.ImageFormat]::Png); $d.Dispose()
