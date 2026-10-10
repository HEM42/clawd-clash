import Foundation

// Hook entry point for Claude Code and Codex. Reads the hook JSON from stdin, records it, prints nothing,
// and always exits 0 so it can never block or disturb either.

let input = FileHandle.standardInput.readDataToEndOfFile()
// `--assistant codex` when installed in Codex's hooks.json; Claude Code's hooks pass nothing.
let args = CommandLine.arguments
let assistant = args.firstIndex(of: "--assistant").flatMap { args.indices.contains($0 + 1) ? args[$0 + 1] : nil } ?? "claude"
if let json = (try? JSONSerialization.jsonObject(with: input)) as? [String: Any] {
    StatusStore.apply(event: json, assistant: assistant)
}
exit(0)
