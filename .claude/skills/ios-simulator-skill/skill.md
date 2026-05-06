---
name: ios-simulator-skill
description: iOS Simulator workflow skill — build, install, launch, and interact with the app via xcodebuild + xcrun simctl. Optimized for Claude Code's build/run/verify loop.
source: https://github.com/conorluddy/ios-simulator-skill
install: gh repo clone conorluddy/ios-simulator-skill .claude/skills/ios-simulator-skill
---

# iOS Simulator Skill

Source: [conorluddy/ios-simulator-skill](https://github.com/conorluddy/ios-simulator-skill)

## Install

```bash
gh repo clone conorluddy/ios-simulator-skill .claude/skills/ios-simulator-skill
```

## What it covers

- Build app to simulator with `xcodebuild`
- List available simulators (`xcrun simctl list`)
- Boot, install, and launch app on simulator
- Capture screenshots via `xcrun simctl io`
- Read logs with `xcrun simctl spawn`
- Interact with simulator via `ios-simulator` MCP server

## When to invoke

Use `/ios-simulator-skill` when:
- Verifying a new feature works in the simulator
- Debugging a bridge component interaction
- Taking before/after screenshots
- Running a full build + launch cycle

## Key commands

```bash
# Build
xcodebuild build -scheme PainterApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Test
xcodebuild test -scheme PainterApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# List simulators
xcrun simctl list devices available

# Launch
xcrun simctl launch booted com.liftbyai.painter
```
