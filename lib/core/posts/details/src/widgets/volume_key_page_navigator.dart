// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import '../../../../foundation/keyboard.dart';
import '../../../../settings/settings.dart';
import 'post_details_page_view.dart';

class VolumeKeyPageNavigator with KeyboardListenerMixin {
  VolumeKeyPageNavigator({
    required this.pageViewController,
    required this.totalPosts,
    required this.visibilityNotifier,
    required this.getSettings,
  });

  final PostDetailsPageViewController pageViewController;
  final int totalPosts;
  final ValueNotifier<bool> visibilityNotifier;

  final Settings Function() getSettings;

  void initialize() {
    // Workaround to bring the keyboard focus to the app
    // https://github.com/flutter/flutter/issues/71144
    Future.delayed(Duration.zero, () {
      SystemChannels.textInput.invokeMethod('TextInput.show');
      SystemChannels.textInput.invokeMethod('TextInput.hide');
    });

    registerListener(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    // make sure user has enabled the feature
    if (!getSettings().volumeKeyViewerNavigation) return false;

    // only handle key event when the page is visible
    if (!visibilityNotifier.value) return false;

    // make sure not in expand state
    if (pageViewController.isExpanded) return false;

    if (isKeyPressed(
      LogicalKeyboardKey.audioVolumeUp,
      event: event,
    )) {
      _nextPage();
    } else if (isKeyPressed(
      LogicalKeyboardKey.audioVolumeDown,
      event: event,
    )) {
      _previousPage();
    }

    return false;
  }

  void dispose() {
    removeListener(_handleKeyEvent);
  }

  Future<void> _nextPage() async {
    if (pageViewController.page < totalPosts - 1) {
      await pageViewController.nextPage(
        duration: Duration.zero,
      );
    }
  }

  Future<void> _previousPage() async {
    if (pageViewController.page > 0) {
      await pageViewController.previousPage(
        duration: Duration.zero,
      );
    }
  }
}