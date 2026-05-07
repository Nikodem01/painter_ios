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

## Dev loop (no Mac)

The maintainer of this repo does **not** have a Mac. There is no local Xcode, no local simulator, no local `xcodebuild`. The Quick start commands above are what CI runs on `macos-15` — they are not runnable here.

The actual dev loop:
1. Edit Swift / config / plist / yml in VSCode (Linux / WSL).
2. `git commit` locally.
3. `git push origin main` — triggers CI on `macos-15`.
4. `gh run watch <id>` (or watch in browser) — wait ~5 min for build + test.
5. If green: change is verified. If red: read `gh run view <id> --log-failed`, fix, push again.

**Implications:**
- CI is the build machine. Treat a green run as the only ground truth that Swift code compiles.
- Tests in `PainterAppTests` and `PainterAppUITests` are the strongest verification available without a real device. Lean on them.
- `paths-ignore` in [.github/workflows/ci.yml](.github/workflows/ci.yml) skips CI for `**.md` / `docs/**` / `.gitignore` / `LICENSE` so doc commits don't burn time.

**What CI cannot verify:**
- Hands-on simulator interaction (tap a button, see the dialer / Now Playing UI / permission prompt)
- Real-device APNS delivery (needs Apple Dev account + device)
- Lock-screen audio + Control Center behavior (needs a real device)
- Real Rails session through the WebView (CI doesn't run a Rails server)

For these, options are: borrow a Mac, rent a cloud Mac (MacInCloud / MacStadium / Codemagic), or ship to TestFlight via cloud-built signed IPA once an Apple Developer account is provisioned.

## Stack

- **Language:** Swift 6, strict concurrency on (`@MainActor`-isolated bridge components)
- **UI:** UIKit (Hotwire Native iOS is UIKit-based, not SwiftUI)
- **Navigation:** [hotwire-native-ios](https://github.com/hotwired/hotwire-native-ios) `from: 1.2.0` via SPM (currently resolves to 1.2.2)
- **Bridge:** `BridgeComponent` subclasses in `PainterApp/Bridge/`, registered through `Hotwire.registerBridgeComponents([...])` (Strada was folded into HotwireNative; the `Strada` import no longer exists)
- **Push:** APNS via `UNUserNotificationCenter`; `AppDelegate` caches the device token and notifies pending handlers (race-safe — bridge can request the token before or after the OS calls back)
- **Audio:** Native takeover with `AVPlayer` + `MPNowPlayingInfoCenter` + `MPRemoteCommandCenter` (lock-screen / Control Center / background playback). `Info.plist` declares `UIBackgroundModes = ["audio"]`.
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

A bridge component spans **three repos** and the JS controller is the contract — Swift and Kotlin must both conform to whatever the JS side sends and expects back.

1. **JS** (`painter_saas`) — `app/javascript/controllers/bridge/<name>_controller.js`, extends `BridgeComponent`. Register in `app/javascript/controllers/index.js`.
2. **Swift** (this repo) — new `<Name>Component.swift` in `PainterApp/Bridge/`. Register in [PainterApp/Navigation/MainNavigator.swift](PainterApp/Navigation/MainNavigator.swift) inside `Hotwire.registerBridgeComponents([...])`.
3. **Kotlin** (`painter_android`) — equivalent class. Register in the Android navigator counterpart.

The class `name` must match exactly across all three (e.g. `"audio-player"`).

**Swift template (HotwireNative 1.2.x):**
```swift
import HotwireNative

final class MyComponent: BridgeComponent {
    override class var name: String { "my-component" }   // must match JS `static component`

    // Decode incoming jsonData — there is NO message.data["key"] subscript
    private struct IncomingPayload: Decodable {
        let foo: String
    }

    // Encode outgoing replies — there is NO MessageData type
    private struct ReplyPayload: Encodable {
        let result: String
    }

    override func onReceive(message: Message) {
        switch message.event {
        case "my-event":
            guard let payload: IncomingPayload = message.data() else { return }
            handle(payload)
        default:
            break
        }
    }

    private func handle(_ payload: IncomingPayload) {
        // ... do work ...
        let reply = ReplyPayload(result: "ok")
        self.reply(to: "my-event", with: reply)   // replies to the last received "my-event" message
    }
}
```

`BridgeComponent` is `@MainActor`, so every override and instance method runs on main. Pure static helpers (no instance state) can be marked `nonisolated` so unit tests can call them without an actor hop.

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

- Bridge components: unit test `name` + any `nonisolated` pure helpers (e.g. `CallInitiateComponent.telURL(_:)`); manual verify on simulator. Don't try to instantiate a `BridgeComponent` in a unit test — its init takes a `BridgingDelegate` you'd have to mock and Swift 6 strict concurrency makes this awkward.
- UI test classes must be marked `@MainActor` (XCUIApplication's init/instance methods are main-isolated under Swift 6).
- Use `/ios-simulator-skill` for the build+launch+screenshot loop.

## CI

GitHub Actions builds and tests on every push and PR. Workflow: [.github/workflows/ci.yml](.github/workflows/ci.yml).

- **Runner:** `macos-15`. Public-repo Actions get **unlimited free macOS minutes**; private would be ~200/month (2,000 standard ÷ 10× macOS multiplier) — public is intentional, the shell repo has no secrets.
- **Xcode:** runner default (no manual `xcode-select`). Pinning a specific Xcode such as 16.0 hardcodes the SDK version (e.g. iOS 18.0) and clashes with the runtimes the runner image actually has installed.
- **Destination:** `platform=iOS Simulator,name=iPhone 16,OS=latest`.
- **Signing:** `CODE_SIGNING_ALLOWED=NO` for both build and test (no Apple Developer account / no Team ID set in `project.yml`).
- **Cache:** SwiftPM checkouts cached by `project.yml` hash — saves ~20s on warm runs.

If a step times out or the runner image bumps Xcode, look at the "Show toolchain versions and available simulators" step output in the run logs.

## APNS

**Currently simulator-only.** iOS 16+ simulators issue a stub APNS device token via `xcrun simctl push`, so the full pipeline (Swift → JS bridge → `POST /push_token` → `users.push_tokens`) is fully validatable on a simulator without a paid Apple Developer account.

To upgrade to real-device APNS later:
1. Provision an Apple Developer account; create an App ID for `com.liftbyai.painter` with the **Push Notifications** capability enabled.
2. Generate an APNS Auth Key (`.p8`) — store in 1Password / Rails credentials, never commit.
3. Add an `aps-environment` entitlement (`development` for dev, `production` for App Store builds). Create `PainterApp/Resources/PainterApp.entitlements`, set `CODE_SIGN_ENTITLEMENTS` in `project.yml`.
4. Set `DEVELOPMENT_TEAM` (Team ID) in the Xcode scheme — never in `project.yml`.
5. CI runs `CODE_SIGNING_ALLOWED=NO` and won't touch entitlements; an additional self-hosted or signed-build job is needed for TestFlight.

The Swift code already sends `platform: "apns"` (matching `PushTokensController::ALLOWED_PLATFORMS`) and uses `AppDelegate.requestAPNSToken(handler:)` so token plumbing is identical between simulator and device.

## Known gaps

- **No offline path-configuration default.** `MainNavigator` only loads from `.server(...)`; if the Rails server is unreachable on first launch, the app starts with empty path rules. Add a bundled `path-configuration.json` if/when this matters.
- **AudioPlayerComponent JS contract is half-shipped.** Swift expects the new `ready { url, title, artist, duration }` event, but the JS controller in `painter_saas` still only sends bare `play`/`pause` events from a DOM `<audio>` element. Until the JS controller is extended, native takeover does not actually play anything — the Swift side is just inert. Open the painter_saas PR to ship the rest.
- **CallInitiateComponent on Android.** If the Kotlin counterpart was scaffolded with the same `"dial"` event-name bug as iOS used to have, the Android side won't dial either. Verify in `painter_android`.
- **No real APNS yet.** See APNS section above.
- **No app icon, no launch screen polish.** `Info.plist` references `LaunchScreen` but no storyboard ships in `PainterApp/Resources/`. Generates a black launch on first run.
- **No interactive simulator verification possible from this machine.** See [Dev loop (no Mac)](#dev-loop-no-mac). Closing this gap requires either cloud Mac access or shipping to a TestFlight build on a real device.

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
