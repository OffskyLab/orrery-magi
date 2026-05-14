import ArgumentParser
import OrreryMagi

// Entry point. `@main` lives in the executable target (not a `main.swift`
// file) so the compiler's `@main` synthesis selects `AsyncParsableCommand`'s
// async `main()`. A `main.swift` calling `.main()` explicitly resolves to
// `ParsableCommand`'s synchronous `main()`, which falls through to the
// default sync `run()` that just prints help.
@main
struct OrreryMagiRoot: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "orrery-magi",
        version: OrreryMagiVersion.current,
        subcommands: [
            MagiCommand.self,
            SpecCommand.self,
            SpecRunCommand.self,
            SpecFinalizeCommand.self,
        ],
        defaultSubcommand: MagiCommand.self
    )

    init() {}
}
