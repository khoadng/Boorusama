// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/animations/constants.dart';
import '../../../../../foundation/toast.dart';
import '../../../ref.dart';

void guardLogin(WidgetRef ref, void Function() action) {
  if (!ref.readConfigAuth.hasLoginDetails()) {
    showSimpleSnackBar(
      context: ref.context,
      content: Text(
        ref.context.t.post.detail.login_required_notice,
      ),
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
