// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../themes/theme/types.dart';
import '../../../sync/hub/types.dart';

class ConflictItemTile extends StatelessWidget {
  const ConflictItemTile({
    super.key,
    required this.conflict,
    required this.index,
    required this.onResolve,
  });

  final ConflictItem conflict;
  final int index;
  final void Function(int index, ConflictResolution resolution) onResolve;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final (statusColor, statusText) = switch (conflict.resolution) {
      ConflictResolution.pending => (colorScheme.error, 'Unresolved'),
      ConflictResolution.keepLocal => (Colors.blue, 'Keeping Local'),
      ConflictResolution.keepRemote => (Colors.orange, 'Keeping Remote'),
    };

    final itemName =
        _getItemDisplayName(conflict.localData) ?? conflict.uniqueId.toString();

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
            ...differences
                .take(3)
                .map(
                  (diff) => _DifferenceRow(difference: diff),
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
                    onPressed: () =>
                        onResolve(index, ConflictResolution.keepLocal),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.blue.withValues(alpha: 0.2),
                    ),
                    child: const Text('Keep Local'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () =>
                        onResolve(index, ConflictResolution.keepRemote),
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
    return data['name'] as String? ??
        data['title'] as String? ??
        data['displayName'] as String? ??
        data['tag'] as String? ??
        data['url'] as String?;
  }

  List<FieldDifference> _findDifferences(
    Map<String, dynamic> local,
    Map<String, dynamic> remote,
  ) {
    final differences = <FieldDifference>[];
    final allKeys = {...local.keys, ...remote.keys};

    for (final key in allKeys) {
      if (key == 'id' || key == 'createdAt' || key == 'createdDate') continue;

      final localVal = local[key];
      final remoteVal = remote[key];

      if (localVal != remoteVal) {
        differences.add(
          FieldDifference(
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
}

class FieldDifference {
  const FieldDifference({
    required this.field,
    required this.localValue,
    required this.remoteValue,
  });

  final String field;
  final dynamic localValue;
  final dynamic remoteValue;
}

class _DifferenceRow extends StatelessWidget {
  const _DifferenceRow({required this.difference});

  final FieldDifference difference;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            difference.field,
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
                child: _ValueBox(
                  label: 'Local',
                  value: difference.localValue,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueBox(
                  label: 'Remote',
                  value: difference.remoteValue,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final dynamic value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatValue(value),
            style: const TextStyle(fontSize: 12),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value == null) return '(empty)';
    if (value is String && value.isEmpty) return '(empty)';
    if (value is List) return '${value.length} items';
    if (value is Map) return '${value.length} fields';
    return value.toString();
  }
}

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();
  }
}
