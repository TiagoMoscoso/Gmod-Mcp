## Purpose

Defines the dual-distribution monorepo layout so the GLua addon can ship as a Workshop GMA without Companion, tests, or documentation, while GitHub holds the full project.

## Requirements

### Requirement: Dual-distribution directory split

The repository MUST keep Workshop-candidate GLua under `addon/` and MUST keep Companion source, tests, and documentation outside `addon/`. Building a GMA from `addon/` MUST NOT require including Companion source, native source, or `docs/`.

#### Scenario: Addon tree is GMA-extractable

- **WHEN** a packager archives only the `addon/` directory
- **THEN** the archive MUST contain GLua addon files and MUST NOT contain `companion/`, `docs/`, `tests/`, or `native/` source

#### Scenario: Full project remains on GitHub layout

- **WHEN** a contributor clones the repository
- **THEN** the tree MUST include `addon/`, `companion/`, `tests/`, and `docs/` as sibling top-level directories (or documented equivalents that preserve the same split)

### Requirement: Addon identity metadata

The `addon/` tree MUST include `addon.json` with a provisional addon title, description, and type suitable for later Workshop publish. The metadata MUST NOT claim a locked public product name while OQ-NAME-001 remains open.

#### Scenario: Addon.json is present and loadable as metadata

- **WHEN** a developer inspects `addon/addon.json`
- **THEN** the file MUST exist and MUST include title, type, and tags fields expected by `gmad`

### Requirement: Companion lives outside the GMA

The Companion process MUST be a separate project tree under `companion/` that can be installed and run from GitHub without being packed into a Workshop GMA. The Companion tree MUST declare its language and how to start the process in a README inside `companion/`.

#### Scenario: Companion is not nested under addon

- **WHEN** a developer looks for Companion source
- **THEN** it MUST live under `companion/` at the repository root and MUST NOT live under `addon/`

#### Scenario: Companion README explains local run

- **WHEN** a developer opens `companion/README.md`
- **THEN** the file MUST describe how to create an environment and start the process locally

### Requirement: Shared protocol version placeholder

The repository MUST define a single protocol version identifier that addon and Companion can later handshake on. The identifier MUST exist in both trees (or a shared documented constant) even before the bridge is implemented.

#### Scenario: Version constant exists on both sides

- **WHEN** a developer searches the skeleton for the protocol version
- **THEN** both `addon/` and `companion/` MUST expose the same initial version string

### Requirement: Skeleton does not claim MCP is ready

Until a later change hosts MCP, loading the addon or starting the Companion skeleton MUST NOT present a working MCP endpoint as ready.

#### Scenario: Addon load does not fake MCP online

- **WHEN** the GLua skeleton autorun loads in Garry's Mod
- **THEN** the client MUST NOT show an MCP URL as online

#### Scenario: Companion skeleton is not an MCP server yet

- **WHEN** a developer starts the Companion process from this change's skeleton
- **THEN** the process MUST start without advertising a live MCP tool session as ready (no `/mcp` success popup contract)
