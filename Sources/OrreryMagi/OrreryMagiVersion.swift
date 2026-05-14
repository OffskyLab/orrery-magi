/// Single source of truth for the orrery-magi binary version.
/// Bumped per orrery-magi's own release cycle — NOT tied to orrery's
/// version. v1.1.4 fixes the async entry point: v1.1.1–1.1.3 shipped a
/// synchronous `main()` that made every AsyncParsableCommand subcommand
/// print help instead of running (breaking the orrery shim handshake).
public enum OrreryMagiVersion {
    public static let current = "1.1.4"

    /// Integer version of the shim <-> orrery-magi argv protocol.
    /// Bumped only when the shim's argv construction changes in a way
    /// orrery-magi cannot accept.  v1 = Phase 2 initial protocol.
    public static let shimProtocol = 1

    /// Integer version of the --capabilities JSON schema itself.
    /// Bumped only on breaking changes to the capabilities document shape.
    public static let capabilitiesSchemaVersion = 1
}
