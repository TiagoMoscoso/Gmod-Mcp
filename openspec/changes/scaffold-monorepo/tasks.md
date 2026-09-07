## 1. Repository split

- [ ] 1.1 Create top-level `addon/`, `companion/`, and `tests/` directories and verify they sit beside existing `docs/` with no Companion or docs files under `addon/`
- [ ] 1.2 Add `.gitignore` for Python venv/__pycache__, `.pyc`, OS junk, and GMod temp files and verify `git status` does not offer those patterns as new tracked files

## 2. GLua addon skeleton

- [ ] 2.1 Add `addon/addon.json` with provisional title "GMod AI Players", type, and tags and verify the JSON parses and includes the fields `gmad` expects
- [ ] 2.2 Add `addon/lua/autorun` client/server stubs that include `lua/ai_players/` and verify the files exist at engine-conventional paths (`lua/autorun/*.lua`)
- [ ] 2.3 Add `addon/lua/ai_players/shared/protocol.lua` exporting `AI_PLAYERS_PROTOCOL_VERSION = "1"` and verify a grep of the addon tree finds that exact string
- [ ] 2.4 Confirm autorun does not open an MCP-online popup or print a live endpoint and verify no UI/net message in the skeleton claims MCP is ready

## 3. Companion skeleton

- [ ] 3.1 Add `companion/pyproject.toml` for Python 3.12+ with package `ai_players_companion` and a console script and verify `pip install -e companion/` (or equivalent) succeeds
- [ ] 3.2 Add `companion/src/ai_players_companion/protocol.py` with `PROTOCOL_VERSION = "1"` matching the GLua constant and verify both files contain the same version string
- [ ] 3.3 Add a `__main__` / console entry that prints that MCP is not hosted yet and exits 0 and verify running the script does not bind port 8765 or serve `/mcp`
- [ ] 3.4 Write `companion/README.md` covering venv, install, and run and verify a new reader can start the process from those steps alone

## 4. Tests placeholder and docs touch

- [ ] 4.1 Add `tests/README.md` stating Companion unit tests land in `companion-mcp-host` and verify the file does not claim a test harness exists yet
- [ ] 4.2 Update the root README "Proposed monorepo" section to "Created skeleton" with the same split and verify it still says MCP/gameplay are not implemented
- [ ] 4.3 Confirm no LICENSE file was added and verify OQ-DIST-001 remains the license tracker
