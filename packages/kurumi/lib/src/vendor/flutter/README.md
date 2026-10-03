# Vendored Flutter code

Copies of Flutter framework files with a local fix that Flutter doesn't ship yet.

Source: Flutter 3.47.2, framework revision `d3b14c8769`.

| File | Upstream path | Change |
| --- | --- | --- |
| `scale.dart` | `packages/flutter/lib/src/gestures/scale.dart` | Adds `ScaleGestureRecognizer.panCausesAcceptance`. When false, moving one finger doesn't win the gesture arena, while pinching still does. Only the recognizer is kept. The `Scale*Details` types and callbacks come from Flutter. |
| `interactive_viewer.dart` | `packages/flutter/lib/src/widgets/interactive_viewer.dart` | Builds the vendored recognizer through `RawGestureDetector` with `panCausesAcceptance: widget.panEnabled`. `TransformationController`, `PanAxis` and `InteractiveViewerWidgetBuilder` come from Flutter. |

## Why

`InteractiveViewer` claims one-finger drags even with `panEnabled: false`. When a single fast move event crosses both the drag slop and the pan slop, the viewer wins over an enclosing `PageView`, so swipes in the post viewer get ignored. This is common on Android, whose touch slop is 8. `KurumiRawInteractiveViewer` enables panning only while zoomed, so drags at rest go to the page view.

## Maintenance

Keep Flutter's formatting and keep the changes limited to the ones listed above, so the files can be compared with upstream. When updating Flutter, copy the files from the new release again and reapply the changes. Delete this folder once a Flutter release ships `panCausesAcceptance` or equivalent behavior, and use Flutter's `InteractiveViewer` directly.
