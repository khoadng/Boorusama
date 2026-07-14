// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../foundation/applock/applock.dart';
import '../settings/providers.dart';

class AppLockScope extends ConsumerWidget {
  const AppLockScope({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return AppLock(
      type: settings.appLockType,
      timeout: Duration(seconds: settings.appLockTimeoutSeconds),
      hideAppPreviewWhenBackgrounded: settings.hideAppPreviewWhenBackgrounded,
      child: child,
    );
  }
}
