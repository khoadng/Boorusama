// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/foundation/animations.dart';
import '../../../core/foundation/toast.dart';

void guardLogin(WidgetRef ref, void Function() action) {
  if (!ref.readConfigAuth.hasLoginDetails()) {
    showSimpleSnackBar(
      context: ref.context,
      content: const Text(
        'post.detail.login_required_notice',
      ).tr(),
      duration: AppDurations.shortToast,
    );

    return;
  }

  action();
}

extension GuardLoginSnackBarX on WidgetRef {
  void showSuccessSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
  }) {
    showSuccessToast(
      context,
      message,
      backgroundColor: backgroundColor,
      duration: AppDurations.shortToast,
    );
  }
}
