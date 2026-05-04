import Foundation

public enum MagiMCPTools {
    /// JSON-compatible dictionary describing the `orrery_magi` MCP tool.
    /// Single source of truth used by the `--print-mcp-schema` CLI mode.
    /// orrery's MCP server queries this binary with `--print-mcp-schema`
    /// at startup and registers the live schema as a forwarder.
    public static var schema: [String: Any] {
        return [
            "name": "orrery_magi",
            "description": "Start a multi-model discussion (Claude, Codex, Gemini) on a topic and produce a consensus report.",
            "inputSchema": [
                "type": "object",
                "properties": [
                    "topic": [
                        "type": "string",
                        "description": "Discussion topic. Use semicolons to separate sub-topics."
                    ],
                    "rounds": [
                        "type": "integer",
                        "description": "Maximum discussion rounds (default: 1 for MCP)"
                    ],
                    "tools": [
                        "type": "array",
                        "items": ["type": "string", "enum": ["claude", "codex", "gemini"]],
                        "description": "Participating tools (default: all installed)"
                    ],
                    "environment": [
                        "type": "string",
                        "description": "Environment name (default: active environment)"
                    ],
                    "roles": [
                        "type": "string",
                        "description": "Role preset (balanced, adversarial, security) or comma-separated role IDs"
                    ],
                    "spec": [
                        "type": "boolean",
                        "description": "Generate a spec from the discussion result (default: false)"
                    ]
                ],
                "required": ["topic"],
                "additionalProperties": false
            ]
        ]
    }

    public static var schemas: [[String: Any]] {
        [
            schema,
            [
                "name": "orrery_spec",
                "description": "Generate a structured implementation spec from a discussion report or any Markdown input.",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "input": [
                            "type": "string",
                            "description": "Path to the input Markdown file"
                        ],
                        "output": [
                            "type": "string",
                            "description": "Output path for the generated spec (optional)"
                        ],
                        "profile": [
                            "type": "string",
                            "description": "Spec profile name: default, minimal, rfc, or a custom template name"
                        ],
                        "review": [
                            "type": "boolean",
                            "description": "Enable dual-model review (default: false)"
                        ],
                        "environment": [
                            "type": "string",
                            "description": "Environment name (default: active environment)"
                        ]
                    ],
                    "required": ["input"],
                    "additionalProperties": false
                ]
            ],
            [
                "name": "orrery_spec_verify",
                "description": "Verify a spec's acceptance criteria. Default dry-run (no shell commands executed); pass execute=true to run sandboxed commands. Output is a structured JSON result with verification.test_results, diff_summary, and optional review. Exit code is authoritative from verify (review is advisory only).",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "spec_path": [
                            "type": "string",
                            "description": "Path to spec markdown file (relative to CWD or absolute)"
                        ],
                        "tool": [
                            "type": "string",
                            "enum": ["claude", "codex", "gemini"],
                            "description": "Delegate tool for optional review"
                        ],
                        "resume_session_id": [
                            "type": "string",
                            "description": "Accepted but ignored in verify mode (verify always uses a fresh session); appears as a note in stderr"
                        ],
                        "timeout": [
                            "type": "integer",
                            "description": "Overall seconds across all acceptance commands (default 600)"
                        ],
                        "per_command_timeout": [
                            "type": "integer",
                            "description": "Per-command seconds before SIGTERM (default 60)"
                        ],
                        "execute": [
                            "type": "boolean",
                            "description": "Disable dry-run and actually execute sandboxed shell commands. Default false (dry-run)."
                        ],
                        "strict_policy": [
                            "type": "boolean",
                            "description": "Treat any policy_blocked command as failure (non-zero exit). Default false."
                        ],
                        "review": [
                            "type": "boolean",
                            "description": "Spawn an advisory review after verify completes (only when verify fully passes). Default false."
                        ],
                        "environment": [
                            "type": "string",
                            "description": "Environment name (default: active environment)"
                        ]
                    ],
                    "required": ["spec_path"],
                    "additionalProperties": false
                ]
            ],
            [
                "name": "orrery_spec_implement",
                "description": "Run the implement phase of a spec. Spawns a delegate agent (claude-code/codex/gemini) in a detached subprocess that writes code per the spec's 介面合約 / 改動檔案 / 實作步驟 / 驗收標準 sections. Returns IMMEDIATELY with session_id + status='running'; use orrery_spec_status to poll until status becomes done/failed/aborted. The delegate is constrained (no git commit/push, no swift build/test — those belong to orrery_spec_verify).",
                "inputSchema": [
                    "type": "object",
                    "properties": [
                        "spec_path": [
                            "type": "string",
                            "description": "Path to spec markdown file (relative to CWD or absolute). Must contain all four mandatory headings: 介面合約, 改動檔案, 實作步驟, 驗收標準."
                        ],
                        "tool": [
                            "type": "string",
                            "enum": ["claude", "codex", "gemini"],
                            "description": "Delegate CLI. Omit to auto-pick the first available."
                        ],
                        "resume_session_id": [
                            "type": "string",
                            "description": "Orrery spec-run session UUID returned by a prior orrery_spec_implement call. Do NOT pass the delegate agent's native session id — orrery resolves delegate resume internally."
                        ],
                        "timeout": [
                            "type": "integer",
                            "description": "Overall seconds the delegate subprocess may run before the wrapper's watchdog sends SIGTERM. Default 3600 (1h). Pass 0 to disable."
                        ],
                        "environment": [
                            "type": "string",
                            "description": "Environment name (default: active environment)."
                        ]
                    ],
                    "required": ["spec_path"],
                    "additionalProperties": false
                ]
            ]
        ]
    }
}
