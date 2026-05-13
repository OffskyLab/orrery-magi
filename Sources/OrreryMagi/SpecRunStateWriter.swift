import ArgumentParser
import Foundation
import OrreryCore
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

public struct SpecRunStateWriter {
    public static func write(sessionId: String, state: SpecRunState) throws {
        try writeUnchecked(sessionId: sessionId, state: state)
    }

    public static func update(
        sessionId: String,
        mutate: (inout SpecRunState) throws -> Void
    ) throws {
        let target = SpecRunStateReader.statePath(sessionId: sessionId)
        guard FileManager.default.fileExists(atPath: target.path) else {
            throw ValidationError(L10n.SpecRun.sessionNotFound(sessionId))
        }

        let fd = open(target.path, O_RDWR)
        guard fd >= 0 else { throw SpecRunStateError.ioError(errno) }
        defer { close(fd) }
        guard flock(fd, LOCK_EX) == 0 else { throw SpecRunStateError.lockFailed(errno) }
        defer { _ = flock(fd, LOCK_UN) }

        let data = try Data(contentsOf: target)
        var state = try JSONDecoder().decode(SpecRunState.self, from: data)
        state = try SpecRunStateContract.upgrade(state)

        try mutate(&state)
        state.updatedAt = ISO8601DateFormatter().string(from: Date())
        state.version = SpecRunStateContract.currentVersion

        try writeUnchecked(sessionId: sessionId, state: state)
    }

    public static func createInitial(_ state: SpecRunState) throws {
        try SpecRunStateContract.upgrade(state)
        try FileManager.default.createDirectory(
            at: SpecRunStateReader.rootDir,
            withIntermediateDirectories: true
        )

        let target = SpecRunStateReader.statePath(sessionId: state.sessionId)
        let fd = open(target.path, O_WRONLY | O_CREAT | O_EXCL, 0o644)
        guard fd >= 0 else {
            let savedErrno = errno
            if savedErrno == EEXIST {
                throw SpecRunStateError.sessionAlreadyExists(state.sessionId)
            }
            throw SpecRunStateError.ioError(savedErrno)
        }
        defer { close(fd) }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = try encoder.encode(state)
        let written = data.withUnsafeBytes { buffer -> Int in
            #if canImport(Darwin)
            return Darwin.write(fd, buffer.baseAddress, data.count)
            #elseif canImport(Glibc)
            return Glibc.write(fd, buffer.baseAddress, data.count)
            #endif
        }
        guard written == data.count else {
            throw SpecRunStateError.ioError(errno)
        }
    }

    private static func writeUnchecked(sessionId: String, state: SpecRunState) throws {
        try SpecRunStateContract.upgrade(state)
        try FileManager.default.createDirectory(
            at: SpecRunStateReader.rootDir,
            withIntermediateDirectories: true
        )

        let target = SpecRunStateReader.statePath(sessionId: sessionId)
        let tmpName = "\(sessionId).\(UUID().uuidString).tmp"
        let tmp = target.deletingLastPathComponent().appendingPathComponent(tmpName)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys, .prettyPrinted]
        let data = try encoder.encode(state)

        try data.write(to: tmp)
        guard rename(tmp.path, target.path) == 0 else {
            let savedErrno = errno
            try? FileManager.default.removeItem(at: tmp)
            throw SpecRunStateError.ioError(savedErrno)
        }
    }
}
