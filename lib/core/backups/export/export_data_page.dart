// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../theme/app_theme.dart';
import 'export_data_notifier.dart';

class ExportDataPage extends ConsumerStatefulWidget {
  const ExportDataPage({super.key});

  @override
  ConsumerState<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends ConsumerState<ExportDataPage> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(exportDataProvider.notifier);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          notifier.stopServer();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transfer data'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: ref.watch(exportDataProvider).when(
                data: (data) => _buildBody(data),
                error: (error, _) => Text('Error: $error'),
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildBody(ExportDataState state) {
    return Column(
      children: [
        Builder(
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
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
                        title: 'Name',
                        value: state.serverName,
                      ),
                      ServerInfoTile(
                        title: 'Version',
                        value: state.appVersion,
                      ),
                      ServerInfoTile(
                        title: 'Status',
                        value: state.status.name,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 8,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.hintColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                      children: [
                        const TextSpan(
                          text:
                              'Open the app on the other device and go to the ',
                        ),
                        TextSpan(
                          text: 'Settings > Backup and restore',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const TextSpan(
                          text:
                              ", then select 'Receive' and start import data from this device. All devices must be connected to the same network and you have to stay on this page until the transfer is complete.",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
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
