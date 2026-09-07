# Native voice

**Status:** **Future.** Principles **Defined**. Codecs, VAD, and Source injection **Open**.

C++ must extend GLua, not replace it. The first vertical slice has **no** native module.

## Why native at all

GLua does not adequately expose:

- Voice chat intercept
- Voice packet capture
- Opus decoding
- PCM access
- Voice activity detection
- Cheap audio transport off the Lua heap

Those belong in a server-side binary module, conceptually:

```text
gmsv_aivoice_win64.dll
gmsv_aivoice_linux64.dll
```

Naming is illustrative.

## Planned pipelines

### Player → NPC (**Future**)

```text
Source / GMod voice
        → native module
        → Opus decode
        → PCM
        → VAD / segmentation
        → Companion STT
        → transcription
        → game/agent event (player_said / player_spoke)
```

### NPC → Player (**v2** output)

```text
Tool Gun voice preset (male | female | later extras)
        → Agent `speak`
        → TTS (Companion; engine Open)
        → audio buffer
        → GMod
        → positional 3D sound (multiplayer-hearable)
```

The Tool Gun **must** expose at least male and female presets in v2. See [v2-backlog.md](../planning/v2-backlog.md) C7.

True **Source voice packet injection** (NPC appears in the voice chat list as a talking player) is **investigation only**, not a requirement. See [OQ-VOI-004](../requirements/open-questions.md#oq-voi-004-source-voice-packet-injection).

## Proposed native layout (not created)

```text
native/
└── voice/
    ├── capture/
    ├── codec/
    ├── vad/
    ├── transport/
    └── lua_bindings/
```

Lua bindings should be small: start/stop capture, pull utterance, maybe set radius. No movement API in C++.

## Distribution

Native modules do not live happily in a Workshop GMA. Prefer GitHub Releases or a Companion bundle when this exists. [OQ-DIST-005](../requirements/open-questions.md#oq-dist-005-native-module-distribution-channel).

## Out of native scope

- Tool Gun UI
- MCP
- Persona storage
- DarkRP
- Pathfinding
