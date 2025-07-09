// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../search/search/routes.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../../../create/widgets.dart';
import '../types/utils.dart';
import '../widgets/additional_blacklisted_tags.dart';
import '../widgets/default_booru_rating_options_tile.dart';
import '../widgets/effective_tag_preview.dart';
import '../widgets/enable_additional_blacklist_switch.dart';

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
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.alwaysIncludeTags),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.8),
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
                  builder: (data) => EffectiveTagPreview(
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
    editBooruConfigProvider(
      ref.read(editBooruConfigIdProvider),
    ).select((value) => value.alwaysIncludeTags),
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
