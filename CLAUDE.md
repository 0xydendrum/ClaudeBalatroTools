# Balatro modding: starter instructions for Claude

You're helping someone make Balatro mods with Steamodded. Everything below was learned by another Claude and its user while building working mods: a stat deck, a Joker with custom art, a cross-mod fusion Joker, and a larger UI mod. Treat it as tested knowledge, except where a section says it wasn't tested.

**What's in this folder:**
- `CLAUDE.md`: this file. Claude Code loads it automatically when started in this folder.
- `examples\ExampleDeck\`: a stat deck with custom card-back art. Confirmed working in-game.
- `examples\ExampleFusion\`: a Joker with art, plus a test deck. Needs the Fusion Jokers mod. Confirmed working in-game.
- `art_kit\`: exact vanilla card templates (blank card, mask, "JOKER" lettering). Empty until `tools\build_art.ps1` runs.
- `tools\`: PowerShell art scripts (Windows only).
- `MOD_LICENSE_TEMPLATE.md`: the license to add to every mod made with this kit (section 12).
- `LICENSE`: the kit's own license. Its rules for the examples are in "Using the examples" below.

**Using the examples.** They're reference material, not starting templates to republish. Read them to learn the working patterns and to debug, and copy only the small pieces a mod actually needs (a config block, one `calculate` pattern, the atlas setup). Never copy a whole example mod into the user's mod, release one under a new name, or keep its names, keys or text. The kit's `LICENSE` forbids that.

---

## 0. Scope: what to aim for
Good first projects, in order of difficulty:
1. **Stat decks** (hand size, hands, discards, starting money, starting Jokers or vouchers). Pure config, no code.
2. **Simple Jokers** using one trigger: flat +Mult/+Chips, xMult, per-suit or per-rank bonuses, money at end of round.
3. **Scaling Jokers** (gain +Mult each time X happens), Jokers that check the poker hand.
4. **Art** made by recolouring or combining vanilla cards with the scripts in `tools\`.

Harder, and best left until the basics work: Lovely patches (editing the game's own source), custom UI or menus, changing what can appear in shops, new consumable types, cross-mod compatibility work. If the user asks for one of these, say it's a bigger step, build the smallest possible version first, and test it before adding more.

Ask the user for names, numbers and costs. Suggest balanced values by comparing to similar vanilla Jokers, but let them decide.

## 1. First-time setup (check each step, don't assume)
1. **Find the game.** Usually `C:\Program Files (x86)\Steam\steamapps\common\Balatro`, but Steam libraries can be on other drives. Ask the user, or check `steamapps\libraryfolders.vdf`.
2. **Install Lovely** (the injector): download the Windows release from https://github.com/ethangreen-dev/lovely-injector/releases and put `version.dll` in the game folder next to `Balatro.exe`.
3. **Install Steamodded:** download https://github.com/Steamodded/smods (latest release, or the main branch zip) and extract it into the Mods folder as its own subfolder.
   - Mods folder: `%APPDATA%\Balatro\Mods` (create it if missing).
   - Always check the current install steps on the wiki: https://github.com/Steamodded/smods/wiki
4. **Launch the game once.** If Steamodded loaded, the main menu has a **Mods** button.
5. **Vanilla source code is now available** at `%APPDATA%\Balatro\Mods\lovely\game-dump\` (`card.lua`, `game.lua`, `back.lua`, `globals.lua`, …). Lovely writes it on launch. **This is the best reference there is.** Search it before writing any code.
6. **Build the kit's art** from the user's own game copy (the kit ships no game art):
   `powershell -ExecutionPolicy Bypass -File tools\build_art.ps1 -GameDir "<game folder>"`
   This fills `art_kit\` and the examples' `assets\`, and leaves the extracted vanilla textures in `_vanilla\resources\textures\1x\` (Jokers in `Jokers.png`, deck backs in `Enhancers.png`).
   - For other sheets, extract them with `tar -xf "<game folder>\Balatro.exe" -C _vanilla resources/textures`. `Balatro.exe` is really a zip file. .NET's `ZipFile` / `Expand-Archive` can't read it, but `tar` can.
7. **Reference examples:** download https://github.com/Steamodded/examples/archive/refs/heads/master.zip (JokerExamples, DeckExamples, SealExamples, …) into a `reference\` folder. Treat them as read-only, and note they're GPL v3 (section 12).

**No git?** That's fine. Download any GitHub repo as a zip: `https://github.com/<owner>/<repo>/archive/refs/heads/<branch>.zip` with `Invoke-WebRequest`.

## 2. Working process (this is what worked)
1. **Find the closest vanilla card first.** Want a "+Mult per Heart" Joker? Search `card.lua` in the game-dump for Lusty Joker and read how it works. Copy its logic.
2. **One thing at a time.** Build one Joker or deck, install it, have the user test it, then do the next one.
3. **Install = copy the mod folder into `%APPDATA%\Balatro\Mods\`, then fully restart the game.** The game only reads from the Mods folder. **Re-copy after every edit**, or the user tests the old version. This is the most common "my change didn't work" cause.
4. **Make a test deck** for each Joker: a Back that starts with that Joker (plus any Jokers it interacts with, plus money). It's much faster than hoping it shows up in a shop. See `examples\ExampleFusion\decks\fusion_test.lua`.
5. **When it crashes:** the game shows a traceback on screen. Ask the user to copy the text, or read the newest log in `%APPDATA%\Balatro\Mods\lovely\log\`. The traceback names the file and line. Fix the cause, don't guess.
6. **Keep a `NOTES.md`** in the project with what was built, what was tested in-game, and anything surprising. Update it as you go.
7. **Be honest about testing.** Code that loads isn't code that works. Say "untested in-game" until the user confirms it.

## 3. Mod skeleton
```
MyMod\
  metadata.json
  main.lua
  LICENSE      from MOD_LICENSE_TEMPLATE.md (section 12)
  jokers\      one file per Joker (optional, for bigger mods)
  decks\       one file per deck
  assets\1x\   art at normal size
  assets\2x\   the same art at double size, same file names
```

`metadata.json`:
```json
{
  "id": "MyMod",
  "name": "My Mod",
  "display_name": "My Mod",
  "author": ["<ask the user>"],
  "description": "What it adds.",
  "prefix": "mymod",
  "main_file": "main.lua",
  "version": "1.0.0",
  "dependencies": ["Steamodded (>=1.0.0~BETA-0301a)", "Lovely (>=0.6.0)"]
}
```
- **`prefix` is added to every key.** A Joker with `key = 'lucky_cat'` in prefix `mymod` becomes `j_mymod_lucky_cat`. A Back becomes `b_mymod_<key>`. Pick a short, unique prefix and never change it after the user has save files using it.
- **Multi-file mods:** `main.lua` runs each file with `SMODS.load_file('jokers/lucky_cat.lua')()`.
- **Depending on another mod:** add its `id` to `dependencies` (e.g. `"FusionJokers"`).
- **⚠ Encoding bug:** Windows PowerShell 5.1 `Set-Content -Encoding utf8` / `Out-File` writes a BOM (invisible bytes at the start). That can break `metadata.json`. Write files with the Write tool, or make sure there's no BOM.

**Art:**
```lua
SMODS.Atlas { key = 'lucky_cat', path = 'j_lucky_cat.png', px = 71, py = 95 }
-- then on the card:  atlas = 'lucky_cat', pos = { x = 0, y = 0 }
```
The png must exist in both `assets\1x\` and `assets\2x\`.

**Text:**
```lua
loc_txt = {
    name = 'Lucky Cat',
    text = { '{C:mult}+#1#{} Mult for each', 'scored {C:hearts}Heart{}' },
},
```
- `#1#`, `#2#` … are filled from `loc_vars` (which returns `{ vars = { … } }`).
- Colour tags: `{C:attention}` `{C:mult}` `{C:chips}` `{C:money}` `{C:blue}` `{C:red}` `{C:green}` `{C:inactive}` `{C:spades}` `{C:hearts}` `{C:clubs}` `{C:diamonds}`. Close with `{}`.
- `{X:mult,C:white} X#1# {}` gives the white-on-red xMult badge.

## 4. Decks (`SMODS.Back`)
The base game applies these `config` keys by itself at run start, so a stat deck needs **no code at all**:
- `hand_size`, `hands`, `discards`: added to the normal values (Painted Deck is `hand_size = 2`, Black Deck is `hands = -1`).
- `dollars`: **added on top of the normal $4**. "Start with $20" is `dollars = 16`.
- `jokers = { 'j_joker', 'j_lusty_joker' }`: start with these Jokers.
- More keys (vouchers, consumables, …) are in the game-dump `back.lua` and in `game.lua` under `P_CENTERS` (search for `b_red`, `b_painted` etc.).

Text gotcha: to show "-1 hand", negate negative values in `loc_vars`:
```lua
loc_vars = function(self)
    return { vars = { self.config.hand_size, -self.config.hands, -self.config.discards } }
end,
```
Leaving out `atlas` uses the vanilla deck-back sheet: `pos = { x = 0, y = 4 }` is the Challenge Deck art, handy for test decks.

Reference: `examples\ExampleDeck\main.lua`.

## 5. Jokers (`SMODS.Joker`)
Fields: `key, atlas, pos, rarity (1 Common, 2 Uncommon, 3 Rare, 4 Legendary), cost, unlocked, discovered, blueprint_compat, eternal_compat, perishable_compat, config = { extra = { … } }, loc_txt, loc_vars, calculate`.

- **Put tunable numbers in `config.extra`** and read them from `card.ability.extra` (not `self.config`) in both `loc_vars` and `calculate`. Each copy of the Joker has its own `ability` table, which is what makes scaling work.
- `loc_vars = function(self, info_queue, card) return { vars = { card.ability.extra.mult } } end`
- Set `unlocked = true, discovered = true` while testing, so it shows in the collection.

**Per-card trigger** (tested in-game; this is how the suit Jokers work):
```lua
calculate = function(self, card, context)
    if context.individual and context.cardarea == G.play and context.other_card:is_suit('Hearts') then
        return { mult = card.ability.extra.mult }
    end
end,
```

**Other common patterns.** These are standard Steamodded API, but they weren't tested in our mods. Check them against the JokerExamples download and the wiki before relying on them:
- Flat bonus once per hand: `if context.joker_main then return { mult = …, chips = …, xmult = … } end`
- Hand type check: `if context.joker_main and next(context.poker_hands['Pair']) then … end`
- Scaling: grow the value in `context.before` (or another context), guarded with `not context.blueprint` so Blueprint copies don't also grow it. Return `{ message = localize('k_upgrade_ex') }` for the "Upgrade!" popup.
- Money at end of round: `calc_dollar_bonus = function(self, card) return card.ability.extra.dollars end`
- Return keys: `mult`, `chips`, `xmult`, `dollars`, `message`.

**Vanilla key quirk:** Gluttonous Joker's key is `j_gluttenous_joker` (misspelled in the base game). Always check real keys in the game-dump `game.lua` (`P_CENTERS`) before using one.

To show another Joker's name in text: `localize { type = 'name_text', key = 'j_lusty_joker', set = 'Joker' }`.

Reference: `examples\ExampleFusion\jokers\example_fusion.lua`.

## 6. JokerDisplay (only if the user has it installed)
JokerDisplay shows a live info bar under each Joker. **If it's installed, every new Joker needs a `joker_display_def`**, or JokerDisplay draws an empty dark bar under the card.
- Fix: find the closest vanilla Joker in `Mods\JokerDisplay…\definitions\display_definitions.lua` and adapt it into the Joker as `joker_display_def = function(JokerDisplay) return { … } end`.
- A typical one has `text` (the number shown), `reminder_text` (e.g. the suits), and a `calc_function` that uses `JokerDisplay.evaluate_hand()` and `JokerDisplay.calculate_card_triggers()` to preview the current hand.
- JokerDisplay is GPL v3. Adapting its definitions makes that part GPL-derived (section 12).
- Ask the user which mods they have before adding this.

## 7. Fusion Jokers (optional cross-mod example)
Only relevant if the user has Fusion Jokers (https://github.com/wingedcatgirl/Fusion-Jokers) and wants fusions.
- Fused Jokers use `rarity = 'fuse_fusion'` (never appears in shops).
- After defining the Joker, register the recipe:
  ```lua
  FusionJokers.fusions:register_fusion {
      jokers = { { name = 'j_wrathful_joker' }, { name = 'j_gluttenous_joker' } },
      result_joker = 'j_<prefix>_<key>',
      cost = 10, -- price to FUSE; the base mod uses $8 to $12
  }
  ```
- Add `"FusionJokers"` to `dependencies`. Don't reuse ingredient pairs the base mod already has (check its source).

## 8. Art rules (measured from ~10,000 vanilla and modded sprites)
**Hard rules, no exceptions found:**
- Each card cell is **71×95 pixels** at 1x. Sheets are grids of these cells.
- **2x is exactly 1x with each pixel doubled.** Draw at 1x only, then make 2x with `tools\make_2x.ps1`. Never draw the two sizes separately.
- **No semi-transparent pixels, ever.** Alpha is always 0 or 255. No anti-aliasing, no soft edges, no blur.
- Vanilla cards are **69×93 inside the cell**, with a 1px transparent margin. The outline is 1px `#BFC7D5` with a small rounded cut at each corner. `art_kit\card_blank.png` (white fill) and `art_kit\card_mask.png` are this exact shape.

**Layout:**
- "JOKER" runs vertically in `#4F6367` at x≈3–13 near the top left, with a 180°-rotated copy at the bottom right (`art_kit\joker_lettering.png`).
- The safe art area between the lettering is x≈14–56.

**Palette (game colour names):**

| Use | Hex |
|---|---|
| Outline / text (L_BLACK) | `#4F6367` |
| Card border (JOKER_GREY) | `#BFC7D5` |
| Mult red | `#FE5F55` |
| Chips blue | `#009DFF` |
| Orange | `#FDA200` |
| Money / Gold | `#F3B958` / `#EAC058` |
| Green | `#4BC292` |
| Purple | `#8867A5` |
| Spades / Clubs / Hearts / Diamonds | `#403995` / `#235955` / `#F03464` / `#F06B3F` |
| Tarot / Planet / Spectral | `#A782D1` / `#13AFCE` / `#4584FA` |
| Rarity Common / Uncommon / Rare / Legendary | `#009DFF` / `#4BC292` / `#FE5F55` / `#B26CBB` |

**Style:**
- About 8–16 colours per card, with 3–4 hard-edged shades per colour. No gradients. Checkerboard dithering for texture.
- Outlines are 1px `#4F6367` or a darker shade of the object's own colour. **Never pure black.**
- Backgrounds: white, or a two-tone repeating suit pattern with a 2px white inner border.
- Deck backs: a white frame with a symmetric one-colour ornament.

**Card styles to choose from:**
1. Jimbo variant: the default jester, re-dressed or recoloured.
2. Recoloured figure on a suit pattern (the suit Jokers).
3. One object or scene filling the card (Credit Card, Driver's License).
4. Card frame plus a floating `soul_pos` layer (how Legendaries and the Pokermon mod show a second floating sprite). Best way to bring in outside art.

**What actually worked:**
- **Start from vanilla art, don't draw from scratch.** The first hand-drawn placeholders looked wrong (wrong corners, wrong border colour, separately drawn 2x). Recoloured or recombined vanilla cells looked right.
- Deck back: recolour a vanilla back. Red Deck with `FE5F55→8867A5` made the example deck's back.
- Combining two Jokers: split them down the middle with a zigzag seam (`split_card.ps1 -Mode zigzag`), as in the example fusion.
- Claude can't draw detailed original pixel art well. For original art, the user draws it (Aseprite, Piskel, LibreSprite) at 71×95 following the rules above, and Claude handles the 2x, checks the rules and wires it in.
- Art made from vanilla sprites is still based on the game's art. That's normal for mods, but the mod's license can't grant rights to it (section 12).

**Bringing in outside art:** crop → nearest-neighbour downscale (figure about 40×70) → reduce to ≤16 colours → set alpha to 0 or 255 → add a 1px outline → paste onto `card_blank.png` → add lettering → save at 1x → `make_2x.ps1`. Only use outside art the user made or has permission to use.

## 9. Art tools (`tools\`, Windows PowerShell)
Run with `powershell -ExecutionPolicy Bypass -File tools\<script>.ps1 …`.

| Script | What it does |
|---|---|
| `build_art.ps1 -GameDir "<game folder>"` | One-time setup: extracts vanilla textures to `_vanilla\` and builds `art_kit\` plus the examples' art |
| `make_2x.ps1 -In1x a.png -Out2x b.png` | Makes the 2x file from the 1x file |
| `zoom.ps1 -In sheet.png -X 0 -Y 0 -W 71 -H 95 -Scale 4 -Out preview.png` | Enlarged preview on a checkerboard, so you can look at pixel art (open it with the Read tool) |
| `recolor_cell.ps1 -Sheet Jokers.png -CX 0 -CY 0 -Map "FE5F55=8867A5","009CFD=4BC292" -Out new.png` | Copies one cell (column CX, row CY) and swaps exact colours |
| `split_card.ps1 -Sheet Jokers.png -AX 6 -AY 1 -BX 7 -BY 1 -Mode zigzag -SplitX 35 -Out fused.png` | Left half from cell A, right half from cell B. Modes: `straight`, `seam`, `zigzag` |
| `make_kit.ps1 -JokersPng Jokers.png -OutDir art_kit` | Rebuilds the `art_kit` templates from vanilla Jimbo |

Cell coordinates count from 0. A vanilla Joker's cell is its `pos` in `P_CENTERS` (game-dump `game.lua`): e.g. Greedy is `{x=6,y=1}` and Lusty `{x=7,y=1}`, which is what the split example above combines. Always preview the result with `zoom.ps1` before installing it.

## 10. Bugs and gotchas we hit
| Problem | Cause / fix |
|---|---|
| Edit doesn't show up in-game | The mod wasn't re-copied into `Mods\`, or the game wasn't restarted |
| Example mod crashes on load: missing png | `tools\build_art.ps1` hasn't been run yet |
| Empty dark bar under a new Joker | JokerDisplay is installed and the Joker has no `joker_display_def` (section 6) |
| Deck gives wrong starting money | `dollars` is added to the base $4 |
| Deck text shows "--1" | Negate negative config values in `loc_vars` |
| Vanilla Joker key "not found" | Typo or vanilla misspelling (`j_gluttenous_joker`). Check `P_CENTERS` in `game.lua` |
| Mod won't load / metadata error | BOM from PowerShell 5.1's UTF-8 output in `metadata.json` |
| Can't extract textures from `Balatro.exe` | Use `tar -xf`, not .NET ZipFile / Expand-Archive |
| Art looks blurry or off | Semi-transparent pixels, separately drawn 2x, or wrong border colour. Re-check section 8 |
| Values wrong on one copy of a Joker | Read `card.ability.extra`, not `self.config` |
| (Advanced) Crash "empty pool" when banning cards | With some mods (e.g. Pokermon) Steamodded's weighted pool picker asserts on an empty pool. Never let a pool go empty. |
| (Advanced) Crash at boss selection | The game crashes if no boss blind is eligible. Don't ban all bosses for an ante. |
| (Advanced) Saved mod config ignores your defaults | Steamodded merges saved config into the defaults, so a default list must start empty |
| (Advanced) Lovely patch stops working | Lovely patches match exact source lines. Another mod changing that line breaks it. Prefer wrapping a function (`local old = Game.start_run; function Game:start_run(...) ... end`) when you can |

## 11. Where to look things up
| What | Where |
|---|---|
| How vanilla does something | `%APPDATA%\Balatro\Mods\lovely\game-dump\` (search `card.lua` for the Joker's name) |
| Steamodded API | https://github.com/Steamodded/smods/wiki |
| Steamodded examples | https://github.com/Steamodded/examples |
| Mod index (ideas, other mods' source to learn from) | https://balatromods.miraheze.org/wiki/Main_Page |
| Fusion Jokers source (clean cross-mod example: `mod/jokers/test.lua`) | https://github.com/wingedcatgirl/Fusion-Jokers |
| A deck mod with CardSleeves support | https://codeberg.org/AstroLightz/Balatro-7DeadlyDecks |
| Colour names | `globals.lua` in the game-dump (`G.C.…`) |

Other installed mods are good examples too: their source is right there in the Mods folder. Read one that does something similar before inventing an approach, and check its license before copying from it.

## 12. Licensing every mod (do this for every mod)
**Every mod made with this kit gets a `LICENSE` file** that forbids selling it and forbids harmful use. Add it when you create the mod, not at release time:
1. Copy `MOD_LICENSE_TEMPLATE.md` into the mod folder as `LICENSE`. Keep only the text below its "copy from here" line.
2. Fill in the year, the mod's name and the author (ask the user for the name they publish under).
3. Tell the user in one or two sentences what it says: free to play, change and share; no selling or paywalls; no harmful use. It's their mod, so if they want a different license, explain the trade-off and do what they decide.

**Check for GPL code first.** Steamodded, the Steamodded examples, JokerDisplay, Fusion Jokers and Pokermon are all **GPL v3**. Using their API (calling `SMODS.Joker`, `register_fusion`, etc.) is fine. But if the mod **contains code copied or adapted from a GPL project** (e.g. a JokerDisplay definition, a function lifted from another mod), the GPL doesn't allow adding a no-sale rule to that code. Before adding the template, check, and if there's GPL-derived code, tell the user and offer two options:
- **Rewrite** those parts independently (from the vanilla game-dump logic and the API docs, not from the GPL source), then use the template.
- **License the mod as GPL v3** instead. Tell the user plainly that the GPL allows others to sell copies, so the no-sale rule can't apply.

Also check other mods' licenses before copying from them. Many mods have no license at all, which means you may not copy their code.

**Game art.** Art derived from vanilla sprites belongs to the game's makers. The license covers only the user's own work, and the template says so.

These are practical guidelines, not legal advice. If the user plans to make money from anything Balatro-related or ends up in a dispute, they should talk to someone qualified.

---
Versions this was learned on: Steamodded 1.0.0~BETA-1814a, Lovely 0.9.0 (October 2026). Newer versions may change details. If something here disagrees with the game-dump or the current wiki, trust those.
