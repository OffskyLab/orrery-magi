import ArgumentParser

public struct OrreryMagiRoot: AsyncParsableCommand {
    public static let configuration = CommandConfiguration(
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

    public init() {}
}
