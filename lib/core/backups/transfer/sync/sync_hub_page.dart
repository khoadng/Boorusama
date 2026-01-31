// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../../themes/theme/types.dart';
import '../../sync/hub/hub_server_provider.dart';
import '../../sync/hub/types.dart';
import '../export/export_data_page.dart';
import 'widgets/conflict_item_tile.dart';
import 'widgets/instruction_step.dart';
import 'widgets/staged_source_tile.dart';

class SyncHubPage extends ConsumerStatefulWidget {
  const SyncHubPage({super.key});

  @override
  ConsumerState<SyncHubPage> createState() => _SyncHubPageState();
}

class _SyncHubPageState extends ConsumerState<SyncHubPage> {
  final _portController = TextEditingController();

  @override
  void dispose() {
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(syncHubProvider);
    final notifier = ref.watch(syncHubProvider.notifier);
    final connectedToWifi = ref.watch(connectedToWifiProvider);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && state.isRunning) {
          notifier.stopHub();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sync Hub'),
          actions: [
            if (state.isRunning)
              IconButton(
                icon: const Icon(Symbols.stop),
                onPressed: () => notifier.stopHub(),
                tooltip: 'Stop Hub',
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: connectedToWifi
              ? _HubBody(
                  state: state,
                  notifier: notifier,
                  portController: _portController,
                )
              : _buildNoWifi(context),
        ),
      ),
    );
  }

  Widget _buildNoWifi(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
        child: Text(
          'Please connect to a WiFi network to use Sync Hub.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.hintColor,
          ),
        ),
      ),
    );
  }
}

class _HubBody extends StatelessWidget {
  const _HubBody({
    required this.state,
    required this.notifier,
    required this.portController,
  });

  final SyncHubState state;
  final SyncHubNotifier notifier;
  final TextEditingController portController;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!state.isRunning) ...[
            _PortConfig(controller: portController),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _startHub(),
                icon: const Icon(Symbols.play_arrow),
                label: const Text('Start Hub'),
              ),
            ),
            const SizedBox(height: 24),
            const _HubInstructions(),
          ] else ...[
            _ServerInfo(serverUrl: state.serverUrl),
            const SizedBox(height: 16),
            _PhaseIndicator(phase: state.phase),
            const SizedBox(height: 16),
            _ConnectedClients(clients: state.connectedClients),
            const SizedBox(height: 16),
            _StagedData(state: state),
            if (state.phase == SyncHubPhase.reviewing ||
                state.phase == SyncHubPhase.resolved) ...[
              const SizedBox(height: 16),
              _ConflictsSection(state: state, notifier: notifier),
            ],
            const SizedBox(height: 16),
            _HubActions(state: state, notifier: notifier),
          ],
        ],
      ),
    );
  }

  void _startHub() {
    final portText = portController.text.trim();
    final port = portText.isNotEmpty ? int.tryParse(portText) : null;
    notifier.startHub(config: SyncHubConfig(port: port));
  }
}

class _PortConfig extends StatelessWidget {
  const _PortConfig({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
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
          Text(
            'Configuration',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Port (optional)',
              hintText: 'Leave empty for random port',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

class _ServerInfo extends StatelessWidget {
  const _ServerInfo({required this.serverUrl});

  final String? serverUrl;

  @override
  Widget build(BuildContext context) {
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
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Hub Running',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ServerInfoTile(
            title: 'Address',
            value: serverUrl ?? 'Unknown',
          ),
        ],
      ),
    );
  }
}

class _PhaseIndicator extends StatelessWidget {
  const _PhaseIndicator({required this.phase});

  final SyncHubPhase phase;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (color, icon, text) = switch (phase) {
      SyncHubPhase.waiting => (
        colorScheme.outline,
        Symbols.hourglass_empty,
        'Waiting for clients to stage data',
      ),
      SyncHubPhase.reviewing => (
        colorScheme.primary,
        Symbols.compare,
        'Reviewing conflicts',
      ),
      SyncHubPhase.resolved => (
        Colors.orange,
        Symbols.check,
        'All conflicts resolved, ready to confirm',
      ),
      SyncHubPhase.confirmed => (
        Colors.green,
        Symbols.check_circle,
        'Sync confirmed! Clients can pull data',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
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
        ],
      ),
    );
  }
}

class _ConnectedClients extends StatelessWidget {
  const _ConnectedClients({required this.clients});

  final List<ConnectedClient> clients;

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Connected Devices',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${clients.length}',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (clients.isEmpty)
            Text(
              'No devices connected yet',
              style: TextStyle(color: colorScheme.hintColor),
            )
          else
            ...clients.map((client) => _ClientRow(client: client)),
        ],
      ),
    );
  }
}

class _ClientRow extends StatelessWidget {
  const _ClientRow({required this.client});

  final ConnectedClient client;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            Symbols.smartphone,
            size: 20,
            color: client.hasStaged ? Colors.green : colorScheme.onSurface,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.deviceName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  client.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (client.hasStaged)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Staged',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StagedData extends StatelessWidget {
  const _StagedData({required this.state});

  final SyncHubState state;

  @override
  Widget build(BuildContext context) {
    if (state.stagedData.isEmpty) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;

    var totalItems = 0;
    for (final entry in state.stagedData.entries) {
      for (final staged in entry.value) {
        totalItems += staged.data.length;
      }
    }

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Staged Data',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalItems items',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...state.stagedData.entries.map(
            (entry) => StagedSourceTile(
              sourceId: entry.key,
              stagedList: entry.value,
              clients: state.connectedClients,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConflictsSection extends StatelessWidget {
  const _ConflictsSection({
    required this.state,
    required this.notifier,
  });

  final SyncHubState state;
  final SyncHubNotifier notifier;

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Conflicts',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (state.conflicts.isNotEmpty)
                TextButton(
                  onPressed: () => _showResolveAllDialog(context),
                  child: const Text('Resolve All'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.conflicts.isEmpty)
            Row(
              children: [
                const Icon(Symbols.check_circle, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'No conflicts detected',
                  style: TextStyle(color: colorScheme.hintColor),
                ),
              ],
            )
          else
            ...state.conflicts.asMap().entries.map(
              (entry) => ConflictItemTile(
                conflict: entry.value,
                index: entry.key,
                onResolve: notifier.resolveConflict,
              ),
            ),
        ],
      ),
    );
  }

  void _showResolveAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve All Conflicts'),
        content: const Text('Choose how to resolve all conflicts:'),
        actions: [
          TextButton(
            onPressed: () {
              notifier.resolveAllConflicts(ConflictResolution.keepLocal);
              Navigator.of(context).pop();
            },
            child: const Text('Keep All Local'),
          ),
          TextButton(
            onPressed: () {
              notifier.resolveAllConflicts(ConflictResolution.keepRemote);
              Navigator.of(context).pop();
            },
            child: const Text('Keep All Remote'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _HubActions extends StatelessWidget {
  const _HubActions({
    required this.state,
    required this.notifier,
  });

  final SyncHubState state;
  final SyncHubNotifier notifier;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        switch (state.phase) {
          SyncHubPhase.waiting => SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.stagedData.isNotEmpty
                  ? () => notifier.startReview()
                  : null,
              icon: const Icon(Symbols.compare),
              label: const Text('Start Review'),
            ),
          ),
          SyncHubPhase.reviewing || SyncHubPhase.resolved => SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.canConfirm || !state.hasUnresolvedConflicts
                  ? () => notifier.confirmSync()
                  : null,
              icon: const Icon(Symbols.check),
              label: const Text('Confirm Sync'),
            ),
          ),
          SyncHubPhase.confirmed => SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => notifier.resetSync(),
              icon: const Icon(Symbols.refresh),
              label: const Text('Reset for New Sync'),
            ),
          ),
        },
        const SizedBox(height: 8),
      ],
    );
  }
}

class _HubInstructions extends StatelessWidget {
  const _HubInstructions();

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
            'How it works:',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const InstructionStep(
            number: '1',
            text: 'Start the hub on this device',
          ),
          const InstructionStep(
            number: '2',
            text: 'Other devices connect and stage their data',
          ),
          const InstructionStep(
            number: '3',
            text: 'Review and resolve any conflicts',
          ),
          const InstructionStep(
            number: '4',
            text: 'Confirm sync, then all devices pull the merged data',
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
                    'Data is staged first, reviewed for conflicts, then merged only after your confirmation.',
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
