# Non-functional requirements

**Status:** **Defined** for principles. Numeric budgets (latency, max NPCs, rate limits) are **Open**.

## Security

### NFR-SEC-001

Agents shall not receive arbitrary Lua execution capabilities.

Forbidden: `execute_lua`, `shell`, `eval`, `run_console_command`, and equivalents.

### NFR-SEC-002

Agents shall operate only through explicitly allowed capabilities for that AI Player.

A missing capability shall cause a tool call to be rejected, not executed.

### NFR-SEC-003

The default MCP deployment for local Sandbox shall not assume a public unauthenticated Internet bind.

Authentication, bind address, and public-server hardening are **Open**. See [OQ-MCP-001](open-questions.md#oq-mcp-001-mcp-authentication) and [OQ-SEC-001](open-questions.md#oq-sec-001-public-server-security).

## Architecture

### NFR-ARCH-001

The LLM shall not control per-frame inputs. Motor details belong to GMod controllers.

### NFR-ARCH-002

C++ native modules, when introduced, shall extend GLua rather than reimplement gameplay.

### NFR-ARCH-003

The core shall not depend on a specific LLM vendor SDK.

## Extensibility

### NFR-EXT-001

Gamemode-specific verbs shall be added through adapters/plugins without contaminating the Sandbox core domain.

### NFR-EXT-002

New semantic actions and capabilities shall be addable without renaming existing `agent_id`-scoped tools.

## Perception and context

### NFR-PER-001

Observation payloads shall be bounded to reduce context explosion (distance, visibility, relevance, recent events, current objective).

Exact caps are **Open**. See [OQ-PER-001](open-questions.md#oq-per-001-perception-caps).

## Distribution

### NFR-DIST-001

The Steam Workshop package must remain installable as a normal GMod addon. It shall not require embedding a Python runtime or undocumented native binaries inside the GMA.

How users then install the Companion is **Open**.

### NFR-DIST-002

Addon and Companion shall be able to fail gracefully on protocol or version mismatch rather than execute undefined behavior.

Mismatch policy is **Open**. See [OQ-DIST-004](open-questions.md#oq-dist-004-version-coupling).

## Reliability

### NFR-REL-001

If the Companion or MCP client disconnects, AI Players shall enter a defined lifecycle state (DISCONNECTED or ERROR), not continue issuing stale agent intents.

In-progress controller motion may finish or halt; that choice is **Open**.

## Performance

### NFR-PERF-001

Agent decisions shall not run on the GMod tick as if they were NextBot think-every-frame LLM calls.

Tick-rate of observation polling and action rate limits are **Open**. See [OQ-PERF-001](open-questions.md#oq-perf-001-rate-limiting).

## Platforms

### NFR-PLT-001

Documentation and packaging shall acknowledge both Windows listen servers and Linux dedicated servers as relevant targets.

Which platforms ship in the first binary release is **Open**. See [OQ-PLT-001](open-questions.md#oq-plt-001-windows-linux-support).
