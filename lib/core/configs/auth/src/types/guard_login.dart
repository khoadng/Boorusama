// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../foundation/animations.dart';
import '../../../../foundation/toast.dart';
import '../../../ref.dart';

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
