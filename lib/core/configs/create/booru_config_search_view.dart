// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';

class BooruConfigSearchView extends ConsumerWidget {
  const BooruConfigSearchView({
    super.key,
    required this.hasRatingFilter,
    required this.config,
  });

  final bool hasRatingFilter;
  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alwaysIncludeTags = ref.watch(alwaysIncludeTagsProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasRatingFilter) ...[
            const SizedBox(height: 12),
            const DefaultBooruRatingOptionsTile(),
            const Divider(),
          ],
          const SizedBox(height: 12),
          Text(
            'Include these tags in every search',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final rawTags = queryAsList(alwaysIncludeTags);
              // filter out tags negated with a minus sign
              final tags = rawTags.where((e) => !e.startsWith('-')).toList();
              return _buildTagList(ref, tags);
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Exclude these tags in every search',
            style: TextStyle(
              color: context.theme.colorScheme.onSurface.withOpacity(0.8),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final rawTags = queryAsList(alwaysIncludeTags);
              // filter out tags negated with a minus sign
              final tags = rawTags.where((e) => e.startsWith('-')).toList();
              return _buildTagList(ref, tags, exclude: true);
            },
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _EffectiveTagPreview()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagList(
    WidgetRef ref,
    List<String> tags, {
    bool exclude = false,
  }) {
    final context = ref.context;

    return Wrap(
      runAlignment: WrapAlignment.center,
      spacing: 5,
      children: [
        ...tags.map(
          (e) => Chip(
            backgroundColor: context.theme.colorScheme.surfaceContainerHighest,
            label: exclude
                ? Text(e.substring(1).replaceAll('_', ' '))
                : Text(e.replaceAll('_', ' ')),
            deleteIcon: Icon(
              Symbols.close,
              size: 16,
              color: context.theme.colorScheme.error,
            ),
            onDeleted: () => _removeTag(ref, e),
          ),
        ),
        IconButton(
          iconSize: 28,
          splashRadius: 20,
          onPressed: () {
            goToQuickSearchPage(
              context,
              ref: ref,
              initialConfig: config,
              onSubmitted: (context, text, _) {
                context.navigator.pop();
                _addTag(ref, text, exclude: exclude);
              },
              onSelected: (tag, _) {
                _addTag(ref, tag, exclude: exclude);
              },
            );
          },
          icon: const Icon(Symbols.add),
        ),
      ],
    );
  }

  void _addTag(
    WidgetRef ref,
    String tag, {
    bool exclude = false,
  }) {
    if (tag.isEmpty) return;

    final tags = queryAsList(ref.read(alwaysIncludeTagsProvider));

    tags.add(exclude ? '-$tag' : tag);

    final json = jsonEncode(tags);

    ref.updateAlwaysIncludeTags(json);
  }

  void _removeTag(
    WidgetRef ref,
    String tag,
  ) {
    if (tag.isEmpty) return;

    final tags = queryAsList(ref.read(alwaysIncludeTagsProvider)).toList();

    tags.remove(tag);

    final json = jsonEncode(tags);

    ref.updateAlwaysIncludeTags(json);
  }
}

List<String> queryAsList(String? query) {
  if (query == null) return [];
  final json = jsonDecode(query);

  if (json is! List) return [];

  try {
    return [for (final tag in json) tag as String];
  } catch (e) {
    return [];
  }
}

class _EffectiveTagPreview extends ConsumerWidget {
  const _EffectiveTagPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tags = ref.watch(alwaysIncludeTagsProvider);

    final rawTags = queryAsList(tags);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: context.theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.theme.colorScheme.onSecondaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          Wrap(
            runAlignment: WrapAlignment.center,
            spacing: 5,
            children: [
              IgnorePointer(
                child: RawCompactChip(
                  backgroundColor: Colors.transparent,
                  label: Text(
                    '<your search query>',
                    style: TextStyle(
                      color: context.theme.colorScheme.onSecondaryContainer
                          .withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
              ...rawTags.map(
                (e) => RawCompactChip(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  label: RichText(
                    text: TextSpan(
                      children: [
                        if (e.startsWith('-'))
                          TextSpan(
                            text: '-',
                            style: TextStyle(
                              color: context.theme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        TextSpan(
                          text: e.startsWith('-') ? e.substring(1) : e,
                          style: TextStyle(
                            color:
                                context.theme.colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  backgroundColor:
                      context.theme.colorScheme.surfaceContainerHighest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
