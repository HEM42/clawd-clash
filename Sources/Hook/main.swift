import Foundation

// Hook entry point for Claude Code, Codex, Qwen Code, Gemini CLI, Copilot CLI and pi (through its extension). Reads the hook JSON from stdin, records it, prints nothing,
// and always exits 0 so it can never block or disturb either.

// Whatever the hook creates is yours alone (the state folder and its files are chmodded too, for older installs).
umask(0o077)

// At most `maxInput` bytes of stdin: a bigger event (a huge tool response) is skipped rather than held in memory.
let maxInput = 16 << 20
var input = Data()
while let chunk = try? FileHandle.standardInput.read(upToCount: 1 << 16), !chunk.isEmpty {
    input.append(chunk)
    if input.count > maxInput { exit(0) }
}
// `--assistant codex|qwen|gemini|copilot|pi` for the other AIs (Claude Code's hooks pass nothing), plus
// `--event <name>` where the payload doesn't name the event or uses that AI's own names.
let args = CommandLine.arguments
func value(_ flag: String) -> String? { args.firstIndex(of: flag).flatMap { args.indices.contains($0 + 1) ? args[$0 + 1] : nil } }
let assistant = value("--assistant") ?? "claude"
if let json = (try? JSONSerialization.jsonObject(with: input)) as? [String: Any] {
    StatusStore.apply(event: StatusStore.normalize(json, assistant: assistant, event: value("--event")), assistant: assistant)
}
exit(0)
