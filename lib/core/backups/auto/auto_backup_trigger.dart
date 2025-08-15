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
    required this.isInProgress,
    required this.lastTriggerTime,
    required this.hasTriggeredOnce,
  });

  final bool isInProgress;
  final DateTime? lastTriggerTime;
  final bool hasTriggeredOnce;

  BackupTriggerState copyWith({
    bool? isInProgress,
    DateTime? Function()? lastTriggerTime,
    bool? hasTriggeredOnce,
  }) {
    return BackupTriggerState(
      isInProgress: isInProgress ?? this.isInProgress,
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
      isInProgress: false,
      lastTriggerTime: null,
      hasTriggeredOnce: false,
    );
  }

  Future<void> triggerOnAppLaunch() async {
    await _performTrigger(isInitialTrigger: true);
  }

  Future<void> _performTrigger({required bool isInitialTrigger}) async {
    final logger = ref.read(loggerProvider);

    // Guard against concurrent backups
    if (state.isInProgress) {
      logger.verbose(
        'AutoBackupTrigger',
        'Backup already in progress, skipping',
      );
      return;
    }

    try {
      state = state.copyWith(
        isInProgress: true,
        lastTriggerTime: () => DateTime.now(),
        hasTriggeredOnce: isInitialTrigger ? true : null,
      );

      logger.verbose('AutoBackupTrigger', 'Checking auto backup on app launch');

      final autoBackupSettings = ref.read(settingsProvider).autoBackup;
      await ref
          .read(backupProvider.notifier)
          .performAutoBackupIfNeeded(autoBackupSettings);
    } catch (e) {
      logger.error('AutoBackupTrigger', 'Auto backup trigger failed: $e');
    } finally {
      state = state.copyWith(isInProgress: false);
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
