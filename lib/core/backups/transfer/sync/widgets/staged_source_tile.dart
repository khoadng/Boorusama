// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../themes/theme/types.dart';
import '../../../sync/hub/types.dart';

class StagedSourceTile extends StatefulWidget {
  const StagedSourceTile({
    super.key,
    required this.sourceId,
    required this.stagedList,
    required this.clients,
  });

  final String sourceId;
  final List<StagedSourceData> stagedList;
  final List<ConnectedClient> clients;

  @override
  State<StagedSourceTile> createState() => _StagedSourceTileState();
}

class _StagedSourceTileState extends State<StagedSourceTile> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
    final name =
        item['name'] as String? ??
        item['title'] as String? ??
        item['displayName'] as String? ??
        item['tag'] as String?;

    if (name != null) return name;

    final url = item['url'] as String?;
    if (url != null) {
      final uri = Uri.tryParse(url);
      if (uri != null) {
        return uri.pathSegments.lastOrNull ?? url;
      }
      return url;
    }

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
