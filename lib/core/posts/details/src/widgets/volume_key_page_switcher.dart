import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';

import 'post_details_page_view.dart';

mixin VolumeKeyPageSwitcher<T extends StatefulWidget> on State<T> {
  final ValueNotifier<double?> _volumeNotifier = ValueNotifier<double?>(null);

  ValueNotifier<double?> get volumeNotifier => _volumeNotifier;

  PostDetailsPageViewController get controller;

  int get totalPosts;

  void attachVolumeListener() {
    FlutterVolumeController.addListener(
      (volume) {
        final prev = _volumeNotifier.value;
        final cur = volume;

        // wait for the first volume change
        if (prev != null) {
          // make sure not in expand state
          if (!controller.isExpanded) {
            if (cur > prev) {
              _nextPage();
            } else if (cur < prev) {
              _previousPage();
            }
          }
        }

        _volumeNotifier.value = volume;
      },
    );
  }

  Future<void> _nextPage() async {
    if (controller.page < totalPosts - 1) {
      await controller.nextPage(
        duration: Duration.zero,
      );
    }
  }

  Future<void> _previousPage() async {
    if (controller.page > 0) {
      await controller.previousPage(
        duration: Duration.zero,
      );
    }
  }

  void detachVolumeListener() {
    FlutterVolumeController.removeListener();
  }
}
