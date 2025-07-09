// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';

// Project imports:
import '../../foundation/animations/constants.dart';
import '../../foundation/clipboard.dart';
import '../../foundation/toast.dart';
import '../boorus/engine/engine.dart';
import '../configs/config/types.dart';
import '../posts/post/post.dart';
import 'providers.dart';

mixin CopyImageMixin on ConsumerWidget {
  BooruConfigAuth get config;
  BooruConfigViewer get configViewer;

  Future<void> copyImage(
    WidgetRef ref,
    Post post,
  ) async {
    void showError(String message) {
      showErrorToast(
        ref.context,
        message,
        duration: AppDurations.longToast,
      );
    }

    final bytes = await ref.read(
      defaultCachedImageFileProvider(
        defaultPostImageUrlBuilder(
          ref,
          config,
          configViewer,
        )(post),
      ).future,
    );

    if (bytes == null) {
      showError('Failed to get image bytes');
      return;
    }

    try {
      await AppClipboard.copyImageBytes(bytes);
      showToast(
        'Copied',
        position: ToastPosition.bottom,
        textPadding: const EdgeInsets.all(8),
        duration: AppDurations.shortToast,
      );
    } on Exception catch (e) {
      showError('Failed to copy image: $e');
      return;
    }
  }
}
