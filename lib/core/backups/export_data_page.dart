// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import '../foundation/networking/network_provider.dart';
import '../servers/server_providers.dart';
import '../settings/src/widgets/settings_page_scaffold.dart';
import '../theme/app_theme.dart';
import 'sync_data_page.dart';

class ExportDataPage extends ConsumerStatefulWidget {
  const ExportDataPage({super.key});

  @override
  ConsumerState<ExportDataPage> createState() => _ExportDataPageState();
}

class _ExportDataPageState extends ConsumerState<ExportDataPage> {
  @override
  Widget build(BuildContext context) {
    final server = ref.watch(dataSyncServerProvider);

    return SettingsPageScaffold(
      title: const Text(''),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        ref.watch(localIPAddressProvider).when(
              data: (address) => Column(
                children: [
                  ValueListenableBuilder(
                    valueListenable: server.isRunning,
                    builder: (context, isRunning, _) {
                      return FilledButton.icon(
                        onPressed: () async {
                          if (isRunning) {
                            server.stopServer();
                          } else {
                            if (address == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error getting IP address'),
                                ),
                              );
                              return;
                            }

                            final messenger = ScaffoldMessenger.of(context);

                            final httpServer =
                                await server.startServer(address);

                            if (!mounted) return;

                            if (httpServer == null) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Error starting server'),
                                ),
                              );
                              return;
                            }

                            ref.read(serverPortProvider.notifier).state =
                                httpServer.port;
                          }
                        },
                        icon: FaIcon(
                          isRunning
                              ? FontAwesomeIcons.stop
                              : FontAwesomeIcons.play,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            isRunning ? 'Stop' : 'Start',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
              error: (error, _) => Text('Error: $error'),
              loading: () => const CircularProgressIndicator(),
            ),
        const SizedBox(height: 16),
        ValueListenableBuilder(
          valueListenable: server.isRunning,
          builder: (context, isRunning, _) {
            return ref.watch(localIPAddressProvider).when(
                  data: (address) {
                    if (isRunning) {
                      final port = ref.watch(serverPortProvider);
                      final serverUrl = 'http://$address:$port';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ServerInfoTile(
                                  title: 'IP',
                                  value: serverUrl,
                                ),
                                ServerInfoTile(
                                  title: 'Name',
                                  value: server.serverName,
                                ),
                                ServerInfoTile(
                                  title: 'Version',
                                  value: server.appVersion,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Text(
                              'You can connect to this device from other devices to import data. Make sure both devices are connected to the same network.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.hintColor,
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                  error: (error, _) => Text('Error: $error'),
                  loading: () => const CircularProgressIndicator(),
                );
          },
        ),
      ],
    );
  }
}

class ServerInfoTile extends StatelessWidget {
  const ServerInfoTile({
    super.key,
    required this.title,
    required this.value,
  });

  final String value;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
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
