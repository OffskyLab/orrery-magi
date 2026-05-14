import Foundation
import OrreryCore

/// `OrreryMagi` — multi-model consensus library.
///
/// The standalone home for Magi consensus orchestration after the
/// Phase 2 split: orrery's in-process orchestration was removed and
/// orrery-magi now ships exclusively as the sibling sidecar binary.
/// The `OrreryMagi` library target re-exports orchestration types
/// (`MagiOrchestrator`, `MagiRun`, `MagiPromptBuilder`,
/// `MagiResponseParser`) for any future programmatic consumers;
/// today the only consumer is the `orrery-magi` executable target.
public enum OrreryMagiModule {
    /// Semantic version of the library API surface. Bumped on any
    /// breaking change to the public DTOs, orchestrator entry points,
    /// or `MagiCommand` / `MagiMCPTools` registration signatures.
    /// 1.1.4 removes `OrreryMagiRoot` from the library surface (moved to
    /// the executable target with `@main`) to fix the async entry point.
    public static let apiVersion = "1.1.4"
}
