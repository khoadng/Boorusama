// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:version/version.dart';

// Project imports:
import '../../../foundation/info/package_info.dart';
import '../../../foundation/toast.dart';
import '../../../foundation/version.dart';
import '../../theme/app_theme.dart';
import '../servers/discovery_client.dart';
import 'manual_device_input_dialog.dart';
import 'transfer_data_dialog.dart';
import 'version_mismatch_alert_dialog.dart';

class ImportDataPage extends ConsumerStatefulWidget {
  const ImportDataPage({super.key});

  @override
  ConsumerState<ImportDataPage> createState() => _ImportDataPageState();
}

class _ImportDataPageState extends ConsumerState<ImportDataPage> {
  List<BonsoirService> discoveredServices = [];
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

    _client.stopDiscovery();
  }

  Future<void> discoverServers() {
    return _client.startDiscovery();
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receive data'),
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
                  'Nearby devices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final uri = await showGeneralDialog<Uri>(
                      context: context,
                      transitionDuration: const Duration(milliseconds: 200),
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
                  final address = service.attributes['ip'];
                  final port = service.attributes['port'];
                  final appVersion = service.attributes['version'];
                  final url = Uri(
                    scheme: 'http',
                    host: address,
                    port: int.tryParse(port ?? ''),
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
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
                        'Version $appVersion',
                      ),
                      trailing: TextButton(
                        child: const Text('Import'),
                        onPressed: () async {
                          if (appVersion == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine this device's version, aborting.",
                            );
                            return;
                          }

                          if (currentVersion == null) {
                            showErrorToast(
                              context,
                              "Couldn't determine the current version, aborting.",
                            );
                            return;
                          }

                          final parsedVersion = Version.parse(appVersion);
                          final shouldShowDialog = currentVersion
                                  .significantlyLowerThan(parsedVersion) ||
                              currentVersion
                                  .significantlyHigherThan(parsedVersion);

                          if (shouldShowDialog) {
                            final result = await showDialog(
                              context: context,
                              builder: (context) => VersionMismatchAlertDialog(
                                importVersion: Version.parse(appVersion),
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
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.hintColor,
                          ),
                      children: const [
                        TextSpan(
                          text:
                              'No devices found. Start transfer on the other device first.\n',
                        ),
                        TextSpan(text: '\nTap '),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.add,
                          ),
                        ),
                        TextSpan(text: ' to add manually by IP address.'),
                      ],
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
