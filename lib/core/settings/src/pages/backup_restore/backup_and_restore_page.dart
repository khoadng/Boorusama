// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../backups/routes.dart';
import '../../../../backups/sources/providers.dart';
import '../../../../backups/transfer/sync_data_page.dart';
import '../../../../theme/app_theme.dart';
import '../../widgets/settings_page_scaffold.dart';

class BackupAndRestorePage extends ConsumerStatefulWidget {
  const BackupAndRestorePage({
    super.key,
  });

  @override
  ConsumerState<BackupAndRestorePage> createState() => _DownloadPageState();
}

class _DownloadPageState extends ConsumerState<BackupAndRestorePage> {
  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: Text(context.t.settings.backup_and_restore.backup_and_restore),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        const _Title(
          title: 'Transfer data',
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
                  title: 'Send',
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
                  title: 'Receive',
                  onPressed: () {
                    goToSyncDataPage(context, mode: TransferMode.import);
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        const _Title(
          title: 'Manual backup',
        ),
        const SizedBox(height: 8),
        _buildProfiles(),
        const SizedBox(height: 8),
        _buildFavoriteTags(),
        const SizedBox(height: 8),
        _buildBookmarks(),
        const SizedBox(height: 8),
        _buildBlacklistedTags(),
        const SizedBox(height: 8),
        _buildSearchHistories(),
        const SizedBox(height: 8),
        _buildBulkDownloads(),
        const SizedBox(height: 8),
        _buildSettings(),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildProfiles() {
    final source = ref.watch(booruConfigsBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildBlacklistedTags() {
    final source = ref.watch(blacklistedTagsBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildFavoriteTags() {
    final source = ref.watch(favoriteTagsBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildBookmarks() {
    final source = ref.watch(bookmarksBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildSettings() {
    final source = ref.watch(settingsBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildSearchHistories() {
    final source = ref.watch(searchHistoryBackupSourceProvider);
    return source.buildTile(context);
  }

  Widget _buildBulkDownloads() {
    final source = ref.watch(downloadsBackupSourceProvider);
    return source.buildTile(context);
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 8,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
    );
  }
}

class DataTransferCard extends StatelessWidget {
  const DataTransferCard({
    required this.icon,
    required this.title,
    required this.onPressed,
    super.key,
  });

  final Widget icon;
  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconTheme = theme.iconTheme;
    final borderRadius = BorderRadius.circular(16);

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: borderRadius,
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Theme(
                  data: theme.copyWith(
                    iconTheme: iconTheme.copyWith(
                      size: 18,
                      color: theme.colorScheme.hintColor,
                    ),
                  ),
                  child: icon,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
