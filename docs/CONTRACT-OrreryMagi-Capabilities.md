# orrery-magi Capabilities Contract

**Status**: v1 (Phase 2 initial) — 2026-04-23

This document pins the `--capabilities` JSON shape that the orrery
shim relies on for version + feature negotiation. Breaking changes
here require a coordinated bump of both orrery and orrery-magi.

## Invocation

```
orrery-magi --capabilities
```

Writes JSON to stdout. Exit code 0 on success. No side effects (no
environment reads beyond ARGV, no file I/O, no network). Must be
< 50 ms to execute on typical hardware.

## Schema

### v1 fields (all required)

| Field | Type | Semantics |
|---|---|---|
| `$schema_version` | integer | Bumped only on breaking schema changes. v1 = this document. |
| `tool.name` | string | Binary name; always `"orrery-magi"` |
| `tool.version` | string | SemVer; e.g. `"0.1.0"`. Used in error messages and telemetry. |
| `compatibility.shim_protocol` | integer | Bumped when the shim's argv-construction format changes and this binary can no longer accept the old format. |
| `mcp_schema.available` | boolean | `true` if `--print-mcp-schema` works. |
| `mcp_schema.command` | string | CLI argv tail to fetch the MCP schema (currently `"--print-mcp-schema"`). |
| `mcp_schema.format` | string | Format identifier; currently `"mcp-tools-json"` (a single tool-definition object). |
| `features` | object | Map of `feature_id -> {status, values?, version?, cli_flags?}`. See § Features. |
| `diagnostics.docs_url` | string | Canonical URL for documentation. |
| `diagnostics.upgrade_hint` | string | Actionable install/upgrade command. |

### Forward compatibility

- Unknown fields MUST be ignored by the shim. Additive changes do not
  bump `$schema_version`.
- Removals, renames, or type changes bump `$schema_version` to the
  next integer.
- The shim's minimum supported `$schema_version` is checked first; if
  the installed orrery-magi is newer than the shim understands, the
  shim must emit an actionable error and exit non-zero.

### Features object shape

Each feature is a stable string id mapped to a descriptor object:
- `status` (string, enum): one of `"stable"`, `"preview"`, `"deprecated"`.
- `values` (string array, optional): enum of allowed values when the
  feature is parameterised (e.g., the preset roles).
- `version` (string, optional): SemVer of this feature's own API, if it
  evolves independently of the tool version.
- `cli_flags` (string array, optional): the CLI flags that expose the
  feature, for shim-side introspection.

Current features (v1):
- `roles` — preset role names for the `--roles` flag.
- `spec_output` — `--spec` flag triggers spec generation after consensus.
- `custom_roles` — comma-separated role IDs are supported by `--roles`.

## Shim failure modes (hard fail, exit non-zero)

- Binary not found on PATH / not executable
- `--capabilities` JSON parse error
- `$schema_version` higher than the shim supports
- `compatibility.shim_protocol` incompatible with the shim's current
  argv format
- Required feature missing for the user-requested operation (e.g.,
  user passed `--roles` but `features.roles` is absent)

## Soft fail (warn + continue)

- Optional feature missing (e.g., `--spec` requested but
  `features.spec_output` absent): warn and continue without the
  optional behaviour. (Phase 2 initial release has no soft-fail
  paths — all current features are required.)

## 2026-07-01 review anchor

Capabilities contract evolution is reviewed alongside the
`OrreryMagi` public-surface contract anchor in the Orrery repo's
`docs/CONTRACT-OrreryMagi.md`.
