# Documentation index

This tree is the initial specification for **GMod AI Players**. It is written for architects, contributors, and future implementers. It is not a user manual for a shipping addon yet.

All specs are in English. The project is intended to be public open source (GitHub + Steam Workshop).

## Reading order

If you are new to the project, read in this order:

1. [Product vision](product/vision.md)
2. [User experience](product/user-experience.md)
3. [Scope](product/scope.md)
4. [Architecture overview](architecture/overview.md)
5. [MCP](architecture/mcp.md)
6. [NPC lifecycle](design/npc-lifecycle.md)
7. [Actions](design/actions.md)
8. [MVP](planning/mvp.md)
9. [Implementation roadmap](planning/implementation-roadmap.md) (OpenSpec change order)
10. [v2 backlog](planning/v2-backlog.md) (not MVP)
11. [Open questions](requirements/open-questions.md)

If you need a term, start with the [glossary](glossary.md).

## Tree

```text
docs/
├── README.md
├── glossary.md
├── product/
│   ├── vision.md
│   ├── user-experience.md
│   ├── use-cases.md
│   └── scope.md
├── requirements/
│   ├── functional-requirements.md
│   ├── non-functional-requirements.md
│   ├── constraints.md
│   └── open-questions.md
├── architecture/
│   ├── overview.md
│   ├── components.md
│   ├── agent-model.md
│   ├── gmod-runtime.md
│   ├── companion.md
│   ├── native-voice.md
│   ├── mcp.md
│   ├── data-flow.md
│   └── decisions/
│       ├── ADR-001-hybrid-architecture.md
│       ├── ADR-002-semantic-actions.md
│       ├── ADR-003-provider-agnostic-mcp.md
│       ├── ADR-004-sandbox-first-adapters.md
│       ├── ADR-005-mcp-hosted-by-companion.md
│       ├── ADR-006-dual-distribution.md
│       └── ADR-007-mvp-model-a-v2-model-c.md
├── design/
│   ├── npc-lifecycle.md
│   ├── perception.md
│   ├── actions.md
│   ├── conversations.md
│   ├── memory.md
│   └── capabilities.md
└── planning/
    ├── milestones.md
    ├── mvp.md
    ├── implementation-roadmap.md
    ├── v2-backlog.md
    ├── risks.md
    ├── technical-spikes.md
    └── distribution.md
```

## How to read status labels

| Label | Meaning |
| --- | --- |
| **Defined** | Locked enough to implement against, unless a later ADR supersedes it |
| **Proposed** | Recommended shape; may change after spikes |
| **Hypothesis** | Plausible, unproven |
| **Future** | Out of MVP / current milestone |
| **Open** | Must not be silently decided; tracked in [open-questions.md](requirements/open-questions.md) |

## Requirement IDs

Functional and non-functional requirements use stable IDs (`FR-BOT-001`, `NFR-SEC-001`). Prefer updating an ID's text over inventing duplicates. Do not create large numbers of speculative requirements.

## What this documentation is not

- Not an implementation plan with dates
- Not a locked memory schema
- Not a choice of TTS/STT vendor
- Not a security audit of public dedicated servers
