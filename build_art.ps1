param([string]$GameDir, [string]$WorkDir = "$PSScriptRoot\..\_vanilla")
# Builds every image this kit needs from YOUR copy of Balatro, so no game art is redistributed:
#   art_kit\card_blank.png, card_mask.png, joker_lettering.png   (from vanilla Jimbo)
#   examples\ExampleDeck\assets\{1x,2x}\example_back.png         (Red Deck back recoloured purple)
#   examples\ExampleFusion\assets\{1x,2x}\j_example_fusion.png   (Wrathful | Gluttonous zigzag split)
# GameDir: the folder that contains Balatro.exe.
$ErrorActionPreference = 'Stop'
$root = Resolve-Path "$PSScriptRoot\.."
$exe = Join-Path $GameDir 'Balatro.exe'
if (-not (Test-Path $exe)) { throw "Balatro.exe not found in $GameDir" }

# Balatro.exe is a LOVE zip; tar can read it, .NET ZipFile can't.
New-Item -ItemType Directory -Force $WorkDir | Out-Null
tar -xf $exe -C $WorkDir resources/textures/1x/Jokers.png resources/textures/1x/Enhancers.png
if ($LASTEXITCODE -ne 0) { throw "tar failed to extract textures from $exe" }
$jokers = Join-Path $WorkDir 'resources\textures\1x\Jokers.png'
$backs = Join-Path $WorkDir 'resources\textures\1x\Enhancers.png'

& "$PSScriptRoot\make_kit.ps1" -JokersPng $jokers -OutDir "$root\art_kit"

$deck1x = "$root\examples\ExampleDeck\assets\1x\example_back.png"
& "$PSScriptRoot\recolor_cell.ps1" -Sheet $backs -CX 0 -CY 0 -Map 'FE5F55=8867A5' -Out $deck1x
& "$PSScriptRoot\make_2x.ps1" -In1x $deck1x -Out2x "$root\examples\ExampleDeck\assets\2x\example_back.png"

$fuse1x = "$root\examples\ExampleFusion\assets\1x\j_example_fusion.png"
New-Item -ItemType Directory -Force (Split-Path $fuse1x) | Out-Null
& "$PSScriptRoot\split_card.ps1" -Sheet $jokers -AX 8 -AY 1 -BX 9 -BY 1 -Mode zigzag -SplitX 35 -Out $fuse1x
& "$PSScriptRoot\make_2x.ps1" -In1x $fuse1x -Out2x "$root\examples\ExampleFusion\assets\2x\j_example_fusion.png"

"Art built. Vanilla textures were extracted to $WorkDir (ignored by git)."
