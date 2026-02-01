// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../settings/providers.dart';
import '../../../themes/theme/types.dart';
import '../../servers/discovery_client.dart';
import '../../sync/client/sync_client_notifier.dart';
import '../../sync/client/sync_service.dart';
import '../../sync/client/types.dart';
import '../../types.dart';
import 'widgets/instruction_step.dart';

class SyncClientPage extends ConsumerStatefulWidget {
  const SyncClientPage({
    super.key,
    this.initialHub,
  });

  final DiscoveredService? initialHub;

  @override
  ConsumerState<SyncClientPage> createState() => _SyncClientPageState();
}

class _SyncClientPageState extends ConsumerState<SyncClientPage> {
  final _addressController = TextEditingController();
  final List<DiscoveredService> _discoveredHubs = [];
  late final DiscoveryClient _discoveryClient;
  String? _activeAddress;

  @override
  void initState() {
    super.initState();

    _discoveryClient = DiscoveryClient(
      onServiceResolved: _handleServiceResolved,
      onServiceLost: _handleServiceLost,
      onError: (_) {},
    );

    _startDiscovery();

    final initialHub = widget.initialHub;
    if (initialHub != null) {
      final address = normalizeHubAddress(initialHub.url);
      _addressController.text = address;
      _activeAddress = address;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(syncClientProvider(address).notifier).stageToHub();
      });
    } else {
      final savedAddress = ref.read(settingsProvider).savedSyncHubAddress;
      if (savedAddress != null) {
        _addressController.text = savedAddress;
      }
    }
  }

  void _handleServiceResolved(DiscoveredService service) {
    if (!mounted) return;
    if (service.attributes['server'] != 'boorusama-hub') return;

    setState(() {
      if (!_discoveredHubs.any((h) => h.name == service.name)) {
        _discoveredHubs.add(service);
      }
    });
  }

  void _handleServiceLost(DiscoveredService service) {
    if (!mounted) return;
    setState(() {
      _discoveredHubs.removeWhere((h) => h.name == service.name);
    });
  }

  Future<void> _startDiscovery() async {
    await _discoveryClient.startDiscovery();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _discoveryClient.stopDiscovery();
    super.dispose();
  }

  void _connectToHub(String address) {
    final normalized = normalizeHubAddress(address);
    setState(() => _activeAddress = normalized);
    ref.read(syncClientProvider(normalized).notifier).stageToHub();
  }

  @override
  Widget build(BuildContext context) {
    final address = _activeAddress;
    final state = address != null
        ? ref.watch(syncClientProvider(address))
        : const SyncClientState(status: SyncClientStatus.idle);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Client'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _AddressInput(
                controller: _addressController,
                state: state,
                onConnect: _connectToHub,
                onClear: () {
                  _addressController.clear();
                  setState(() => _activeAddress = null);
                },
              ),
              const SizedBox(height: 16),
              _DiscoveredHubs(
                hubs: _discoveredHubs,
                state: state,
                onHubSelected: (hub) {
                  _addressController.text = hub.url;
                  _connectToHub(hub.url);
                },
              ),
              const SizedBox(height: 16),
              _StatusSection(
                state: state,
                onReset: address != null
                    ? () =>
                          ref.read(syncClientProvider(address).notifier).reset()
                    : null,
                onRetry: address != null
                    ? () => ref
                          .read(syncClientProvider(address).notifier)
                          .retryConnection()
                    : null,
              ),
              const SizedBox(height: 24),
              const _ClientInstructions(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddressInput extends StatelessWidget {
  const _AddressInput({
    required this.controller,
    required this.state,
    required this.onConnect,
    required this.onClear,
  });

  final TextEditingController controller;
  final SyncClientState state;
  final void Function(String address) onConnect;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLoading =
        state.status == SyncClientStatus.connecting ||
        state.status == SyncClientStatus.staging ||
        state.status == SyncClientStatus.pulling;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hub Address',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'e.g., 192.168.1.100:8765',
              border: const OutlineInputBorder(),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Symbols.close),
                      onPressed: onClear,
                    )
                  : null,
            ),
            enabled:
                !isLoading &&
                state.status != SyncClientStatus.waitingForConfirmation,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  isLoading ||
                      state.status == SyncClientStatus.waitingForConfirmation
                  ? null
                  : () {
                      final address = controller.text.trim();
                      if (address.isNotEmpty) {
                        onConnect(address);
                      }
                    },
              icon: isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : const Icon(Symbols.upload),
              label: Text(_getButtonText(state.status)),
            ),
          ),
        ],
      ),
    );
  }

  String _getButtonText(SyncClientStatus status) {
    return switch (status) {
      SyncClientStatus.connecting => 'Connecting...',
      SyncClientStatus.staging => 'Staging...',
      SyncClientStatus.pulling => 'Pulling...',
      SyncClientStatus.waitingForConfirmation => 'Waiting...',
      _ => 'Stage Data',
    };
  }
}

class _DiscoveredHubs extends StatelessWidget {
  const _DiscoveredHubs({
    required this.hubs,
    required this.state,
    required this.onHubSelected,
  });

  final List<DiscoveredService> hubs;
  final SyncClientState state;
  final void Function(DiscoveredService hub) onHubSelected;

  @override
  Widget build(BuildContext context) {
    if (hubs.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

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
              Icon(Symbols.wifi_find, size: 20, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Discovered Hubs',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...hubs.map(
            (hub) => _HubTile(hub: hub, onTap: () => onHubSelected(hub)),
          ),
        ],
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.hub,
    required this.onTap,
  });

  final DiscoveredService hub;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
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
              Icon(Symbols.chevron_right, color: colorScheme.hintColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  const _StatusSection({
    required this.state,
    required this.onReset,
    required this.onRetry,
  });

  final SyncClientState state;
  final VoidCallback? onReset;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (icon, color, text, subtitle) = switch (state.status) {
      SyncClientStatus.idle => (
        Symbols.circle,
        colorScheme.outline,
        'Ready to sync',
        'Enter the hub address and tap "Stage Data"',
      ),
      SyncClientStatus.connecting => (
        Symbols.wifi,
        colorScheme.primary,
        'Connecting...',
        'Establishing connection to hub',
      ),
      SyncClientStatus.staging => (
        Symbols.upload,
        colorScheme.primary,
        'Staging data...',
        'Sending your data to the hub',
      ),
      SyncClientStatus.waitingForConfirmation => (
        Symbols.hourglass_empty,
        Colors.orange,
        'Waiting for confirmation',
        'The hub owner needs to review and confirm the sync',
      ),
      SyncClientStatus.pulling => (
        Symbols.download,
        colorScheme.primary,
        'Pulling data...',
        'Downloading merged data from hub',
      ),
      SyncClientStatus.completed => (
        Symbols.check_circle,
        Colors.green,
        'Sync completed',
        'Your data has been synchronized',
      ),
      SyncClientStatus.error => (
        Symbols.error,
        colorScheme.error,
        'Sync failed',
        state.errorMessage ?? 'An error occurred',
      ),
      SyncClientStatus.hubUnreachable => (
        Symbols.wifi_off,
        colorScheme.error,
        'Hub unreachable',
        state.errorMessage ?? 'Cannot connect to hub',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              if ((state.status == SyncClientStatus.error ||
                      state.status == SyncClientStatus.completed) &&
                  onReset != null)
                TextButton(
                  onPressed: onReset,
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.hintColor,
              ),
            ),
          ),
          if (state.status == SyncClientStatus.waitingForConfirmation &&
              onReset != null)
            _WaitingActions(onReset: onReset!),
          if (state.status == SyncClientStatus.hubUnreachable &&
              onReset != null &&
              onRetry != null)
            _UnreachableActions(onReset: onReset!, onRetry: onRetry!),
        ],
      ),
    );
  }
}

class _WaitingActions extends StatelessWidget {
  const _WaitingActions({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onReset,
            icon: const Icon(Symbols.close, size: 18),
            label: const Text('Cancel'),
          ),
        ),
      ],
    );
  }
}

class _UnreachableActions extends StatelessWidget {
  const _UnreachableActions({
    required this.onReset,
    required this.onRetry,
  });

  final VoidCallback onReset;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'The hub may have stopped or the network connection was lost. '
          'You can wait for it to come back online, or reset and try again.',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.hintColor,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  onRetry();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Retrying connection...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Symbols.refresh, size: 18),
                label: const Text('Retry'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: onReset,
                icon: const Icon(Symbols.restart_alt, size: 18),
                label: const Text('Reset'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClientInstructions extends StatelessWidget {
  const _ClientInstructions();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How to sync:',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const InstructionStep(
            number: '1',
            text: 'Start the Sync Hub on another device',
          ),
          const InstructionStep(
            number: '2',
            text: 'Enter the hub address and tap "Stage Data"',
          ),
          const InstructionStep(
            number: '3',
            text: 'Wait for the hub to review and confirm',
          ),
          const InstructionStep(
            number: '4',
            text: 'Merged data will be pulled automatically',
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Symbols.info, color: colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Your data is staged first. The hub owner reviews conflicts before any merge happens.',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
