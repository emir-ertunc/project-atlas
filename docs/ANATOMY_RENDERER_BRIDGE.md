# Android Anatomy Renderer Bridge

## Purpose

P2-05 establishes the Android renderer boundary for the anatomy spike. P2-06
adds the interaction contract for camera orbit, zoom, semantic picking, and
muscle heatmap state. Flutter owns product state, navigation, localization,
gesture interpretation, and training behavior. Android owns the native Filament
surface, render loop, swapchain lifecycle, camera application, and future GLB
loading details.

P6-07 reuses the same heatmap boundary for training-derived anatomy overlays.
Trained-muscle, weekly-volume, and fatigue maps are calculated in Flutter from
local workout evidence and exercise-catalog muscle mappings, then passed to
`setHeatmap` as normalized semantic muscle-region scores. No platform-channel
method or native renderer ownership changes are required.

No anatomy GLB is bundled in this step. The P2-04 GLB outputs remain external
until a later checklist item explicitly reviews and packages runtime assets.

## Android Runtime Dependencies

| Dependency | Version | Purpose | License |
| --- | --- | --- | --- |
| `com.google.android.filament:filament-android` | `1.73.0` | Filament engine, renderer, scene, camera, swapchain, and Android native libraries | Apache-2.0 |
| `com.google.android.filament:gltfio-android` | `1.73.0` | GLB/glTF loader dependency reserved for the next renderer step | Apache-2.0 |

Filament `1.74.0` is listed in the upstream README, but Maven resolution in
the validated local build resolves `1.73.0` and does not resolve `1.74.0`.
The project therefore pins `1.73.0` until the later version is available from
the configured repositories and passes Android build validation.

## Flutter Contract

Flutter exposes the renderer through:

- View type: `project_atlas/anatomy_renderer`
- Method channel: `project_atlas/anatomy_renderer_bridge`
- Dart bridge:
  [`anatomy_renderer_bridge.dart`](../lib/features/anatomy/platform/anatomy_renderer_bridge.dart)
- Presentation wrapper:
  [`anatomy_renderer_panel.dart`](../lib/features/anatomy/presentation/anatomy_renderer_panel.dart)

The method channel currently supports:

| Method | Required arguments | Return |
| --- | --- | --- |
| `getCapabilities` | None | Platform, backend, view type, GLB support flag, orbit/zoom/picking/heatmap flags, asset-bundled flag, LOD support, default render mode, render-loop mode, and required GLB node extras |
| `setCameraPose` | `viewId`, `yawDegrees`, `pitchDegrees`, `zoom` | Normalized camera pose |
| `setHeatmap` | `viewId`, `heatmap` keyed by semantic muscle region ID with scores from `0.0` to `1.0` | Renderer state including sanitized heatmap |
| `selectRegion` | `viewId`, nullable `regionId` | Renderer state including selected region |
| `pick` | `viewId`, `normalizedX`, `normalizedY` | Hit flag, nullable semantic region ID, and normalized coordinates |
| `getState` | `viewId` | Renderer state snapshot |

The Flutter widget passes localized content description text and the expected
GLB metadata fields as platform-view creation parameters. It also passes the
initial camera pose, initial heatmap, pickable semantic region IDs, selected
LOD tier, render mode, fallback reason, and missed performance threshold IDs.

## Interaction Contract

- Camera orbit is represented by `yawDegrees`, `pitchDegrees`, and `zoom`.
- Flutter clamps pitch to `-70..70` degrees and zoom to `1.2..8.0`.
- Android applies the same bounds before updating the Filament camera.
- Drag gestures rotate the camera; pinch scale updates zoom.
- Taps are normalized to the platform-view bounds before crossing the method
  channel.
- Heatmaps are keyed by P2-03 semantic muscle region IDs and clamp every score
  to `0.0..1.0`.
- P6-07 training heatmaps use the same score range and semantic IDs, so the
  current fallback renderer and future GLB material highlighting share one
  contract.
- Non-Android targets and widget tests use the same semantic IDs with a safe
  fallback picker, so interaction behavior remains testable without native
  renderer access.

The P2-06 picker is a semantic preview because the runtime GLB is still not
bundled. Android keeps a registered platform-view state table and returns a
deterministic semantic region from the supplied pickable IDs. When the reviewed
GLB is packaged, mesh hit testing must resolve to the same `muscle_region_id`
contract and heatmap highlighting must apply material/color changes to matching
GLB nodes without changing the Flutter API.

## Android Contract

Android registers the platform view in `MainActivity.configureFlutterEngine`.
The native view:

1. Initializes Filament.
2. Creates an `Engine`, `Renderer`, `Scene`, `View`, and `Camera`.
3. Hosts a `SurfaceView` inside a Flutter platform view.
4. Creates and destroys a swapchain from the Android surface lifecycle.
5. Renders the empty scene on dirty Choreographer frames.
6. Registers the view by Flutter `viewId` for method-channel interaction.
7. Applies bounded camera pose updates to the Filament camera.
8. Stores semantic heatmap and selection state keyed by muscle region ID.
9. Releases Filament resources when Flutter disposes the platform view.

The renderer remains asset-light in P2-06. This keeps lifecycle, bridge, and
interaction correctness isolated before later asset packaging and performance
budget steps bind the contract to real GLB nodes.

## P2-10 Performance Policy

P2-10 applies the P2-07 physical-device result as a runtime guardrail. The
current result missed the mid-range launch and frame-pacing thresholds, and no
runtime anatomy GLB is bundled yet. Therefore the Flutter layer defaults to
`static_fallback` and does not mount the Android platform view in normal
builds. The fallback keeps camera state, heatmap preview, and semantic
selection active using Flutter-owned state.

Native renderer profiling remains available through:

```text
PROJECT_ATLAS_ANATOMY_RENDERER_MODE=interactive_lite
```

When this override is supplied, Flutter creates the Android platform view with:

| Creation parameter | Value |
| --- | --- |
| `renderMode` | `interactive_lite` |
| `lodTier` | `lod2` |
| `performanceFallbackReason` | `manual_override` |
| `missedPerformanceThresholds` | Threshold IDs from the latest physical-device measurement |

Android reports `supportsLod=true`, `supportedLodTiers=["lod2"]`,
`defaultLodTier=lod2`, `defaultRenderMode=interactive_lite`, and
`renderLoopMode=dirty_frame`. The dirty-frame loop renders only after surface
creation, surface resize, camera changes, heatmap changes, or selection
changes. It avoids a continuous Choreographer loop while the anatomy spike is
static.

## Semantic Asset Contract

P2-05 preserves the P2-04/P2-03 identity boundary. Future GLB loading must use
node names and these node extras rather than source OBJ filenames or localized
labels:

- `muscle_region_id`
- `semantic_group_id`
- `side`
- `reduction_slot`
- `source_element_ids`

## Platform Behavior

- Android: defaults to the Flutter semantic fallback after the P2-07 threshold
  miss; native Filament rendering is available for explicit profiling through
  `interactive_lite`.
- Non-Android Flutter targets and widget tests: show a safe fallback panel.
- iOS: remains an architecture placeholder until iOS renderer work begins.

## Validation Notes

On this Windows workspace, full Android APK builds must run from an ASCII drive
alias because CMake and Ninja do not reliably handle the current Unicode
OneDrive path. The command pattern is recorded in
[development setup](DEVELOPMENT_SETUP.md).

The P2-05 validated debug build output was:

- `P:\build\app\outputs\flutter-apk\app-debug.apk`
- Size: 208,534,405 bytes
- SHA-256:
  `8e51ee81b1d760973662233a6f4bdcb41399e4d3933f37d91ea4d836b4b5c616`

This APK is a development artifact and is not committed.

P2-06 validation adds:

- Dart analyzer coverage for the Flutter bridge, controller, and panel.
- Widget and unit tests for camera normalization, heatmap clamping, fallback
  picking, and method-channel arguments.
- Clean Android Kotlin compilation for the Filament platform view and
  interaction bridge.

The P2-06 validated debug build output was:

- `P:\build\app\outputs\flutter-apk\app-debug.apk`
- Size: 175,596,706 bytes
- SHA-256:
  `956194ae27cb2acefcaa35215544d088db3e8922f5694103d1df5fa7ad5f146d`

This APK is a development artifact and is not committed.

The P2-11 Build C1 profileable anatomy APK output was:

- `P:\build\app\outputs\flutter-apk\app-profile.apk`
- Size: 104,647,786 bytes
- SHA-256:
  `7cf3d7832e6e739dcc7a6d8a4d22242be70bde3f6752ee3e03d54db500bc37e5`
- Build defines:
  `PROJECT_ATLAS_INITIAL_LOCATION=/anatomy`,
  `PROJECT_ATLAS_PERF_LOGS=true`,
  `PROJECT_ATLAS_ANATOMY_RENDERER_MODE=interactive_lite`

`aapt dump xmltree` confirmed the profile APK contains
`<profileable android:shell="true" />`. The APK installed on a physical Android
device and launched the native anatomy platform view for smoke validation with
`anatomy_platform_view_created` at 518 ms.

The P6-11 Build C4 personalized anatomy alpha APK output was:

- `P:\build\app\outputs\flutter-apk\app-debug.apk`
- Size: 198,872,646 bytes
- SHA-256:
  `7B7A4EB193CB78A1AA3320199C1DA9547B5637387F799626FDBCE82251731393`
- Build define: `PROJECT_ATLAS_INITIAL_LOCATION=/anatomy`

Build C4 opens to the Anatomy branch and keeps the P2-10 default renderer
policy unchanged. The native Filament view remains behind the explicit
`interactive_lite` override, while the packaged checkpoint exposes the
measurement-based visual estimate, disclosure, and training heatmaps through
the Flutter fallback path.
