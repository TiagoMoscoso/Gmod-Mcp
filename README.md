# GMod AI Players

**Status:** specification  
**Provisional name:** GMod AI Players  
**License:** open — see [OQ-DIST-001](docs/requirements/open-questions.md#oq-dist-001-spdx-license)

An addon/framework for [Garry's Mod](https://gmod.facepunch.com/) that turns NPCs and bots into characters controlled by external AI agents through the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/).

The user connects the MCP client of their choice (Claude Code, Codex, or any compatible client), binds a persona to an in-game character, and the agent observes and acts through **semantic high-level actions**. Garry's Mod executes movement, combat, and interaction deterministically. The LLM does not press keys every frame.

This repository is the **source of truth**. The GLua addon is also intended for the [Steam Workshop](https://steamcommunity.com/app/4000/workshop/). The Companion service and native modules are not assumed to ship inside a Workshop GMA. See [Distribution](docs/planning/distribution.md).

## Current stage

This repository currently contains **documentation only**. There is no production addon, Companion, or native module yet.

The goal of this pass is a solid initial specification for discussion and decision-making, not an implementation.

## Read this first

1. [Documentation index](docs/README.md)
2. [Product vision](docs/product/vision.md)
3. [Scope and phasing](docs/product/scope.md)
4. [MVP / first vertical slice](docs/planning/mvp.md)
5. [Open questions](docs/requirements/open-questions.md)

## Architecture at a glance

```text
                 AI AGENT
       Claude / Codex / MCP client
                     |
                     | MCP
                     v
              AI COMPANION
           (proposed: Python)
                     |
         actions / events / state
                     |
                     v
            GARRY'S MOD SERVER
                     |
        +------------+-------------+
        |                          |
       GLua                       C++
 gameplay / world logic        voice core
                                 (future)
```

| Layer | Responsibility |
| --- | --- |
| Agent | What should this character think and do? |
| Companion | MCP, routing, sessions, optional speech/memory |
| GLua | What is happening inside the game? |
| C++ (future) | What did humans say? (voice capture) |

**Defined:** cognition and motor control are decoupled. Agents issue actions such as `move_to`, `follow`, `say`, and `attack`. GMod owns navmesh, `StartCommand`, aiming, and arrival.

## Intended public channels

| Channel | Role | Status |
| --- | --- | --- |
| Public GitHub | Full monorepo, issues, docs, Companion, native source | **Defined** goal |
| Steam Workshop | GLua addon discovery and install/update | **Defined** goal |

How Workshop-only users obtain the Companion remains **Open**. See [OQ-DIST-002](docs/requirements/open-questions.md#oq-dist-002-workshop-payload).

## Non-goals (now)

- Production Lua, Python, or C++ in this documentation pass
- Coupling the core to Claude, OpenAI, DarkRP, or any single LLM provider
- Frame-level input tools (`press_w`, `move_mouse`, `press_attack`)
- Arbitrary Lua/shell execution exposed to agents
- Shipping voice STT/TTS in the first vertical slice

## Proposed monorepo (not created yet)

```text
gmod-ai-players/
├── docs/
├── addon/          → Workshop GMA candidate
├── native/         → future voice module
├── companion/      → MCP host (GitHub)
└── tests/
```

## Contributing

The project is intended to become a public open-source framework. Contribution guidelines, license, and CI are **Open** until the first implementation milestone. Until then, discuss the specification in issues after the repository is published.

## Statement status legend

Documentation uses these labels:

| Label | Meaning |
| --- | --- |
| **Defined** | Agreed requirement or goal |
| **Proposed** | Recommended default, not locked |
| **Hypothesis** | Needs a spike or experiment |
| **Future** | Intentionally out of the current phase |
| **Open** | Decision not taken; see open questions |
