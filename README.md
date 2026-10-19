# Balatro Mod Tool Starter Kit

A starting point for making Balatro mods with [Claude Code](https://claude.com/claude-code). Open this folder in Claude Code and it reads `CLAUDE.md`, a working knowledge base built while making real mods:
- Steamodded setup
- a step-by-step process that works
- deck and Joker patterns
- measured art rules for Balatro's pixel style
- PowerShell art scripts
- a list of bugs already hit and fixed

## What's inside
| Path | What it is |
|---|---|
| `CLAUDE.md` | The instructions Claude reads |
| `examples/` | Two small working mods: a stat deck and a Fusion Jokers fusion. **Reference only:** see the license |
| `tools/` | Art scripts: build the templates, make 2x art, recolour or split vanilla cards, preview pixel art |
| `art_kit/` | Card templates, built on your machine by `tools/build_art.ps1` |
| `MOD_LICENSE_TEMPLATE.md` | The no-sale, no-harm license Claude adds to every mod you make |

No game art is included. The scripts build everything from your own copy of Balatro.

## Quick start (Windows)
1. Own Balatro on Steam and install [Claude Code](https://claude.com/claude-code).
2. Download this repository and unzip it.
3. Open a terminal in the folder and run `claude`.
4. Say something like: *"Help me set up Balatro modding, then let's make a simple deck."*
   Claude installs Lovely and Steamodded with you, runs `tools/build_art.ps1`, and starts from there.

**Which model?** Sonnet handles decks and simple Jokers well. For bigger projects (Lovely patches, custom menus, crashes that won't go away after a few tries), Opus does noticeably better.

## Recommended tools (not included)
The kit was built with these Claude Code add-ons. They're optional and installed separately, under their own MIT licenses.

| Tool | What it adds | Install |
|---|---|---|
| [gstack](https://github.com/garrytan/gstack) by Garry Tan | Skills such as `/investigate` (root-cause debugging), `/plan-eng-review` (plan before building) and `/context-save` (pause and resume long work) | Follow the repo's README. On Windows it needs Git for Windows and Bun, and `./setup` must run in Git Bash |
| [REA](https://github.com/morluto/rea) (`rea-agents` on npm) | Reverse-engineering MCP server for looking inside packaged files and binaries | `claude mcp add rea --scope user -- cmd /c npx -y rea-agents@6.5.0 mcp` |

## Licenses
- **This kit:** see [`LICENSE`](LICENSE). It's free to use and share, but you can't sell it or use it for harmful purposes. The example mods are reference only: learn from them and copy small pieces, but don't republish them as mods.
- **Mods you make with it:** Claude adds [`MOD_LICENSE_TEMPLATE.md`](MOD_LICENSE_TEMPLATE.md) to each one: no sale, no harmful use. If your mod includes code copied from a GPL v3 mod, Claude explains your options first.
- **Not covered:** Balatro (LocalThunk / Playstack), Steamodded and Lovely, gstack and REA. Each keeps its own license.

These licenses are custom and haven't been reviewed by a lawyer.
