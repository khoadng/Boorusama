// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../backups/auto/auto_backup_section.dart';
import '../../../../backups/routes.dart';
import '../../../../backups/transfer/sync_data_page.dart';
import '../../../../backups/widgets.dart';
import '../../../../backups/zip/providers.dart';
import '../../widgets/settings_page_scaffold.dart';
import 'data_transfer_card.dart';

class BackupAndRestorePage extends ConsumerStatefulWidget {
  const BackupAndRestorePage({
    super.key,
  });

  @override
  ConsumerState<BackupAndRestorePage> createState() =>
      _BackupAndRestorePageState();
}

class _BackupAndRestorePageState extends ConsumerState<BackupAndRestorePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: Text(context.t.settings.backup_and_restore.backup_and_restore),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        _Title(
          title: context.t.settings.backup_and_restore.transfer_data,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.paperPlane,
                  ),
                  title: context.t.settings.backup_and_restore.send,
                  onPressed: () {
                    goToSyncDataPage(context, mode: TransferMode.export);
                  },
                ),
              ),
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.download,
                  ),
                  title: context.t.settings.backup_and_restore.receive,
                  onPressed: () {
                    goToSyncDataPage(context, mode: TransferMode.import);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _Title(
          title: context.t.settings.backup_and_restore.backup_data,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 12,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.fileExport,
                  ),
                  title: context.t.settings.backup_and_restore.export,
                  onPressed: () => _handleExportAll(),
                ),
              ),
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.fileImport,
                  ),
                  title: context.t.settings.backup_and_restore.import,
                  onPressed: () => _handleImport(),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () => _navigateToManualBackup(),
            icon: const Icon(Icons.tune, size: 16),
            label: Text(
              context.t.settings.backup_and_restore.advanced_export_import,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _Title(
          title: context.t.settings.backup_and_restore.auto_backup,
          extra: Tooltip(
            message: context.t.settings.backup_and_restore.auto_backup_tooltip,
            triggerMode: TooltipTriggerMode.tap,
            showDuration: const Duration(seconds: 5),
            child: const Icon(
              Icons.info,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const AutoBackupSection(),
        const SizedBox(height: 16),
      ],
    );
  }

  void _handleExportAll() {
    ref.read(backupProvider.notifier).exportAll(context);
  }

  void _navigateToManualBackup() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ManualBackupPage(),
      ),
    );
  }

  void _handleImport() {
    ref.read(backupProvider.notifier).importFromZip(context);
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
    this.extra,
  });

  final String title;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          if (extra != null) ...[
            const SizedBox(width: 8),
            extra!,
          ],
        ],
      ),
    );
  }
}
