// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../../themes/theme/types.dart';
import '../../types.dart';
import 'sync_client_page.dart';
import 'sync_discovery_notifier.dart';
import 'sync_hub_page.dart';

class SyncPage extends ConsumerStatefulWidget {
  const SyncPage({super.key});

  @override
  ConsumerState<SyncPage> createState() => _SyncPageState();
}

class _SyncPageState extends ConsumerState<SyncPage> {
  var _isHub = false;
  DiscoveredService? _selectedHub;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(syncDiscoveryProvider.notifier).startDiscovery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final connectedToWifi = ref.watch(connectedToWifiProvider);

    if (!connectedToWifi) {
      return _buildNoWifi(context);
    }

    if (_isHub) {
      return const SyncHubPage();
    }

    if (_selectedHub != null) {
      return SyncClientPage(initialHub: _selectedHub);
    }

    return _buildDiscoveryContent();
  }

  Widget _buildNoWifi(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Text(
          'Please connect to a WiFi network to use Sync.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.hintColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryContent() {
    final discoveryState = ref.watch(syncDiscoveryProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatusCard(discoveryState, colorScheme),
              const SizedBox(height: 24),
              if (discoveryState.discoveredHubs.isNotEmpty) ...[
                _buildDiscoveredHubs(
                  discoveryState.discoveredHubs,
                  colorScheme,
                ),
                const SizedBox(height: 24),
              ],
              _buildActions(discoveryState, colorScheme),
            ]),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildInstructions(colorScheme),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(
    SyncDiscoveryState discoveryState,
    ColorScheme colorScheme,
  ) {
    final (icon, color, title, subtitle) = switch (discoveryState.status) {
      SyncDiscoveryStatus.idle => (
        Symbols.sync,
        colorScheme.outline,
        'Ready to Sync',
        'Looking for sync sessions on your network...',
      ),
      SyncDiscoveryStatus.discovering => (
        Symbols.wifi_find,
        colorScheme.primary,
        'Searching...',
        'Looking for sync sessions on your network...',
      ),
      SyncDiscoveryStatus.hubFound => (
        Symbols.check_circle,
        Colors.green,
        'Session Found',
        'Tap a session below to join, or start your own.',
      ),
      SyncDiscoveryStatus.noHubFound => (
        Symbols.sync_disabled,
        colorScheme.outline,
        'No Session Found',
        'Start a new session to sync with other devices.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          if (discoveryState.status == SyncDiscoveryStatus.discovering)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            )
          else
            Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.hintColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveredHubs(
    List<DiscoveredService> hubs,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Symbols.devices, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Available Sessions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...hubs.map((hub) => _buildHubTile(hub, colorScheme)),
        ],
      ),
    );
  }

  Widget _buildHubTile(DiscoveredService hub, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => _joinHub(hub),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Symbols.computer, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hub.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${hub.host}:${hub.port}',
                      style: TextStyle(
                        color: colorScheme.hintColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: () => _joinHub(hub),
                child: const Text('Join'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(
    SyncDiscoveryState discoveryState,
    ColorScheme colorScheme,
  ) {
    final isDiscovering =
        discoveryState.status == SyncDiscoveryStatus.discovering;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: isDiscovering ? null : () => _startSession(),
          icon: const Icon(Symbols.add),
          label: const Text('Start New Session'),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: isDiscovering
              ? null
              : () {
                  ref.read(syncDiscoveryProvider.notifier).startDiscovery();
                },
          icon: const Icon(Symbols.refresh),
          label: const Text('Scan Again'),
        ),
      ],
    );
  }

  Widget _buildInstructions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Symbols.info, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Open Sync on all devices you want to sync. '
              'One device starts a session, others join automatically.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _startSession() {
    setState(() => _isHub = true);
  }

  void _joinHub(DiscoveredService hub) {
    setState(() => _selectedHub = hub);
  }
}
