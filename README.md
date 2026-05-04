# orrery-magi

Sidecar binary for [orrery](https://github.com/OffskyLab/orrery) that hosts
the multi-model discussion engine **and** the spec generation /
verification / implementation pipeline.

`orrery-magi` is invoked via shims in the orrery binary (`orrery magi …`,
`orrery spec …`, `orrery spec-run …`, `orrery _spec-finalize …`) — the
shim resolves the sidecar (`$ORRERY_MAGI_PATH` → `~/.orrery/bin/orrery-magi`
→ `PATH`) and forwards the user's arguments after a strict capabilities +
MCP-schema handshake. Direct invocation also works.

```sh
# Multi-model discussion (Claude + Codex + Gemini debate, then summarize)
orrery magi "Should we use REST or GraphQL?"
orrery magi --rounds 3 --output report.md "API design"
orrery magi --roles balanced "Storage tradeoffs"

# Generate a structured spec from a discussion report
orrery spec discussion.md --output spec.md

# Run the spec pipeline
orrery spec-run --mode verify spec.md
orrery spec-run --mode implement spec.md          # detached; returns session_id
orrery spec-run --mode status --session-id <id>   # poll
```

The above commands all work **either** as `orrery <cmd>` (intercepted by
the orrery shim from v2.7.0 onwards) **or** as `orrery-magi <cmd>` direct.

## Install

`orrery-magi` is auto-installed by orrery's `install.sh` on macOS and
Linux from v2.7.0 onwards. To install manually:

```sh
# Homebrew (macOS)
brew install offskylab/orrery/orrery-magi

# Pre-built tarball (macOS / Linux)
curl -fsSL https://github.com/OffskyLab/orrery-magi/releases/latest/download/orrery-magi-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m).tar.gz | tar -xz -C ~/.orrery/bin/

# From source
git clone https://github.com/OffskyLab/orrery-magi
cd orrery-magi
swift build -c release
cp .build/release/orrery-magi ~/.orrery/bin/
```

## Subcommands

`orrery-magi` ships as a `ParsableCommand` root with `magi` as the
default subcommand:

| Subcommand | Purpose |
|---|---|
| `magi <topic>` *(default)* | Multi-round multi-model discussion → consensus report. Persists rounds + sessionMap to `~/.orrery/magi/<id>.json` so subsequent rounds can resume each tool's native session. |
| `spec <discussion.md>` | Read a discussion report and emit a structured implementation spec with the four mandatory headings (`介面合約` / `改動檔案` / `實作步驟` / `驗收標準`). |
| `spec-run --mode verify <spec.md>` | Parse the acceptance criteria + interface contract; sandbox-run the verification commands. Default dry-run; `--execute` actually runs; `--strict-policy` fails on policy_blocked. |
| `spec-run --mode implement <spec.md>` | Hand the spec to a delegate agent (claude / codex / gemini) in a *detached* subprocess. Returns immediately with `session_id` + `status: "running"`; a wrapper shell owns the lifecycle. |
| `spec-run --mode status --session-id <id>` | Poll the persisted state under `~/.orrery/spec-runs/{id}.json`. Supports `--include-log` and `--since-timestamp`. |
| `_spec-finalize <id> <rc>` *(hidden)* | Wrapper-shell callback. Captures the delegate's native session id via snapshot diff, computes `git diff --stat`, and writes terminal state. |

## Wire contract (consumed by the orrery shim)

`orrery-magi` exposes a stable wire contract for the orrery shim's
discovery + tool registration:

- `--version` — print the binary version string (`OrreryMagiVersion.current`).
- `--capabilities` — print a JSON document describing supported features,
  protocol versions, and MCP schema availability. From v1.1.0 the
  `features` object includes `multi_tool_schema` and `spec_runtime`,
  both `stable`.
- `--print-mcp-schema` — print the MCP schema for `orrery_magi` only
  (single dict, kept for backward compat with orrery v2.6.x).
- `--print-mcp-schemas` *(plural; new in v1.1.0)* — print an array of
  schemas for `orrery_magi`, `orrery_spec`, `orrery_spec_verify`, and
  `orrery_spec_implement`. The orrery shim uses this to register all
  four as MCP forwarders in one handshake.
- `--print-mcp-schema-for=<name>` *(new in v1.1.0)* — print one named
  schema. Useful for ad-hoc inspection.

`orrery_spec_status` is intentionally **not** in the schema array — the
orrery shim handles it inline by reading `~/.orrery/spec-runs/{id}.json`
directly via `SpecRunStateReader.load()`, avoiding a sidecar fork on
every poll.

The compatibility envelope is:
- `$schema_version`: `1` — overall capabilities schema version
- `compatibility.shim_protocol`: `1` — argv contract between shim and sidecar

See `docs/CONTRACT-OrreryMagi-Capabilities.md` for the full wire schema.

## License

Apache 2.0 — same as orrery.
