import Foundation

// Claude Code hook entry point. Reads the hook JSON from stdin, records it, prints nothing,
// and always exits 0 so it can never block or disturb Claude Code.

let input = FileHandle.standardInput.readDataToEndOfFile()
if let json = (try? JSONSerialization.jsonObject(with: input)) as? [String: Any] {
    StatusStore.apply(event: json)
}
exit(0)
