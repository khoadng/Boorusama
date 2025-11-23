// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../auto/widgets.dart';
import '../routes.dart';
import '../transfer/sync_data_page.dart';
import '../zip/providers.dart';
import 'data_transfer_card.dart';
import 'manual_backup_page.dart';

class BackupSettingsSection extends ConsumerWidget {
  const BackupSettingsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
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
                  onPressed: () =>
                      ref.read(backupProvider.notifier).exportAll(context),
                ),
              ),
              Expanded(
                child: DataTransferCard(
                  icon: const FaIcon(
                    FontAwesomeIcons.fileImport,
                  ),
                  title: context.t.settings.backup_and_restore.import,
                  onPressed: () =>
                      ref.read(backupProvider.notifier).importFromZip(context),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: TextButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ManualBackupPage(),
              ),
            ),
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
