## SPK-TRN-001 Result

Date: 2026-09-07

Environment:

- Garry's Mod launched from the local Steam Flatpak/Proton install.
- Sandbox listen server on `gm_construct`.
- 16-player local server.
- Spike addon: `garrysmod/addons/ai_players_transport_spike/lua/autorun/server/sv_ai_players_transport_spike.lua`.

Result:

- File IPC under `garrysmod/data/ai_players_transport_spike/` sent `hello` from GLua and received `hello_ok` from a local Companion-side responder.
- The generated report recorded `file_ipc = "ok"` with `map = "gm_construct"`.
- The first HTTP run to `http://127.0.0.1:8765/spike/hello` failed when no responder was listening.
- With the responder listening, the rerun completed through file IPC before any HTTP success was observed by the responder.

Decision input:

- File IPC is verified as a working transport path for the MVP bridge on the target listen-server setup.
- HTTP remains unreliable for this setup and is not selected for the MVP production bridge.

Relevant report excerpt:

```json
{
  "file_ipc": "ok",
  "protocol_version": "0.1.0",
  "realm": "server",
  "http": "waiting",
  "map": "gm_construct",
  "file_ipc_response": {
    "type": "hello_ok",
    "protocol_version": "0.1.0",
    "payload": {
      "source": "companion_spike"
    }
  }
}
```

## Task 1.3 Live Bridge Verification

Date: 2026-09-07

Setup:

- The repo addon Lua files were copied into the local GMod `garrysmod/lua` tree for the running Proton session because GMod did not follow Unix symlinks.
- The real Companion was started with `ai-players-companion --gmod-data <GarrysMod>/garrysmod/data`.
- The GMod console ran `lua_openscript autorun/server/sv_ai_players_init.lua`.

Result:

- GMod wrote `garrysmod/data/ai_players/bridge/gmod_out/hello.json`.
- Companion wrote `garrysmod/data/ai_players/bridge/companion_out/hello_ok.json`.
- Companion wrote `garrysmod/data/ai_players/bridge/companion_out/status.json` with `ready = true` and `state = "healthy"`.
