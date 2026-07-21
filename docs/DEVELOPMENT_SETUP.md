# Development Setup

## Supported Local Environment

- Windows 11
- Flutter stable 3.44.4
- Dart 3.12.2
- Android Studio 2026.1.1 Patch 2
- OpenJDK 21 from the Android Studio runtime
- Android SDK Platform 36
- Android SDK Build Tools 36.0.0
- Android SDK Platform Tools 37.0.0
- Git for Windows 2.55.0

## Installed Locations

The local setup uses user-writable directories and does not require repository
files to contain machine-specific absolute paths.

- Flutter: `%LOCALAPPDATA%\Programs\Flutter`
- Android Studio: `%LOCALAPPDATA%\Programs\AndroidStudio\android-studio`
- Android SDK: `%LOCALAPPDATA%\Android\Sdk`
- JDK: `%LOCALAPPDATA%\Programs\AndroidStudio\android-studio\jbr`

The user environment defines `JAVA_HOME`, `ANDROID_HOME`, and
`ANDROID_SDK_ROOT`. Flutter, JDK, Android Studio, platform-tools, and
command-line tools are also present in the user `Path`.

## Repository Identity and Remote

- Project owner: Emir Ertunç
- GitHub account: [`emir-ertunc`](https://github.com/emir-ertunc)
- Public repository: [`emir-ertunc/project-atlas`](https://github.com/emir-ertunc/project-atlas)
- Git remote: `origin` over HTTPS

The owner's Git name and GitHub-provided noreply address are configured only
for this repository. `user.useConfigOnly` is enabled so commits cannot fall
back to an unintended machine identity. Validate the configuration with:

```powershell
git config --local --get user.name
git config --local --get user.email
git config --local --get user.useConfigOnly
git remote -v
```

## Toolchain Validation

Open a new PowerShell session after installation, then run:

```powershell
flutter --version
flutter doctor -v
adb version
```

The Flutter and Android toolchain checks must pass. Web and Windows desktop
targets are disabled because the initial application target is Android.

### Workspace Path Compatibility

The repository currently resides under a Unicode OneDrive path. If
`flutter analyze` reports a truncated LSP initialization message, create an
ASCII-only junction and run the command from that path:

```powershell
New-Item -ItemType Junction `
  -Path "$env:LOCALAPPDATA\ProjectAtlasWorkspace" `
  -Target "<repository-path>"
Set-Location "$env:LOCALAPPDATA\ProjectAtlasWorkspace"
flutter analyze
```

This junction references the same repository and does not copy project files.

Native Android builds also invoke CMake and Ninja. On Windows, those tools do
not reliably handle the repository's current Unicode path, and a junction is
not sufficient because Gradle resolves it to the original path. Map the
repository to an unused ASCII drive letter before building:

```powershell
subst P: "<repository-path>"
Set-Location P:\
flutter build apk --debug
Set-Location $HOME
subst P: /d
```

Use another drive letter if `P:` is already assigned. The mapping references
the existing files and does not create a second working copy.

## Foundation Validation Commands

Run code generation after changing a Drift definition:

```powershell
dart run build_runner build
```

Run localization generation after changing an ARB file:

```powershell
flutter gen-l10n
```

Run the local quality checks from the ASCII workspace path:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Continuous Integration

The `CI` GitHub Actions workflow runs for pushes, pull requests, and manual
dispatches. It uses Flutter 3.44.4 and Java 21, then performs these gates:

1. Resolve dependencies and regenerate localization and Drift sources.
2. Reject stale committed generated sources or a changed lockfile.
3. Validate anatomy asset budgets and reject bundled GLB/glTF files without
   required manifests.
4. Validate the anatomy shared rig, ten-exercise prototype contract, and
   P3-10 thirty-exercise compound animation contract.
5. Verify Dart formatting and static analysis.
6. Run all tests with coverage.
7. Build the Android debug APK.

Successful runs retain `coverage/lcov.info` and the debug APK as workflow
artifacts for 14 days. CI uses read-only repository permissions and does not
receive signing material.

## Physical Android Device Workflow

1. Open the device's system settings and enable Developer options.
2. Enable USB debugging inside Developer options.
3. Connect the unlocked device with a data-capable USB cable.
4. Select file transfer mode if the device offers a USB mode prompt.
5. Accept the host computer's debugging authorization prompt on the device.
6. Run the following commands:

```powershell
adb kill-server
adb start-server
adb devices -l
flutter devices
```

The ADB row must end in `device`, not `unauthorized` or `offline`, and Flutter
must list the same Android device.

If no device appears, install the device manufacturer's official Windows USB
driver. The Google USB driver is already available under the Android SDK at
`extras\google\usb_driver` for supported devices.

If the device is unauthorized, revoke existing USB debugging authorizations on
the device, reconnect it, and accept the new authorization prompt.

## Validation Record

- Flutter installation: Passed on 2026-07-06
- Android Studio and JDK installation: Passed on 2026-07-06
- Android SDK and licenses: Passed on 2026-07-06
- ADB installation and server startup: Passed on 2026-07-06
- Android emulator and API 35 x86_64 image: Passed on 2026-07-06
- Physical-device authorization: Pending a connected Android device
- Phase 1 local validation: Passed on 2026-07-07; see
  [the validation record](PHASE_1_VALIDATION.md)
- Phase 3 local and CI validation: Passed on 2026-07-20; see
  [the validation record](PHASE_3_VALIDATION.md)
- Phase 4 Build C2 local validation: Passed on 2026-07-20; see
  [the validation record](PHASE_4_VALIDATION.md)
- Phase 5 Build C3 local validation: Passed on 2026-07-21; see
  [the validation record](PHASE_5_VALIDATION.md)

## Build C0 Validation

- Date: 2026-07-06
- Package: `app.projectatlas.personal`
- Version: `0.1.0` (`versionCode` 1)
- Artifact: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 158,414,050 bytes
- SHA-256: `FC6E74CADA82762535BD375AC35A127B0B0BAE5A9960EDC9C27024AD53B0D4D1`
- Install target: `ProjectAtlas_API_35`, Android 15, API 35, x86_64
- Result: ADB installation, cold launch, foreground Activity, process health,
  and rendered foundation screen passed.

This is a development-only debug build. It is excluded from source control and
must not be distributed as a release artifact.

## Build C2 Validation

- Date: 2026-07-20
- Package: `app.projectatlas.personal`
- Version: `0.1.0` (`versionCode` 1)
- Artifact: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 177,137,788 bytes
- SHA-256:
  `E690A875EC69A2AAAAF8A16A4E000ED8F19F40156B00C04098A9FEC4F840D185`
- Build source: ASCII temporary workspace copy, copied back to the repository
  build output directory
- Result: Local quality gates, APK build, and APK metadata inspection passed.

This is a development-only debug build. It is excluded from source control and
must not be distributed as a release artifact.

## Build C3 Validation

- Date: 2026-07-21
- Package: `app.projectatlas.personal`
- Version: `0.1.0` (`versionCode` 1)
- Artifact: `build/app/outputs/flutter-apk/app-debug.apk`
- Size: 198,741,888 bytes
- SHA-256:
  `3D21929DED6D7975AC9D40C54D95B4F178FC7F28BC692E471DFB1970C81BC950`
- Build source: ASCII `subst` workspace at `P:\`, mapped to the existing
  repository path
- Result: Local quality gates, APK build, and APK metadata inspection passed.

This is a development-only debug build. It is excluded from source control and
must not be distributed as a release artifact.
