---
name: swift-agent-skills
description: Swift 6 and iOS development patterns from Hacking with Swift. Covers async/await, actors, Sendable, XCTest, UIKit, and SwiftUI conventions.
source: https://github.com/twostraws/swift-agent-skills
install: gh repo clone twostraws/swift-agent-skills ~/.claude/skills/swift-agent-skills
---

# Swift Agent Skills

Source: [twostraws/swift-agent-skills](https://github.com/twostraws/swift-agent-skills) by Paul Hudson (Hacking with Swift)

## Install

```bash
gh repo clone twostraws/swift-agent-skills .claude/skills/swift-agent-skills
```

## What it covers

- Swift 6 strict concurrency: `async/await`, `MainActor`, `Sendable`, actors
- XCTest and Swift Testing framework (`@Test`, `#expect`)
- UIKit patterns (this app is UIKit-based, not SwiftUI)
- SwiftUI patterns (for reference)
- Xcode project structure conventions
- Error handling idioms

## When to invoke

Use `/swift-agent-skills` before:
- Writing any Swift 6 concurrency code
- Writing XCTest unit or UI tests
- Unsure about UIKit lifecycle methods
- Adding a new feature to a bridge component
