# Distribution

**Status:** Dual public channels are **Defined**. Payload split is **Proposed**. License and Companion install are **Open**.

## Channels

| Channel | Role |
| --- | --- |
| **Public GitHub** | Source of truth: docs, addon, Companion, native source, issues |
| **Steam Workshop** | GLua addon discovery, subscribe, auto-update |

Publishing to both is a product goal, not a future maybe.

## Proposed package split

```text
GitHub (source of truth)
├── addon/          → Steam Workshop GMA (GLua + UI + entities + sounds/materials if any)
├── companion/      → GitHub only
├── native/         → GitHub Releases later
└── docs/           → GitHub only
```

The monorepo must stay **Workshop-extractable**: building a GMA from `addon/` must not require dragging Companion or documentation into the archive.

## Requirements

- [FR-DIST-001](../requirements/functional-requirements.md#fr-dist-001) — GLua publishable to Workshop
- [FR-DIST-002](../requirements/functional-requirements.md#fr-dist-002) — full source on public GitHub
- [NFR-DIST-001](../requirements/non-functional-requirements.md#nfr-dist-001) — no Python runtime inside the GMA
- [NFR-DIST-002](../requirements/non-functional-requirements.md#nfr-dist-002) — version mismatch fails closed

## Workshop-only user

**Defined** UX need: if the Companion is missing, the addon must not claim MCP is online.

**Proposed:** Setup Guide opens or cites the GitHub README.

Do not invent an installer in this specification pass.

## Dedicated servers

Linux `srcds` often does not consume Workshop like a client. Operators need a documented copy of `addon/` plus Companion. Details: [OQ-DIST-006](../requirements/open-questions.md#oq-dist-006-dedicated-server-install-path).

Native modules go to `garrysmod/lua/bin` with Facepunch names — never assume Workshop put them there.

## Versioning (**Proposed** direction, numbers **Open**)

- Addon has a version (Workshop changelog + Lua string)
- Companion has a version
- Shared **protocol version** integer/semver for handshake

Workshop can jump the addon without the Companion. Treat that as a normal case.

## License

Must be chosen before GitHub is public. Steam compatibility is part of that choice. [OQ-DIST-001](../requirements/open-questions.md#oq-dist-001-spdx-license).

No license file is added in this documentation pass because the SPDX ID is still **Open**.

## Secrets and bind defaults

Public addon + public repo must not ship API keys or a default `0.0.0.0` open MCP.

**Proposed** default: Companion binds loopback.

## Workshop metadata

Title, tags, preview image: [OQ-DIST-007](../requirements/open-questions.md#oq-dist-007-workshop-metadata). Blocked on final name.

## What this document is not

- Not a `gmpublish` tutorial
- Not a CI pipeline
- Not a promise that native DLLs will ever be on Workshop
