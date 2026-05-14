/// Single source of truth for the orrery-magi binary version.
/// Bumped per orrery-magi's own release cycle — NOT tied to orrery's
/// version. v1.1.1 fixes cross-platform Linux builds by replacing Darwin
/// imports and NS-prefixed ObjC classes with Swift-native equivalents.
public enum OrreryMagiVersion {
    public static let current = "1.1.1"

    /// Integer version of the shim <-> orrery-magi argv protocol.
    /// Bumped only when the shim's argv construction changes in a way
    /// orrery-magi cannot accept.  v1 = Phase 2 initial protocol.
    public static let shimProtocol = 1

    /// Integer version of the --capabilities JSON schema itself.
    /// Bumped only on breaking changes to the capabilities document shape.
    public static let capabilitiesSchemaVersion = 1
}
