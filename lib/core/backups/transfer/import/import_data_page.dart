// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:bonsoir/bonsoir.dart';
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/info/package_info.dart';
import '../../../../foundation/permissions.dart';
import '../../../../foundation/toast.dart';
import '../../../../foundation/version.dart';
import '../../../themes/theme/types.dart';
import '../../preparation/version_mismatch_alert_dialog.dart';
import '../../servers/discovery_client.dart';
import '../widgets/permission_required_view.dart';
import 'manual_device_input_dialog.dart';
import 'transfer_data_dialog.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final permissionState = ref.read(localNetworkPermissionProvider);
      if (permissionState.value?.isGranted ?? false) {
        discoverServers();
      }
    });
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
    final colorScheme = Theme.of(context).colorScheme;
    final currentVersion = ref.watch(appVersionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.t.settings.backup_and_restore.receive_data.title),
      ),
      body: ref
          .watch(localNetworkPermissionProvider)
          .when(
            data: (permission) => switch (permission.status) {
              PermissionStatus.granted => _buildBody(
                colorScheme,
                currentVersion,
              ),
              _ => PermissionRequiredView(
                onPermissionGranted: () {
                  final permissionState = ref.read(
                    localNetworkPermissionProvider,
                  );
                  if (permissionState.value?.isGranted ?? false) {
                    discoverServers();
                  }
                },
              ),
            },
            error: (error, _) => Center(child: Text('Error: $error')),
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
          ),
    );
  }

  Widget _buildBody(ColorScheme colorScheme, Version? currentVersion) {
    return Padding(
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
                  if (!mounted) return;
                  final uri = await showGeneralDialog<Uri>(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const ManualDeviceInputDialog(),
                  );

                  if (uri == null) return;

                  if (mounted) {
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
                final appVersion = Version.tryParse(
                  service.attributes['version'],
                );
                final url = Uri(
                  scheme: 'http',
                  host: address,
                  port: int.tryParse(port ?? ''),
                );

                return _ServiceTile(
                  appVersion: appVersion,
                  url: url,
                  currentVersion: currentVersion,
                  service: service,
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
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  const _ServiceTile({
    required this.appVersion,
    required this.currentVersion,
    required this.url,
    required this.service,
  });

  final Version? appVersion;
  final Version? currentVersion;
  final BonsoirService service;
  final Uri url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

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
                "Couldn't determine this device's version, aborting.".hc,
              );
              return;
            }

            if (currentVersion == null) {
              showErrorToast(
                context,
                "Couldn't determine the current version, aborting.".hc,
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
              if (!context.mounted) return;
              final result = await showDialog(
                context: context,
                builder: (context) => VersionMismatchAlertDialog(
                  importVersion: version,
                  currentVersion: currentVersion!,
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
  }
}
