// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../../../../widgets/circular_icon_button.dart';
import '../../pages/auth_config_changed_dialog.dart';
import '../../providers/bulk_download_notifier.dart';
import '../../types/bulk_download_session.dart';
import '../../types/download_configs.dart';
import '../../types/download_session.dart';

class BulkDownloadActionButtonBar extends StatelessWidget {
  const BulkDownloadActionButtonBar({
    required this.session,
    super.key,
  });

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context) {
    final status = session.session.status;

    if (!session.actionable) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(
        top: 4,
      ),
      child: Wrap(
        spacing: 12,
        children: [
          if (status == DownloadSessionStatus.pending)
            _StartPendingButton(session)
          else if (status == DownloadSessionStatus.dryRun)
            _StopDryRunButton(session),
          if (status == DownloadSessionStatus.running ||
              status == DownloadSessionStatus.paused)
            _CancelAllButton(session),
          if (status == DownloadSessionStatus.running)
            _PauseAllButton(session)
          else if (status == DownloadSessionStatus.paused)
            _ResumeAllButton(session),
          if (status == DownloadSessionStatus.running)
            _SuspendButton(session)
          else if (status == DownloadSessionStatus.suspended)
            _ResumeSuspensionButton(session),
        ],
      ),
    );
  }
}

class _StopDryRunButton extends ConsumerWidget {
  const _StopDryRunButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.forward,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).stopDryRun(sessionId);
      },
    );
  }
}

class _StartPendingButton extends ConsumerWidget {
  const _StartPendingButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;
    final notifier = ref.watch(bulkDownloadProvider.notifier);

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        notifier.startPendingSession(sessionId);
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.onPressed,
    required this.icon,
  });

  final VoidCallback onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CircularIconButton(
      padding: const EdgeInsets.all(8),
      backgroundColor: colorScheme.surfaceContainer,
      icon: Theme(
        data: ThemeData(
          iconTheme: IconThemeData(
            color: colorScheme.onSurfaceVariant,
            fill: 1,
            size: 18,
          ),
        ),
        child: icon,
      ),
      onPressed: onPressed,
    );
  }
}

class _CancelAllButton extends ConsumerWidget {
  const _CancelAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.stop,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).cancelSession(sessionId);
      },
    );
  }
}

class _PauseAllButton extends ConsumerWidget {
  const _PauseAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.pause,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).pauseSession(sessionId);
      },
    );
  }
}

class _SuspendButton extends ConsumerWidget {
  const _SuspendButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.solidFloppyDisk,
      ),
      onPressed: () {
        ref.read(bulkDownloadProvider.notifier).suspendSession(sessionId);
      },
    );
  }
}

class _ResumeSuspensionButton extends ConsumerWidget {
  const _ResumeSuspensionButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        ref
            .read(bulkDownloadProvider.notifier)
            .resumeSuspendedSession(
              sessionId,
              downloadConfigs: DownloadConfigs(
                authChangedConfirmation: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        AuthConfigChangedDialog(session: session),
                  );

                  return confirmed ?? false;
                },
              ),
            );
      },
    );
  }
}

class _ResumeAllButton extends ConsumerWidget {
  const _ResumeAllButton(
    this.session,
  );

  final BulkDownloadSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionId = session.id;

    return _ActionButton(
      icon: const Icon(
        FontAwesomeIcons.play,
      ),
      onPressed: () {
        ref
            .read(bulkDownloadProvider.notifier)
            .resumeSession(
              sessionId,
              downloadConfigs: DownloadConfigs(
                authChangedConfirmation: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) =>
                        AuthConfigChangedDialog(session: session),
                  );

                  return confirmed ?? false;
                },
              ),
            );
      },
    );
  }
}
