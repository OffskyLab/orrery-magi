import ArgumentParser
import Foundation
import OrreryCore

public struct SpecCommand: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
        commandName: "spec",
        abstract: L10n.Spec.abstract
    )

    @Argument(help: ArgumentHelp(L10n.Spec.inputHelp))
    public var input: String

    @Option(name: .shortAndLong, help: ArgumentHelp(L10n.Spec.outputHelp))
    public var output: String?

    @Option(name: .long, help: ArgumentHelp(L10n.Spec.profileHelp))
    public var profile: String?

    @Option(name: .long, help: ArgumentHelp(L10n.Spec.toolHelp))
    public var tool: String?

    @Flag(name: .long, help: ArgumentHelp(L10n.Spec.reviewHelp))
    public var review: Bool = false

    @Option(name: .shortAndLong, help: ArgumentHelp(L10n.Spec.envHelp))
    public var environment: String?

    public init() {}

    public func run() async throws {
        let store = EnvironmentStore.default
        let envName = environment ?? ProcessInfo.processInfo.environment["ORRERY_ACTIVE_ENV"]
        let selectedTool: Tool? = tool.flatMap { Tool(rawValue: $0) }

        let outputPath = try await SpecGenerator.generate(
            inputPath: input,
            outputPath: output,
            profile: profile,
            tool: selectedTool,
            review: review,
            environment: envName,
            store: store)
        print(outputPath)
    }
}
