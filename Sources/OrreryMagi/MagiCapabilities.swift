import Foundation

/// Produces the capabilities JSON document that describes this
/// orrery-magi binary to a caller (typically the orrery shim).
///
/// Stability contract: `docs/CONTRACT-OrreryMagi-Capabilities.md`
/// in the orrery-magi repo.  Additive changes don't bump
/// `$schema_version`; removals / renames do.
public enum MagiCapabilities {
    /// Produce the capabilities JSON as a pretty-printed UTF-8 string.
    public static func json() -> String {
        let doc = document()
        guard let data = try? JSONSerialization.data(
            withJSONObject: doc,
            options: [.prettyPrinted, .sortedKeys]
        ), let str = String(data: data, encoding: .utf8) else {
            return "{}"
        }
        return str
    }

    /// Produce the capabilities dictionary.  Exposed for testing.
    public static func document() -> [String: Any] {
        return [
            "$schema_version": OrreryMagiVersion.capabilitiesSchemaVersion,

            "tool": [
                "name": "orrery-magi",
                "version": OrreryMagiVersion.current
            ],

            "compatibility": [
                "shim_protocol": OrreryMagiVersion.shimProtocol
            ],

            "mcp_schema": [
                "available": true,
                "command": "--print-mcp-schema",
                "format": "mcp-tools-json"
            ],

            "features": [
                "roles": [
                    "status": "stable",
                    "values": MagiRolePreset.allCases.map { $0.rawValue }
                ],
                "spec_output": ["status": "stable"],
                "custom_roles": ["status": "stable"]
            ],

            "diagnostics": [
                "docs_url": "https://github.com/OffskyLab/orrery-magi",
                "upgrade_hint": "brew upgrade orrery-magi"
            ]
        ]
    }
}
