// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../../../foundation/permissions.dart';
import '../../../themes/theme/types.dart';
import '../lan_permission_request_dialog.dart';
import 'export_data_notifier.dart';

class ExportDataPage extends ConsumerStatefulWidget {
  const ExportDataPage({super.key});

  @override
  ConsumerState<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends ConsumerState<ExportDataPage> {
  @override
  void initState() {
    super.initState();
    _requestPermissionIfNeeded();
  }

  Future<void> _requestPermissionIfNeeded() async {
    final handler = ref.read(localNetworkPermissionHandlerProvider);
    final isGranted = await handler.isGranted();

    if (!isGranted && mounted) {
      final result = await showLanPermissionRequestDialog(context);
      if (result ?? false) {
        await handler.request();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(exportDataProvider.notifier);
    final connectedToWifi = ref.watch(connectedToWifiProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          notifier.stopServer();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            context.t.settings.backup_and_restore.transfer_data,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: connectedToWifi
              ? ref
                    .watch(exportDataProvider)
                    .when(
                      data: (data) => _buildBody(data),
                      error: (error, _) => Text('Error: $error'),
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
              : _buildNoWifi(context),
        ),
      ),
    );
  }

  Widget _buildNoWifi(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 8,
        ),
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
            ),
            children: [
              TextSpan(
                text: context
                    .t
                    .settings
                    .backup_and_restore
                    .send_data
                    .no_networks_error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ExportDataState state) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfo(colorScheme, state),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                '${context.t.settings.backup_and_restore.send_data.how_to_transfer}:',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text.rich(
                context.t.settings.backup_and_restore.send_data.how_to_send(
                  settings: (_) => TextSpan(
                    text:
                        '${context.t.settings.settings} > ${context.t.settings.backup_and_restore.backup_and_restore}',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  receive: (_) => TextSpan(
                    text: context.t.settings.backup_and_restore.receive,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context
                            .t
                            .settings
                            .backup_and_restore
                            .send_data
                            .disclaimer,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(ColorScheme colorScheme, ExportDataState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ServerInfoTile(
            title: 'IP',
            value: state.serverUrl,
          ),
          ServerInfoTile(
            title: context.t.settings.backup_and_restore.send_data.name,
            value: state.serverName,
          ),
          ServerInfoTile(
            title: context.t.settings.backup_and_restore.send_data.version,
            value: state.appVersion,
          ),
          ServerInfoTile(
            title: context.t.settings.backup_and_restore.send_data.status.title,
            value: _buildStatus(state, context),
          ),
        ],
      ),
    );
  }

  String _buildStatus(ExportDataState state, BuildContext context) =>
      switch (state.status) {
        ServerStatus.stopped =>
          context.t.settings.backup_and_restore.send_data.status.stopped,
        ServerStatus.running =>
          context.t.settings.backup_and_restore.send_data.status.running,
        ServerStatus.broadcasting =>
          context.t.settings.backup_and_restore.send_data.status.broadcasting,
      };
}

class ServerInfoTile extends StatelessWidget {
  const ServerInfoTile({
    required this.title,
    required this.value,
    super.key,
  });

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SelectableText(
            value,
            style: TextStyle(
              color: theme.colorScheme.hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
