# CLAUDE.md — painter_ios

Hotwire Native iOS shell app for liftbyai (painter vertical v1).
Connects to the Rails backend at `https://app.liftbyai.com`.
Companion to `painter_saas` (Rails + JS) and `painter_android` (Kotlin).

## Quick start

```bash
# macOS only — Xcode required
brew install xcodegen
xcodegen generate                                  # creates PainterApp.xcodeproj
open PainterApp.xcodeproj

# Build + test via CLI
xcodebuild build -scheme PainterApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'

xcodebuild test -scheme PainterApp \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

> **Note:** The `.xcodeproj` is not committed — generate it locally with `xcodegen generate` after cloning.

## Stack

- **Language:** Swift 6, strict concurrency on
- **UI:** UIKit (Hotwire Native iOS is UIKit-based, not SwiftUI)
- **Navigation:** [hotwire-native-ios](https://github.com/hotwired/hotwire-native-ios) >= 1.2 via SPM
- **Bridge:** Strada (`BridgeComponent` subclasses in `PainterApp/Bridge/`)
- **Push:** APNS via `UNUserNotificationCenter`
- **Audio:** `AVPlayer` / `AVFoundation`
- **Dependencies:** SPM only — no CocoaPods, no Carthage

## Key entry points

| File | Purpose |
|---|---|
| `PainterApp/App/AppDelegate.swift` | `@main` entry, APNS registration callbacks |
| `PainterApp/Navigation/MainNavigator.swift` | `Navigator` setup, bridge registration, path config |
| `PainterApp/Configuration/AppConfig.swift` | Base URL (dev: `localhost:3000`, prod: `app.liftbyai.com`), path config URL |
| `PainterApp/Bridge/PushRegistrationComponent.swift` | APNS token → JS bridge |
| `PainterApp/Bridge/AudioPlayerComponent.swift` | Native `AVPlayer` driven by JS events |
| `PainterApp/Bridge/CallInitiateComponent.swift` | System dialer via `tel://` URL scheme |
| `project.yml` | xcodegen spec — source of truth for the Xcode project |

**Path config** is fetched at runtime from:
`https://app.liftbyai.com/configurations/ios_v1.json`

## MCP servers (auto-loaded from .claude/settings.json)

| Key | Package | Use for |
|---|---|---|
| `xcode` | `@getsentry/xcode-build-mcp` | Build, test, archive, simulator management, LLDB, SPM |
| `ios-simulator` | `ios-simulator-mcp` | UI accessibility tree, tap/swipe/type, screenshots |
| `spm` | `spm-mcp` | Add/update/resolve/clean Swift packages |

**Hard rule:** call the `xcode` MCP **before** writing any `xcodebuild` command.
Call `ios-simulator` MCP **before** writing any simulator interaction code.

## Skills (repo-scoped, in .claude/skills/)

| Skill | Invoke | When |
|---|---|---|
| `swift-agent-skills` | `/swift-agent-skills` | Swift 6 concurrency, XCTest, UIKit patterns |
| `apple-hig` | `/apple-hig` | Any new UI, navigation, or interaction design |
| `ios-simulator-skill` | `/ios-simulator-skill` | Build/run/verify loop on simulator |

## Bridge component pattern

Adding a new bridge component requires changes in **three repos**:

1. **JS** (`painter_saas`) — `app/javascript/controllers/bridge/<name>_controller.js`, extends `BridgeComponent`
2. **Swift** (this repo) — new `<Name>Component.swift` in `PainterApp/Bridge/`
3. **Kotlin** (`painter_android`) — equivalent Kotlin component

**Swift template:**
```swift
import HotwireNative

final class MyComponent: BridgeComponent {
    override class var name: String { "my-component" }   // must match JS controller identifier

    override func onReceive(message: Message) {
        guard message.event == "my-event" else { return }
        // handle, then optionally reply:
        let data = MessageData(metadata: [:], data: ["result": "ok"])
        reply(with: message(replacing: data))
    }
}
```

Register in `MainNavigator.swift` → `BridgeComponent.register([...])`.

## Conventions

- UIKit, not SwiftUI — Hotwire Native requires UIKit
- Swift 6 strict concurrency: `async/await`, `@MainActor`, no `DispatchQueue.main` hacks
- No third-party deps beyond `hotwire-native-ios` without a strong reason
- Dev vs. prod URL switching via `AppConfig` + `LOCAL_BASE_URL` env var (set in Xcode scheme)
- **Never commit:** `.xcuserdata/`, `*.mobileprovision`, `*.p8`, `*.p12`, `AuthKey_*.p8`
- Manual code signing — set `DEVELOPMENT_TEAM` in Xcode scheme, not in `project.yml`

## Testing

| Type | Target | Command |
|---|---|---|
| Unit | `PainterAppTests` | `xcodebuild test -scheme PainterApp ...` |
| UI | `PainterAppUITests` | `xcodebuild test -scheme PainterApp ...` |

- Bridge components: unit test `name` + `onReceive` dispatch; manual verify on simulator
- Use `/ios-simulator-skill` for the build+launch+screenshot loop

## Companion repos

| Repo | Location | Role |
|---|---|---|
| `painter_saas` | `~/code/saas-ruby/painter_saas` | Rails backend, JS bridge, path config, push token endpoint |
| `painter_android` | `~/code/saas-ruby/painter_android` | Kotlin shell — Kotlin bridge counterpart |

When adding a bridge component: open PRs in all three repos in one session.

## Layer guidance

| Layer | Invoke |
|---|---|
| Swift 6 concurrency / XCTest | `/swift-agent-skills` |
| Any new UI or screen | `/apple-hig` |
| Simulator build/run/verify | `/ios-simulator-skill` |
