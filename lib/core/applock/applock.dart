// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/settings/data.dart';
import 'package:boorusama/foundation/biometrics/app_lock.dart';

class AppLockWithSettings extends ConsumerWidget {
  const AppLockWithSettings({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLock(
      enable: ref.watch(settingsProvider.select((s) => s.appLockEnabled)),
      child: child,
    );
  }
}
