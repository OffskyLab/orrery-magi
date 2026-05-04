# orrery-magi

Multi-model consensus subcommand for [orrery](https://github.com/OffskyLab/orrery).

`orrery-magi` is a standalone sidecar binary that drives Claude, Codex,
and Gemini through a structured multi-round discussion and produces a
consensus report. It's invoked via the `orrery magi …` shim:

```sh
orrery magi "Should we use REST or GraphQL?"
orrery magi --rounds 3 --output report.md "API design"
orrery magi --roles balanced "Storage tradeoffs"
```

The shim in orrery (≥ v2.6.0) finds this binary on `$ORRERY_MAGI_PATH`,
in `~/.orrery/bin/orrery-magi`, or on `PATH`, and forwards the user's
arguments via stdio after a strict capabilities + MCP-schema handshake.

## Install

`orrery-magi` is auto-installed by orrery's `install.sh` on macOS and
Linux from v2.6.0 onwards. To install manually:

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

## Contract

`orrery-magi` exposes a stable wire contract for the orrery shim:

- `--capabilities` — print a JSON document describing supported features,
  protocol versions, and MCP schema availability.
- `--print-mcp-schema` — print the MCP tool schema (consumed by orrery's
  MCP server to register the `orrery_magi` tool).
- `--version` — print the binary version string.

See `docs/CONTRACT-OrreryMagi-Capabilities.md` for the wire schema.

## License

Apache 2.0 — same as orrery.
