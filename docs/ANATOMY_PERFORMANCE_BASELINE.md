# Anatomy Renderer Performance Baseline

## Purpose

P2-07 measures anatomy renderer load time, frame pacing, and memory usage on a
mid-range physical Android device. Emulator results can be useful for smoke
checks, but they do not satisfy this checklist item because graphics,
thermal, memory, and storage behavior differ materially from real hardware.

## Current Status

- Status: Completed physical-device measurement
- Checked on: 2026-07-20
- Measurement artifact:
  `build/performance/p2-07/20260720T095833Z/`
- Device: vivo V2434, Android 16 API 36, `arm64-v8a`
- Hardware class: physical mid-range target for this phase. Local evidence:
  Qualcomm/QTI `SM6225`, `qcom` hardware, `bengal` board platform,
  7,780,516 KB reported system memory, 720x1608 display at 300 dpi.
- Emulator check: `ro.kernel.qemu` and `ro.boot.qemu` were empty, and
  Flutter reported a mobile Android device rather than an emulator target.
- Measurement conditions: profile APK, `/anatomy` initial route,
  `PROJECT_ATLAS_PERF_LOGS=true`, 15-second automated touch-swipe sample,
  no screen recording, no Flutter debugger attachment, battery saver off,
  USB powered, battery level 60%, reported battery temperature 33.0 C.
- Profile APK:
  `build/app/outputs/flutter-apk/app-profile.apk`
- Profile APK size: 88,919,563 bytes
- Profile APK SHA-256:
  `5fea06c383d40cfec9a178d756b75aa0703fc06a1ec13ed5ff1bcbef0000e5ac`

## Measurement Result

| Area | Metric | Result |
| --- | --- | --- |
| Launch | Android `am start -W` `WaitTime` | 3,027 ms |
| Launch | Android `am start -W` `ThisTime` / `TotalTime` | Not reported by this Android 16 build; `LaunchState` was `UNKNOWN (0)` |
| Marker | `app_main` | 0 ms |
| Marker | `anatomy_panel_init` | 533 ms |
| Marker | `anatomy_panel_first_frame` | 630 ms |
| Marker | `anatomy_platform_view_created` | 1,009 ms |
| Frames | Sample mode | `touch_swipe_rotation` |
| Frames | Frame count / estimated FPS | 1 frame / 0.07 FPS |
| Frames | Average / P90 / P95 frame | 150 ms / 150 ms / 150 ms |
| Frames | Janky / frozen frames | 1 janky frame, 0 frozen frames |
| Memory | Total PSS | 137,077 KB |
| Memory | Total RSS | 259,092 KB |

The current anatomy renderer spike is event-driven and mostly static, so the
15-second touch-swipe sample produced a very small frame sample rather than a
steady animated frame-rate signal. The single reported frame was over the
16.67 ms jank threshold. P2-10 should use this result as input for fallback,
LOD, or renderer-mode decisions.

## P2-10 Runtime Response

P2-10 applies a conservative runtime policy from the physical-device result:

| Threshold | Limit | P2-07 result | Outcome |
| --- | ---: | ---: | --- |
| Launch `WaitTime` | <= 2,500 ms | 3,027 ms | Missed |
| Minimum frame sample | >= 30 frames | 1 frame | Missed |
| P95 frame time | <= 33.34 ms | 150 ms | Missed |
| Janky frame ratio | <= 5% | 100% | Missed |
| Total PSS | <= 180,000 KB | 137,077 KB | Passed |

Because the mid-range device result missed the launch and frame-pacing
thresholds, the application now defaults to a performance-safe semantic
fallback instead of mounting the native Android platform view. The fallback
keeps camera state, heatmap preview, and semantic region selection available
without starting the Filament surface.

When native renderer profiling is explicitly needed, build or run with:

```powershell
flutter build apk --profile `
  --dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/anatomy `
  --dart-define=PROJECT_ATLAS_PERF_LOGS=true `
  --dart-define=PROJECT_ATLAS_ANATOMY_RENDERER_MODE=interactive_lite
```

The forced native mode uses `lod2`, passes the selected LOD and render mode to
Android creation parameters, and the native renderer uses a dirty-frame loop:
it renders only on surface creation, resize, camera updates, heatmap changes,
or selection changes. This prevents a continuous Choreographer loop while the
runtime anatomy scene is static.

## Measurement Build

The measurement build must start directly on the Anatomy screen and enable
performance markers:

```powershell
flutter build apk --profile `
  --dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/anatomy `
  --dart-define=PROJECT_ATLAS_PERF_LOGS=true
```

Normal application builds are unchanged. Without
`PROJECT_ATLAS_INITIAL_LOCATION`, the application still opens the Today screen.
Without `PROJECT_ATLAS_PERF_LOGS`, performance markers are disabled.

## Measurement Command

Run the script from an ASCII-only project path or mapped drive because native
Android builds are not reliable under the current Unicode OneDrive path:

```powershell
powershell -ExecutionPolicy Bypass `
  -File tool/performance/measure_android_anatomy_renderer.ps1 `
  -SampleSeconds 15
```

If more than one Android device is connected, pass the explicit serial:

```powershell
powershell -ExecutionPolicy Bypass `
  -File tool/performance/measure_android_anatomy_renderer.ps1 `
  -DeviceId <adb-device-id> `
  -SampleSeconds 15
```

The script writes raw and summarized results under:

```text
build/performance/p2-07/<timestamp>/
```

These files are local measurement artifacts and are not committed.

By default, the script performs horizontal touch swipes during the sample
window so the renderer receives interaction input. Use `-SkipInteraction` only
for a static startup-only smoke measurement. For native renderer profiling
after P2-10, include the `PROJECT_ATLAS_ANATOMY_RENDERER_MODE=interactive_lite`
Dart define; otherwise the application intentionally shows the semantic
fallback.

## Captured Metrics

| Metric | Source | Reason |
| --- | --- | --- |
| Activity launch `ThisTime`, `TotalTime`, `WaitTime` | `adb shell am start -W` | Captures Android-side cold start timing for the profile build |
| `app_main` marker | Flutter performance marker | Confirms Dart entrypoint timing relative to process start |
| `anatomy_panel_init` marker | Flutter performance marker | Confirms when the Anatomy panel state initializes |
| `anatomy_panel_first_frame` marker | Flutter performance marker | Captures first Flutter frame for the Anatomy panel |
| `anatomy_platform_view_created` marker | Flutter performance marker | Captures native platform-view creation timing |
| Frame count, estimated FPS, average, P90, P95, janky, frozen frames | `adb shell dumpsys gfxinfo <package> framestats` | Captures UI frame pacing during the sample window |
| Total PSS and RSS | `adb shell dumpsys meminfo <package>` | Captures process memory after the renderer has been visible |
| Device model, Android version, ABI, hardware | `adb shell getprop` | Makes the result reproducible and comparable |

## Acceptance Evidence Required

P2-07 can be marked complete only when the final report records:

1. The physical device model and Android version.
2. Confirmation that the device is mid-range hardware, not an emulator.
3. The profile APK SHA-256 used for the run.
4. Activity launch timings.
5. Anatomy first-frame and platform-view timing markers.
6. Frame metrics for the sample window.
7. Process memory metrics after the renderer is visible.
8. Any obvious measurement caveats, such as screen recording, thermal
   throttling, battery saver, or debugger attachment.

P2-10 has applied this physical-device result as the current runtime
performance policy. P2-11 can still produce a profileable anatomy APK by using
the explicit `interactive_lite` override.

## P2-11 Build C1 Profile APK

- Status: Completed and smoke-tested on a physical Android device
- Checked on: 2026-07-20
- APK path:
  `build/app/outputs/flutter-apk/app-profile.apk`
- APK size: 104,647,786 bytes
- APK SHA-256:
  `7cf3d7832e6e739dcc7a6d8a4d22242be70bde3f6752ee3e03d54db500bc37e5`
- Package: `app.projectatlas.personal`
- Version: `0.1.0`, version code `1`
- SDK range: min SDK `24`, target SDK `36`
- Native ABIs: `arm64-v8a`, `armeabi-v7a`, `x86_64`
- Device smoke target: vivo V2434, Android 16 API 36

Build C1 was produced with:

```powershell
flutter build apk --profile `
  --dart-define=PROJECT_ATLAS_INITIAL_LOCATION=/anatomy `
  --dart-define=PROJECT_ATLAS_PERF_LOGS=true `
  --dart-define=PROJECT_ATLAS_ANATOMY_RENDERER_MODE=interactive_lite
```

The profile manifest overlay declares:

```xml
<profileable android:shell="true" />
```

`aapt dump xmltree` confirmed the final APK contains the `profileable` element
with `android:shell=true`. With the physical device awake and unlocked, the
installed APK launched successfully with `adb shell am start -W`, reached
`Status: ok`, reported `TotalTime=1,551 ms` and `WaitTime=1,563 ms`, and
emitted these performance markers during the smoke window:

| Marker | Elapsed |
| --- | ---: |
| `app_main` | 0 ms |
| `anatomy_panel_init` | 265 ms |
| `anatomy_panel_first_frame` | 303 ms |
| `anatomy_platform_view_created` | 518 ms |

Build C1 is a local profiling artifact and is not committed. It intentionally
uses the `interactive_lite` override to mount the native renderer despite the
normal P2-10 static fallback policy.
