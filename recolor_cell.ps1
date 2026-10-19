param([string]$Sheet, [int]$CX, [int]$CY, [string[]]$Map, [string]$Out, [int]$CW = 71, [int]$CH = 95)
# Copy one cell out of a sprite sheet, swapping exact colours. -Map "FE5F55=8867A5","FFFFFF=FFFFFF"
# Unmapped colours and alpha (including the hidden RGB of transparent pixels) are kept as-is.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$swap = @{}
foreach ($m in $Map) { $from, $to = $m.ToUpper().TrimStart('#') -split '=#?'; $swap[[Convert]::ToInt32($from, 16)] = [Convert]::ToInt32($to, 16) }
$src = [System.Drawing.Bitmap]::FromFile($Sheet)
$o = New-Object System.Drawing.Bitmap($CW, $CH, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$hits = 0
for ($y = 0; $y -lt $CH; $y++) { for ($x = 0; $x -lt $CW; $x++) {
    $c = $src.GetPixel($CX * $CW + $x, $CY * $CH + $y)
    $rgb = $c.ToArgb() -band 0xFFFFFF
    if ($c.A -eq 255 -and $swap.ContainsKey($rgb)) { $n = $swap[$rgb]; $c = [System.Drawing.Color]::FromArgb(255, ($n -shr 16) -band 255, ($n -shr 8) -band 255, $n -band 255); $hits++ }
    $o.SetPixel($x, $y, $c) } }
$src.Dispose()
New-Item -ItemType Directory -Force (Split-Path $Out) | Out-Null
$o.Save($Out, [System.Drawing.Imaging.ImageFormat]::Png); $o.Dispose()
"recoloured $hits px -> $Out"
