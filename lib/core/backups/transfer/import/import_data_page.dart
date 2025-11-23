// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/info/package_info.dart';
import '../../../../foundation/toast.dart';
import '../../../../foundation/version.dart';
import '../../../themes/theme/types.dart';
import '../../preparation/version_mismatch_alert_dialog.dart';
import '../../servers/discovery_client.dart';
import '../../types.dart';
import 'manual_device_input_dialog.dart';
import 'transfer_data_dialog.dart';

class ImportDataPage extends ConsumerStatefulWidget {
  const ImportDataPage({super.key});

  @override
  ConsumerState<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends ConsumerState<ImportDataPage> {
  List<DiscoveredService> discoveredServices = [];
  late final _client = DiscoveryClient(
    onServiceResolved: _handleServiceResolved,
    onServiceLost: _handleServiceLost,
    onError: (message) {
      if (!mounted) return;
      showErrorToast(context, message);
    },
  );

  @override
  void initState() {
    super.initState();

    discoverServers();
  }

  void _handleServiceResolved(DiscoveredService service) {
    if (!mounted) return;
    setState(() {
      if (!discoveredServices.any((element) => element.name == service.name)) {
        discoveredServices.add(service);
      }
    });
  }

  void _handleServiceLost(DiscoveredService service) {
    if (!mounted) return;
    setState(() {
      discoveredServices.removeWhere((element) => element.name == service.name);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _client.stopDiscovery();
  }

  Future<void> discoverServers() {
    return _client.startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentVersion = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.backup_and_restore.receive_data.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context
                      .t
                      .settings
                      .backup_and_restore
                      .receive_data
                      .nearby_devices,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final uri = await showGeneralDialog<Uri>(
                      context: context,
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const ManualDeviceInputDialog(),
                    );

                    if (uri == null) return;

                    if (context.mounted) {
                      await showTransferOptionsDialog(
                        context,
                        url: uri.toString(),
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (discoveredServices.isNotEmpty)
              Column(
                children: discoveredServices.map((service) {
                  final appVersion = Version.tryParse(
                    service.attributes['version'] ?? '',
                  );
                  final url = Uri(
                    scheme: 'http',
                    host: service.host,
                    port: service.port,
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        service.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        context.t.generic.version(
                          version: appVersion ?? 'unknown',
                        ),
                      ),
                      trailing: TextButton(
                        child: Text(
                          context.t.settings.backup_and_restore.import,
                        ),
                        onPressed: () async {
                          final version = appVersion;

                          if (version == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine this device's version, aborting."
                                  .hc,
                            );
                            return;
                          }

                          if (currentVersion == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine the current version, aborting."
                                  .hc,
                            );
                            return;
                          }

                          final shouldShowDialog =
                              currentVersion.significantlyLowerThan(
                                appVersion,
                              ) ||
                              currentVersion.significantlyHigherThan(
                                appVersion,
                              );

                          if (shouldShowDialog) {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => VersionMismatchAlertDialog(
                                importVersion: version,
                                currentVersion: currentVersion,
                              ),
                            );

                            if (result == null || !result) return;
                          }

                          if (context.mounted) {
                            await showTransferOptionsDialog(
                              context,
                              url: url.toString(),
                            );
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 8,
                  ),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.hintColor,
                    ),
                    context.t.settings.backup_and_restore.receive_data
                        .no_devices_found(
                          tapHere: (_) => const WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.add,
                            ),
                          ),
                        ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
