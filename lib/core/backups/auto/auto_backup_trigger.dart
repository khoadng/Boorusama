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

  Future<void> triggerOnLifecycleResume() async {
    if (!state.hasTriggeredOnce) return;
    await _performTrigger(isInitialTrigger: false);
  }

  Future<void> _performTrigger({required bool isInitialTrigger}) async {
    // Guard against concurrent backups
    if (state.isInProgress) {
      ref
          .read(loggerProvider)
          .logI('AutoBackupTrigger', 'Backup already in progress, skipping');
      return;
    }

    // Debounce frequent app resumes
    final now = DateTime.now();
    if (state.lastTriggerTime != null &&
        now.difference(state.lastTriggerTime!).inMinutes < 5) {
      ref
          .read(loggerProvider)
          .logI('AutoBackupTrigger', 'Recent trigger, skipping');
      return;
    }

    try {
      state = state.copyWith(
        isInProgress: true,
        lastTriggerTime: () => now,
        hasTriggeredOnce: isInitialTrigger ? true : null,
      );

      ref
          .read(loggerProvider)
          .logI('AutoBackupTrigger', 'Checking auto backup on app launch');

      final autoBackupSettings = ref.read(settingsProvider).autoBackup;
      await ref
          .read(backupProvider.notifier)
          .performAutoBackupIfNeeded(autoBackupSettings);
    } catch (e) {
      ref
          .read(loggerProvider)
          .logE('AutoBackupTrigger', 'Auto backup trigger failed: $e');
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      ref.read(backupTriggerProvider.notifier).triggerOnLifecycleResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
