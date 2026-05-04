import XCTest
@testable import OrreryMagi
import OrreryCore

final class SpecRunStateWriterTests: XCTestCase {

    private var tmpHome: URL!
    private var savedHome: String?

    override func setUp() {
        super.setUp()
        tmpHome = FileManager.default.temporaryDirectory
            .appendingPathComponent("orrery-state-tests-\(UUID().uuidString)", isDirectory: true)
        try? FileManager.default.createDirectory(at: tmpHome, withIntermediateDirectories: true)

        savedHome = ProcessInfo.processInfo.environment["ORRERY_HOME"]
        setenv("ORRERY_HOME", tmpHome.path, 1)
    }

    override func tearDown() {
        if let saved = savedHome {
            setenv("ORRERY_HOME", saved, 1)
        } else {
            unsetenv("ORRERY_HOME")
        }
        try? FileManager.default.removeItem(at: tmpHome)
        super.tearDown()
    }

    private func makeState(
        id: String = UUID().uuidString,
        status: String = "running"
    ) -> SpecRunState {
        SpecRunState.initial(sessionId: id, startedAt: "2026-04-21T00:00:00Z")
            .with { $0.status = status }
    }

    func testRootDir_usesOrreryHomeOverride() {
        XCTAssertTrue(
            SpecRunStateReader.rootDir.path.hasPrefix(tmpHome.path),
            "rootDir=\(SpecRunStateReader.rootDir.path) should start with tmpHome=\(tmpHome.path)"
        )
        XCTAssertEqual(SpecRunStateReader.rootDir.lastPathComponent, "spec-runs")
    }

    func testSessionPaths_shareCommonStem() {
        let id = "abc-123"
        XCTAssertEqual(SpecRunStateReader.statePath(sessionId: id).lastPathComponent, "abc-123.json")
        XCTAssertEqual(SpecRunStateReader.progressLogPath(sessionId: id).lastPathComponent, "abc-123.progress.jsonl")
        XCTAssertEqual(SpecRunStateReader.stdoutLogPath(sessionId: id).lastPathComponent, "abc-123.stdout.log")
        XCTAssertEqual(SpecRunStateReader.stderrLogPath(sessionId: id).lastPathComponent, "abc-123.stderr.log")
    }

    func testWrite_createsRootDirAndFile() throws {
        let state = makeState()
        XCTAssertFalse(SpecRunStateReader.exists(sessionId: state.sessionId))
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)
        XCTAssertTrue(SpecRunStateReader.exists(sessionId: state.sessionId))
    }

    func testWrite_thenLoad_roundTripsAllFields() throws {
        var state = makeState()
        state.delegateSessionId = "delegate-native-abc"
        state.preSessionSnapshot = ["older-1", "older-2"]
        state.completedSteps = ["step-1", "step-2"]
        state.touchedFiles = ["Foo.swift", "Bar.swift"]
        state.diffSummary = "3 files changed"
        state.failedStep = "step-3"
        state.childSessionIds = []
        state.executionGraph = nil
        state.lastError = "compile error"
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)

        let loaded = try SpecRunStateReader.load(sessionId: state.sessionId)
        XCTAssertEqual(loaded, state)
    }

    func testLoad_missingFile_throws() {
        XCTAssertThrowsError(
            try SpecRunStateReader.load(sessionId: "nonexistent-\(UUID().uuidString)")
        ) { err in
            let desc = String(describing: err)
            XCTAssertTrue(desc.contains("not found") || desc.contains("找不到"),
                          "expected sessionNotFound message, got: \(desc)")
        }
    }

    func testUpdate_mutateChangesAreWritten_andUpdatedAtIsStamped() throws {
        let state = makeState()
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)

        let original = try SpecRunStateReader.load(sessionId: state.sessionId)
        try SpecRunStateWriter.update(sessionId: state.sessionId) { s in
            s.status = "done"
            s.completedAt = "2026-04-21T01:00:00Z"
        }
        let updated = try SpecRunStateReader.load(sessionId: state.sessionId)
        XCTAssertEqual(updated.status, "done")
        XCTAssertEqual(updated.completedAt, "2026-04-21T01:00:00Z")
        XCTAssertNotEqual(updated.updatedAt, original.updatedAt)
    }

    func testUpdate_missingFile_throws() {
        XCTAssertThrowsError(try SpecRunStateWriter.update(
            sessionId: "nonexistent-\(UUID().uuidString)"
        ) { $0.status = "done" })
    }

    func testJSON_usesSnakeCaseKeys() throws {
        let state = makeState()
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)
        let content = try String(
            contentsOf: SpecRunStateReader.statePath(sessionId: state.sessionId),
            encoding: .utf8
        )
        XCTAssertTrue(content.contains("\"session_id\""))
        XCTAssertTrue(content.contains("\"started_at\""))
        XCTAssertTrue(content.contains("\"completed_steps\""))
        XCTAssertTrue(content.contains("\"touched_files\""))
        XCTAssertTrue(content.contains("\"child_session_ids\""))
        XCTAssertTrue(content.contains("\"execution_graph\""))
        XCTAssertTrue(content.contains("\"delegate_session_id\""))
        XCTAssertTrue(content.contains("\"pre_session_snapshot\""))
        XCTAssertFalse(content.contains("\"sessionId\""),
                       "Swift camelCase must not leak into JSON")
    }

    func testJSON_nullOptionalsAppearExplicitly() throws {
        let state = makeState()
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)
        let content = try String(
            contentsOf: SpecRunStateReader.statePath(sessionId: state.sessionId),
            encoding: .utf8
        )
        XCTAssertTrue(content.contains("\"completed_at\" : null")
            || content.contains("\"completed_at\": null")
            || content.contains("\"completed_at\":null"))
        XCTAssertTrue(content.contains("\"delegate_session_id\" : null")
            || content.contains("\"delegate_session_id\": null")
            || content.contains("\"delegate_session_id\":null"))
        XCTAssertTrue(content.contains("\"execution_graph\" : null")
            || content.contains("\"execution_graph\": null")
            || content.contains("\"execution_graph\":null"))
    }

    func testDI3ReservedFields_roundTripWithDefaults() throws {
        let state = makeState()
        XCTAssertEqual(state.childSessionIds, [])
        XCTAssertNil(state.executionGraph)
        try SpecRunStateWriter.write(sessionId: state.sessionId, state: state)
        let loaded = try SpecRunStateReader.load(sessionId: state.sessionId)
        XCTAssertEqual(loaded.childSessionIds, [])
        XCTAssertNil(loaded.executionGraph)
    }

    func testMultipleSessions_haveSeparateFiles() throws {
        let a = makeState()
        var b = makeState()
        b.status = "done"
        try SpecRunStateWriter.write(sessionId: a.sessionId, state: a)
        try SpecRunStateWriter.write(sessionId: b.sessionId, state: b)
        XCTAssertEqual(try SpecRunStateReader.load(sessionId: a.sessionId).status, "running")
        XCTAssertEqual(try SpecRunStateReader.load(sessionId: b.sessionId).status, "done")
    }
}

private extension SpecRunState {
    func with(_ mutate: (inout SpecRunState) -> Void) -> SpecRunState {
        var copy = self
        mutate(&copy)
        return copy
    }
}
