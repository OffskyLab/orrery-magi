/// Single source of truth for the orrery-magi binary version.
/// Bumped per orrery-magi's own release cycle — NOT tied to orrery's
/// version (though Phase 2 initial release both start at semantically
/// compatible points: orrery v2.4.0 + orrery-magi v0.1.0).
public enum OrreryMagiVersion {
    public static let current = "0.1.0"

    /// Integer version of the shim <-> orrery-magi argv protocol.
    /// Bumped only when the shim's argv construction changes in a way
    /// orrery-magi cannot accept.  v1 = Phase 2 initial protocol.
    public static let shimProtocol = 1

    /// Integer version of the --capabilities JSON schema itself.
    /// Bumped only on breaking changes to the capabilities document shape.
    public static let capabilitiesSchemaVersion = 1
}
