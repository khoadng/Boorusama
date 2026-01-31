// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../foundation/networking.dart';
import '../../../themes/theme/types.dart';
import '../../sync/hub_server_provider.dart';
import '../../sync/types.dart';
import '../export/export_data_page.dart';

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
              ? _buildBody(context, state, notifier)
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

  Widget _buildBody(
    BuildContext context,
    SyncHubState state,
    SyncHubNotifier notifier,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!state.isRunning) ...[
            _buildPortConfig(context),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _startHub(notifier),
                icon: const Icon(Symbols.play_arrow),
                label: const Text('Start Hub'),
              ),
            ),
            const SizedBox(height: 24),
            _buildInstructions(context),
          ] else ...[
            _buildServerInfo(context, state),
            const SizedBox(height: 16),
            _buildPhaseIndicator(context, state),
            const SizedBox(height: 16),
            _buildConnectedClients(context, state),
            const SizedBox(height: 16),
            _buildStagedData(context, state),
            if (state.phase == SyncHubPhase.reviewing ||
                state.phase == SyncHubPhase.resolved) ...[
              const SizedBox(height: 16),
              _buildConflicts(context, state, notifier),
            ],
            const SizedBox(height: 16),
            _buildActions(context, state, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildPortConfig(BuildContext context) {
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
            controller: _portController,
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

  Widget _buildServerInfo(BuildContext context, SyncHubState state) {
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
            value: state.serverUrl ?? 'Unknown',
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(BuildContext context, SyncHubState state) {
    final colorScheme = Theme.of(context).colorScheme;

    final (color, icon, text) = switch (state.phase) {
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

  Widget _buildConnectedClients(BuildContext context, SyncHubState state) {
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
                  '${state.connectedClients.length}',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (state.connectedClients.isEmpty)
            Text(
              'No devices connected yet',
              style: TextStyle(color: colorScheme.hintColor),
            )
          else
            ...state.connectedClients.map(
              (client) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Symbols.smartphone,
                      size: 20,
                      color: client.hasStaged
                          ? Colors.green
                          : colorScheme.onSurface,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStagedData(BuildContext context, SyncHubState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.stagedData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate totals
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
            (entry) => _StagedSourceTile(
              sourceId: entry.key,
              stagedList: entry.value,
              clients: state.connectedClients,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflicts(
    BuildContext context,
    SyncHubState state,
    SyncHubNotifier notifier,
  ) {
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
                  onPressed: () => _showResolveAllDialog(context, notifier),
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
              (entry) => _buildConflictItem(
                context,
                entry.value,
                entry.key,
                notifier,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConflictItem(
    BuildContext context,
    ConflictItem conflict,
    int index,
    SyncHubNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    final (statusColor, statusText) = switch (conflict.resolution) {
      ConflictResolution.pending => (colorScheme.error, 'Unresolved'),
      ConflictResolution.keepLocal => (Colors.blue, 'Keeping Local'),
      ConflictResolution.keepRemote => (Colors.orange, 'Keeping Remote'),
    };

    // Get display name for the item
    final itemName =
        _getItemDisplayName(conflict.localData) ?? conflict.uniqueId.toString();

    // Find differing fields
    final differences = _findDifferences(
      conflict.localData,
      conflict.remoteData,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: statusColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(8),
        color: statusColor.withValues(alpha: 0.05),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Symbols.warning, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        itemName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            conflict.sourceId,
            style: TextStyle(fontSize: 12, color: colorScheme.hintColor),
          ),
          if (differences.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Show what's different
            ...differences
                .take(3)
                .map(
                  (diff) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diff.field,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.hintColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Local',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.blue.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatValue(diff.localValue),
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Remote',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.orange.shade700,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatValue(diff.remoteValue),
                                      style: const TextStyle(fontSize: 12),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            if (differences.length > 3)
              Text(
                '+${differences.length - 3} more differences',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.hintColor,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
          if (conflict.resolution == ConflictResolution.pending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => notifier.resolveConflict(
                      index,
                      ConflictResolution.keepLocal,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    ),
                    child: const Text('Keep Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => notifier.resolveConflict(
                      index,
                      ConflictResolution.keepRemote,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange.withValues(alpha: 0.2),
                    ),
                    child: const Text('Keep Remote'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String? _getItemDisplayName(Map<String, dynamic> data) {
    // Try common name fields
    return data['name'] as String? ??
        data['title'] as String? ??
        data['displayName'] as String? ??
        data['tag'] as String? ??
        data['url'] as String?;
  }

  List<_FieldDifference> _findDifferences(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final differences = <_FieldDifference>[];
    final allKeys = {...local.keys, ...remote.keys};

    for (final key in allKeys) {
      // Skip internal/meta fields
      if (key == 'id' || key == 'createdAt' || key == 'createdDate') continue;

      final localVal = local[key];
      final remoteVal = remote[key];

      if (localVal != remoteVal) {
        differences.add(
          _FieldDifference(
            field: _formatFieldName(key),
            localValue: localVal,
            remoteValue: remoteVal,
          ),
        );
      }
    }

    return differences;
  }

  String _formatFieldName(String field) {
    // Convert camelCase to Title Case
    return field
        .replaceAllMapped(
          RegExp('([A-Z])'),
          (match) => ' ${match.group(1)}',
        )
        .trim()
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }

  String _formatValue(dynamic value) {
    if (value == null) return '(empty)';
    if (value is String && value.isEmpty) return '(empty)';
    if (value is List) return '${value.length} items';
    if (value is Map) return '${value.length} fields';
    return value.toString();
  }

  Widget _buildActions(
    BuildContext context,
    SyncHubState state,
    SyncHubNotifier notifier,
  ) {
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

  Widget _buildInstructions(BuildContext context) {
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
          const _InstructionStep(
            number: '1',
            text: 'Start the hub on this device',
          ),
          const _InstructionStep(
            number: '2',
            text: 'Other devices connect and stage their data',
          ),
          const _InstructionStep(
            number: '3',
            text: 'Review and resolve any conflicts',
          ),
          const _InstructionStep(
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

  void _showResolveAllDialog(BuildContext context, SyncHubNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve All Conflicts'),
        content: const Text(
          'Choose how to resolve all conflicts:',
        ),
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

  void _startHub(SyncHubNotifier notifier) {
    final portText = _portController.text.trim();
    final port = portText.isNotEmpty ? int.tryParse(portText) : null;

    notifier.startHub(
      config: SyncHubConfig(
        port: port,
      ),
    );
  }
}

class _InstructionStep extends StatelessWidget {
  const _InstructionStep({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }
}

class _StagedSourceTile extends StatefulWidget {
  const _StagedSourceTile({
    required this.sourceId,
    required this.stagedList,
    required this.clients,
  });

  final String sourceId;
  final List<StagedSourceData> stagedList;
  final List<ConnectedClient> clients;

  @override
  State<_StagedSourceTile> createState() => _StagedSourceTileState();
}

class _StagedSourceTileState extends State<_StagedSourceTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Calculate total items for this source
    final totalItems = widget.stagedList.fold<int>(
      0,
      (sum, staged) => sum + staged.data.length,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _getSourceIcon(widget.sourceId),
                    size: 20,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatSourceName(widget.sourceId),
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '$totalItems items from ${widget.stagedList.length} device(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.hintColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Symbols.expand_less : Symbols.expand_more,
                    color: colorScheme.hintColor,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: widget.stagedList.map((staged) {
                  // Find device name
                  final client = widget.clients
                      .where((c) => c.id == staged.clientId)
                      .firstOrNull;
                  final deviceName = staged.clientId == '_hub_self_'
                      ? 'This Device (Hub)'
                      : client?.deviceName ?? staged.clientId;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          staged.clientId == '_hub_self_'
                              ? Symbols.home
                              : Symbols.smartphone,
                          size: 16,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            deviceName,
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${staged.data.length}',
                            style: TextStyle(
                              fontSize: 12,
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            // Show preview of first few items
            if (widget.stagedList.isNotEmpty) ...[
              Divider(height: 1, color: colorScheme.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.hintColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._getPreviewItems()
                        .take(5)
                        .map(
                          (item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Symbols.circle,
                                  size: 6,
                                  color: colorScheme.hintColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getItemPreview(item),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    if (_getTotalItemCount() > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+${_getTotalItemCount() - 5} more',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.hintColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getPreviewItems() {
    final items = <Map<String, dynamic>>[];
    for (final staged in widget.stagedList) {
      items.addAll(staged.data);
    }
    return items;
  }

  int _getTotalItemCount() {
    return widget.stagedList.fold<int>(0, (sum, s) => sum + s.data.length);
  }

  String _getItemPreview(Map<String, dynamic> item) {
    // Try to get a meaningful preview
    final name =
        item['name'] as String? ??
        item['title'] as String? ??
        item['displayName'] as String? ??
        item['tag'] as String?;

    if (name != null) return name;

    final url = item['url'] as String?;
    if (url != null) {
      // Extract just the path/filename from URL
      final uri = Uri.tryParse(url);
      if (uri != null) {
        return uri.pathSegments.lastOrNull ?? url;
      }
      return url;
    }

    // Fallback to ID
    return 'Item ${item['id'] ?? ''}';
  }

  IconData _getSourceIcon(String sourceId) {
    return switch (sourceId) {
      'bookmarks' => Symbols.bookmark,
      'favorite_tags' => Symbols.favorite,
      'blacklisted_tags' => Symbols.block,
      'profiles' => Symbols.settings,
      _ => Symbols.folder,
    };
  }

  String _formatSourceName(String sourceId) {
    return switch (sourceId) {
      'bookmarks' => 'Bookmarks',
      'favorite_tags' => 'Favorite Tags',
      'blacklisted_tags' => 'Blacklisted Tags',
      'profiles' => 'Booru Profiles',
      _ =>
        sourceId
            .split('_')
            .map(
              (word) => word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
            )
            .join(' '),
    };
  }
}

class _FieldDifference {
  const _FieldDifference({
    required this.field,
    required this.localValue,
    required this.remoteValue,
  });

  final String field;
  final dynamic localValue;
  final dynamic remoteValue;
}
