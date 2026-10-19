param([string]$JokersPng, [string]$OutDir)
# Builds reusable 1x templates from the vanilla Jimbo card (Jokers.png cell 0,0):
#   card_blank.png      - exact vanilla card silhouette, #BFC7D5 outline, white fill
#   card_mask.png       - same silhouette, opaque white (for clipping custom backgrounds)
#   joker_lettering.png - only the #4F6367 "JOKER" lettering (top-left + rotated bottom-right), transparent elsewhere
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
New-Item -ItemType Directory -Force $OutDir | Out-Null
$src = [System.Drawing.Bitmap]::FromFile($JokersPng)
$W = 71; $H = 95
$blank = New-Object System.Drawing.Bitmap($W, $H); $mask = New-Object System.Drawing.Bitmap($W, $H); $text = New-Object System.Drawing.Bitmap($W, $H)
$outline = [System.Drawing.Color]::FromArgb(255, 0xBF, 0xC7, 0xD5)
$slate = [System.Drawing.Color]::FromArgb(255, 0x4F, 0x63, 0x67)
function Opaque($x, $y) { if ($x -lt 0 -or $y -lt 0 -or $x -ge $W -or $y -ge $H) { return $false }; return $src.GetPixel($x, $y).A -eq 255 }
for ($y = 0; $y -lt $H; $y++) { for ($x = 0; $x -lt $W; $x++) {
    if (-not (Opaque $x $y)) { continue }
    $edge = -not ((Opaque ($x+1) $y) -and (Opaque ($x-1) $y) -and (Opaque $x ($y+1)) -and (Opaque $x ($y-1)))
    $blank.SetPixel($x, $y, $(if ($edge) { $outline } else { [System.Drawing.Color]::White }))
    $mask.SetPixel($x, $y, [System.Drawing.Color]::White)
    $c = $src.GetPixel($x, $y)
    $inText = (($x -le 13 -and $y -le 56) -or ($x -ge 57 -and $y -ge 38))
    if ($inText -and $c.ToArgb() -eq $slate.ToArgb()) { $text.SetPixel($x, $y, $slate) }
} }
$src.Dispose()
$blank.Save("$OutDir\card_blank.png"); $mask.Save("$OutDir\card_mask.png"); $text.Save("$OutDir\joker_lettering.png")
$blank.Dispose(); $mask.Dispose(); $text.Dispose()

