# Phorm iOS

Implementation of the Phorm score tracker. See `../docs/superpowers/specs/2026-05-25-phorm-ios-implementation-design.md` for the architecture spec and `../docs/superpowers/plans/2026-05-25-phorm-ios-implementation.md` for the implementation plan.

## Requirements
- Xcode 15.0+
- iOS 17.0+ (deployment target)
- [xcodegen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- Apple Developer account in Xcode → Settings → Accounts (only needed for device builds + CloudKit)

## Generating the project

The Xcode project file is generated from `project.yml`; it is **not** checked into git.

```sh
cd phorm-ios
xcodegen generate
open phorm-ios.xcodeproj
```

Regenerate whenever `project.yml` changes, or when files are added/removed.

## Building & testing from the CLI

```sh
# Build (simulator, no signing required)
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO build

# Run unit tests
xcodebuild -project phorm-ios.xcodeproj -scheme Phorm \
  -destination 'platform=iOS Simulator,name=iPhone 15 Pro' \
  CODE_SIGNING_ALLOWED=NO test
```

Substitute a different simulator name if iPhone 15 Pro isn't installed (`xcrun simctl list devices available | grep iPhone`).

## One-time setup for device builds

1. Open `phorm-ios.xcodeproj` in Xcode.
2. Select the Phorm target → Signing & Capabilities → set **Team** to your Apple Developer team.
3. Xcode auto-provisions the bundle ID + CloudKit container on first build.

## CloudKit container

Container ID: `iCloud.com.quyctd.phorm`

On first device build, Xcode auto-creates the container in the developer portal. Verify at https://developer.apple.com/account/resources/identifiers/list/cloudContainer.

After the first run that writes data, the CloudKit Console (https://icloud.developer.apple.com/dashboard/) shows the schema. **Before TestFlight, promote the schema from Development → Production** via the Console.

If you build on simulator only, CloudKit calls will fail silently (no container provisioned). The app works local-only; SwiftData persists locally.
