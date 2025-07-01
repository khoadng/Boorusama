// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension RiverpodExtended on Ref {
  /// Keeps the provider alive for [duration] after the last listener is removed.
  void cacheFor(Duration duration) {
    final keepAliveLink = keepAlive();
    Timer? disposeTimer;

    onCancel(() {
      // Prevent multiple timers
      disposeTimer?.cancel();
      disposeTimer = Timer(duration, () {
        keepAliveLink.close();
        disposeTimer = null;
      });
    });

    onResume(() {
      disposeTimer?.cancel();
      disposeTimer = null;
    });

    onDispose(() {
      disposeTimer?.cancel();
      disposeTimer = null;
    });
  }

  /// Invalidates the provider after [duration], even if there are active listeners.
  void invalidateSelfAfter(Duration duration) {
    Timer? timer;

    timer = Timer(duration, () {
      invalidateSelf();
      timer = null;
    });

    onDispose(() {
      timer?.cancel();
      timer = null;
    });
  }
}
