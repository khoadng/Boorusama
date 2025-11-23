// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/loggers.dart';
import '../../settings/providers.dart';
import '../zip/providers.dart';

final backupTriggerProvider =
    NotifierProvider<BackupTriggerNotifier, BackupTriggerState>(
      BackupTriggerNotifier.new,
    );

class BackupTriggerState {
  const BackupTriggerState({
    required this.lastTriggerTime,
    required this.hasTriggeredOnce,
  });

  final DateTime? lastTriggerTime;
  final bool hasTriggeredOnce;

  BackupTriggerState copyWith({
    DateTime? Function()? lastTriggerTime,
    bool? hasTriggeredOnce,
  }) {
    return BackupTriggerState(
      lastTriggerTime: lastTriggerTime != null
          ? lastTriggerTime()
          : this.lastTriggerTime,
      hasTriggeredOnce: hasTriggeredOnce ?? this.hasTriggeredOnce,
    );
  }
}

class BackupTriggerNotifier extends Notifier<BackupTriggerState> {
  @override
  BackupTriggerState build() {
    return const BackupTriggerState(
      lastTriggerTime: null,
      hasTriggeredOnce: false,
    );
  }

  Future<void> triggerOnAppLaunch() async {
    await _performTrigger(isInitialTrigger: true);
  }

  Future<void> _performTrigger({required bool isInitialTrigger}) async {
    final logger = ref.read(loggerProvider);

    try {
      state = state.copyWith(
        lastTriggerTime: () => DateTime.now(),
        hasTriggeredOnce: isInitialTrigger ? true : null,
      );

      final autoBackupSettings = ref.read(settingsProvider).autoBackup;
      await ref
          .read(backupProvider.notifier)
          .performAutoBackupIfNeeded(autoBackupSettings);
    } catch (e) {
      logger.error('AutoBackupTrigger', 'Auto backup trigger failed: $e');
    }
  }
}

class AutoBackupAppLifecycle extends ConsumerStatefulWidget {
  const AutoBackupAppLifecycle({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<AutoBackupAppLifecycle> createState() =>
      _AutoBackupAppLifecycleState();
}

class _AutoBackupAppLifecycleState extends ConsumerState<AutoBackupAppLifecycle>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupTriggerProvider.notifier).triggerOnAppLaunch();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
