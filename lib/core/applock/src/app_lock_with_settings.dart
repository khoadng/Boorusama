// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../settings/providers.dart';
import 'app_lock.dart';

class AppLockWithSettings extends ConsumerWidget {
  const AppLockWithSettings({
    required this.child,
    super.key,
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
