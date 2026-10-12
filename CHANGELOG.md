# Changelog

Avengers: Clawd Wars is a fork of [Clawd Wars](https://github.com/rodclemen/clawd-wars) 2.28.1. Its history up to the fork is in [CHANGELOG-clawd-wars.md](CHANGELOG-clawd-wars.md).

## 0.1.0 — unreleased

### Changed
- **New name and identity: Avengers: Clawd Wars.** It installs as `Avengers Clawd Wars.app` (bundle ID `com.rodclemen.avengersclawdwars`) and can sit on the same Mac as Clawd Wars. Its hook binary is `avengers-hook`, and each app only adds, replaces or removes hook entries whose command contains its own binary name, so the two never strip each other's hooks from `~/.claude/settings.json` or the other AIs' settings. Session state lives in `~/.claude/avengers-status`, the screen-saver feed in `~/Library/Application Support/Avengers Clawd Wars`, and the Copilot hook file is `~/.copilot/hooks/avengers-clawd-wars.json`. The cast and locations are still Star Wars for now.
