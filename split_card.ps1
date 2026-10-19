param([string]$Sheet, [int]$AX, [int]$AY, [int]$BX, [int]$BY, [string]$Mode, [int]$SplitX = 35, [string]$Out)
# Composite two 71x95 cells from a sheet: left of the split line comes from cell A, right from cell B.
# Mode: straight | seam (white 1px seam where both sides are background) | zigzag (seam follows a zigzag)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Bitmap]::FromFile($Sheet)
$W = 71; $H = 95
function Cell($cx, $cy) { $b = New-Object System.Drawing.Bitmap($W, $H); for ($y=0;$y -lt $H;$y++){ for ($x=0;$x -lt $W;$x++){ $b.SetPixel($x,$y,$src.GetPixel($cx*$W+$x, $cy*$H+$y)) } }; $b }
$A = Cell $AX $AY; $B = Cell $BX $BY; $src.Dispose()
# Background = the two most common colours in each cell (the two-tone suit pattern)
function TopColours($bmp) { $hist=@{}; for ($y=4;$y -lt $H-4;$y++){ for ($x=4;$x -lt $W-4;$x++){ $k=$bmp.GetPixel($x,$y).ToArgb(); $hist[$k]=1+$hist[$k] } }; ($hist.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 2).Key }
$bgA = TopColours $A; $bgB = TopColours $B
function SplitAt($y) {
    if ($Mode -eq 'zigzag') { $p = $y % 8; return $SplitX + $(if ($p -lt 4) { $p - 2 } else { 6 - $p - 2 }) }
    return $SplitX }
$white = [System.Drawing.Color]::White
$o = New-Object System.Drawing.Bitmap($W, $H)
for ($y=0;$y -lt $H;$y++){ $s = SplitAt $y; for ($x=0;$x -lt $W;$x++){
    $c = if ($x -lt $s) { $A.GetPixel($x,$y) } else { $B.GetPixel($x,$y) }
    if ($Mode -ne 'straight' -and $x -eq $s -and $y -ge 3 -and $y -le $H-4) {
        $isBg = ($bgA -contains $A.GetPixel($x,$y).ToArgb()) -and ($bgB -contains $B.GetPixel($x,$y).ToArgb())
        if ($isBg) { $c = $white } }
    $o.SetPixel($x,$y,$c) } }
$o.Save($Out); $o.Dispose(); $A.Dispose(); $B.Dispose()
