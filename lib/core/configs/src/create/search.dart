// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../search/queries/providers.dart';
import '../../../search/search/routes.dart';
import '../booru_config.dart';
import '../booru_config_converter.dart';
import '../data/booru_config_data.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';
import 'search_blacklist.dart';

class DefaultBooruConfigSearchView extends ConsumerWidget {
  const DefaultBooruConfigSearchView({
    super.key,
    this.hasRatingFilter = false,
  });

  final bool hasRatingFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    return BooruConfigSearchView(
      hasRatingFilter: hasRatingFilter,
      config: config.auth,
    );
  }
}

class BooruConfigSearchView extends ConsumerWidget {
  const BooruConfigSearchView({
    required this.hasRatingFilter,
    required this.config,
    super.key,
    this.extras,
  });

  final bool hasRatingFilter;
  final List<Widget>? extras;
  final BooruConfigAuth config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alwaysIncludeTags = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.alwaysIncludeTags),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (hasRatingFilter) ...[
            const SizedBox(height: 12),
            const DefaultBooruRatingOptionsTile(),
            const Divider(),
          ],
          if (extras != null) ...[
            ...extras!,
            const Divider(),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Flexible(
                child: Text(
                  'Include these tags in every search',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTooltip(),
            ],
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
          Row(
            children: [
              Flexible(
                child: Text(
                  'Exclude these tags in every search',
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildTooltip(),
            ],
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
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BooruConfigDataProvider(
                  builder: (data) => _EffectiveTagPreview(
                    configData: data,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const EnableAdditionalBlacklistSwitch(),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BooruConfigDataProvider(
                  builder: (data) => const AdditionalBlacklistedTags(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTooltip() {
    return const Tooltip(
      message:
          'These tags will be appended to every search that the app makes, not just the ones you make manually.',
      triggerMode: TooltipTriggerMode.tap,
      showDuration: Duration(seconds: 5),
      child: Icon(
        Symbols.info,
        size: 14,
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
      runSpacing: 5,
      children: [
        ...tags.map(
          (e) => Chip(
            backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            label: exclude
                ? Text(e.substring(1).replaceAll('_', ' '))
                : Text(e.replaceAll('_', ' ')),
            deleteIcon: Icon(
              Symbols.close,
              size: 16,
              color: Theme.of(context).colorScheme.error,
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
                Navigator.of(context).pop();
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

  String? alwaysIncludeTags(WidgetRef ref) => ref.read(
        editBooruConfigProvider(ref.read(editBooruConfigIdProvider))
            .select((value) => value.alwaysIncludeTags),
      );

  void _addTag(
    WidgetRef ref,
    String tag, {
    bool exclude = false,
  }) {
    if (tag.isEmpty) return;

    final tags = queryAsList(alwaysIncludeTags(ref))
      ..add(exclude ? '-$tag' : tag);

    final json = jsonEncode(tags);

    ref.editNotifier.updateAlwaysIncludeTags(json);
  }

  void _removeTag(
    WidgetRef ref,
    String tag,
  ) {
    if (tag.isEmpty) return;

    final tags = queryAsList(alwaysIncludeTags(ref))..remove(tag);

    final json = jsonEncode(tags);

    ref.editNotifier.updateAlwaysIncludeTags(json);
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
  const _EffectiveTagPreview({
    required this.configData,
  });

  final BooruConfigData configData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final tags = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.alwaysIncludeTags),
    );

    final effectiveConfigData = configData.copyWith(
      alwaysIncludeTags: () => tags,
    );

    final config = effectiveConfigData.toBooruConfig(id: -1);

    if (config == null) return const SizedBox.shrink();

    final tagComposer = ref.watch(tagQueryComposerProvider(config.search));

    final rawTags = tagComposer.compose([]);

    return TagListPreview(
      header: Text(
        'Preview',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      content: Wrap(
        runAlignment: WrapAlignment.center,
        spacing: 5,
        runSpacing: 5,
        children: [
          IgnorePointer(
            child: RawCompactChip(
              backgroundColor: Colors.transparent,
              label: Text(
                '<any search query>',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          ...rawTags.map(
            (e) => TagSearchConfigChip(tag: e),
          ),
        ],
      ),
    );
  }
}

class TagListPreview extends StatelessWidget {
  const TagListPreview({
    required this.content,
    required this.header,
    super.key,
  });

  final Widget content;
  final Widget header;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }
}

class TagSearchConfigChip extends StatelessWidget {
  const TagSearchConfigChip({
    required this.tag,
    super.key,
  });

  final String tag;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RawCompactChip(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      label: RichText(
        text: TextSpan(
          children: [
            if (tag.startsWith('-'))
              TextSpan(
                text: '—',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            TextSpan(
              text: tag.startsWith('-') ? tag.substring(1) : tag,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
