import 'package:bonsoir/bonsoir.dart';
import 'package:boorusama/core/backups/backups.dart';
import 'package:boorusama/core/blacklists/blacklists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/export_import/export_import.dart';
import 'package:boorusama/core/favorited_tags/favorited_tags.dart';
import 'package:boorusama/core/servers/servers.dart';
import 'package:boorusama/core/settings/widgets/widgets.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:boorusama/foundation/toast.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'widgets/settings_page_scaffold.dart';

final serverPortProvider = StateProvider<int?>((ref) => null);

enum TransferMode {
  import,
  export,
}

class SyncDataPage extends ConsumerStatefulWidget {
  const SyncDataPage({
    super.key,
    required this.mode,
  });

  final TransferMode mode;

  @override
  ConsumerState<SyncDataPage> createState() => _SyncDataPageState();
}

class _SyncDataPageState extends ConsumerState<SyncDataPage> {
  @override
  Widget build(BuildContext context) {
    return widget.mode == TransferMode.export
        ? const ExportDataPage()
        : const ImportDataPage();
  }
}

void goToSyncDataPage(
  BuildContext context, {
  required TransferMode mode,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => SyncDataPage(
        mode: mode,
      ),
    ),
  );
}

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
      title: const Text('Transfer data'),
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
                        icon:
                            Icon(isRunning ? Symbols.stop : Symbols.play_arrow),
                        label: Text(isRunning
                            ? 'Stop data transter server'
                            : 'Start data transfer server'),
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
                        children: [
                          Text(
                            'Server running at:\n$serverUrl',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'You can connect to this server from another device to start transferring data.',
                            style: const TextStyle(fontSize: 16),
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

class ImportDataPage extends ConsumerStatefulWidget {
  const ImportDataPage({super.key});

  @override
  ConsumerState<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends ConsumerState<ImportDataPage> {
  List<BonsoirService> discoveredServices = [];
  late final _client = AppClient(
    onServiceResolved: _handleServiceResolved,
    onServiceLost: _handleServiceLost,
  );

  void _handleServiceResolved(BonsoirService service) {
    if (!mounted) return;
    setState(() {
      if (!discoveredServices.any((element) => element.name == service.name)) {
        discoveredServices.add(service);
      }
    });
  }

  void _handleServiceLost(BonsoirService service) {
    if (!mounted) return;
    setState(() {
      discoveredServices.removeWhere((element) => element.name == service.name);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _client.dispose();
  }

  Future<void> discoverServers() async {
    _client.startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPageScaffold(
      title: const Text('Import Data'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: discoverServers,
          icon: const Icon(Icons.search),
          label: const Text('Find other devices'),
        ),
        const SizedBox(height: 16),
        if (discoveredServices.isNotEmpty)
          Column(
            children: discoveredServices.map((service) {
              final address = service.attributes['ip'];
              final port = service.attributes['port'];
              final url = Uri(
                scheme: 'http',
                host: address,
                port: int.tryParse(port ?? ''),
              );

              return ListTile(
                title: Text(service.name),
                subtitle: Text(url.toString()),
                trailing: TextButton(
                  child: const Text('Import'),
                  onPressed: () async {
                    showTransferOptionsDialog(context).then((options) async {
                      if (options != null) {
                        for (final option in options) {
                          switch (option) {
                            case 'Booru profiles':
                              _client.stopDiscovery();
                              final dio = Dio(
                                BaseOptions(
                                  baseUrl: url.toString(),
                                ),
                              );

                              try {
                                final res = await dio.get('/configs');

                                final jsonString = res.data;

                                await ref
                                    .read(booruConfigProvider.notifier)
                                    .importFromRawString(
                                      jsonString: jsonString,
                                      onSuccess: _onImportSuccess,
                                      onWillImport:
                                          _showImportBooruConfigsAlertDialog,
                                      onFailure: (message) =>
                                          showErrorToast(context, message),
                                    );
                              } catch (e) {
                                if (context.mounted) {
                                  showErrorToast(context, e.toString());
                                }
                              }
                              break;
                            case 'Favorite tags':
                              final dio = Dio(
                                BaseOptions(
                                  baseUrl: url.toString(),
                                ),
                              );

                              try {
                                final res = await dio.get('/favorite_tags');

                                final tagString = res.data;

                                await ref
                                    .read(favoriteTagsProvider.notifier)
                                    .importWithLabelsFromRawString(
                                      context: context,
                                      text: tagString,
                                    );
                              } catch (e) {
                                if (context.mounted) {
                                  showErrorToast(context, e.toString());
                                }
                              }

                              break;
                            // case 'Bookmarks':
                            //   final dio = Dio(
                            //     BaseOptions(
                            //       baseUrl: url.toString(),
                            //     ),
                            //   );

                            //   try {
                            //     final res = await dio.get('/bookmarks');

                            //     final jsonString = res.data;

                            //     await ref
                            //         .read(bookmarksProvider.notifier)
                            //         .importFromRawString(
                            //           jsonString: jsonString,
                            //           onSuccess: _onImportSuccess,
                            //           onFailure: (message) =>
                            //               showErrorToast(context, message),
                            //         );
                            //   } catch (e) {
                            //     if (context.mounted) {
                            //       showErrorToast(context, e.toString());
                            //     }
                            //   }
                            //   break;
                            // case 'Blacklisted tags':
                            //   final dio = Dio(
                            //     BaseOptions(
                            //       baseUrl: url.toString(),
                            //     ),
                            //   );

                            //   try {
                            //     final res = await dio.get('/blacklisted_tags');

                            //     final tagString = res.data;

                            //     ref
                            //         .read(
                            //             globalBlacklistedTagsProvider.notifier)
                            //         .addTagStringWithToast(context, tagString);
                            //   } catch (e) {
                            //     if (context.mounted) {
                            //       showErrorToast(context, e.toString());
                            //     }
                            //   }

                            //   break;
                            // case 'Settings':
                            //   _importSettings(url);
                            //   break;
                          }
                        }
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Future<bool> _showImportBooruConfigsAlertDialog(
    BooruConfigExportData data,
  ) async {
    final result = await showDialog<bool?>(
      context: context,
      builder: (context) => ImportBooruConfigsAlertDialog(data: data),
    );

    return result ?? false;
  }

  void _onImportSuccess(String message, List<BooruConfig> configs) {
    final config = configs.first;
    Reboot.start(context, config, configs);
  }
}

class TransferOptionsDialog extends StatefulWidget {
  const TransferOptionsDialog({
    super.key,
  });

  @override
  State<TransferOptionsDialog> createState() => _TransferOptionsDialogState();
}

class _TransferOptionsDialogState extends State<TransferOptionsDialog> {
  final Map<String, bool> options = {
    'Favorite tags': true,
    'Booru profiles': true,
    // 'Bookmarks': true,
    // 'Blacklisted tags': true,
    // 'Settings': true,
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 650),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Choose data to transfer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            ...options.entries.map(
              (e) => CheckboxListTile(
                title: Text(e.key),
                value: e.value,
                onChanged: (bool? value) {
                  if (value != null) {
                    setState(() {
                      options[e.key] = value;
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(
                  options.entries
                      .where((e) => e.value)
                      .map((e) => e.key)
                      .toList(),
                );
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Transfer',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// Usage example:
Future<List<String>?> showTransferOptionsDialog(BuildContext context) async {
  return showDialog<List<String>>(
    context: context,
    builder: (context) => const TransferOptionsDialog(),
  );
}
