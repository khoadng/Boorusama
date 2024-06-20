// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/widgets.dart';

class TagEditWikiView extends ConsumerStatefulWidget {
  const TagEditWikiView({
    super.key,
    required this.onRemoved,
    required this.onAdded,
    required this.isSelected,
    required this.tag,
  });

  final String? tag;
  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditzwikiViewState();
}

class _TagEditzwikiViewState extends ConsumerState<TagEditWikiView> {
  final relatedTabs = const [
    'all',
    'wiki',
  ];
  var selectTab = 'all';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: widget.tag.toOption().fold(
            () => const Center(
              child: Text(
                'Select a tag to view related tags',
              ),
            ),
            (tag) => SingleChildScrollView(
              child: Column(
                children: [
                  Center(
                    child: BooruSegmentedButton(
                      segments: {
                        for (final entry in relatedTabs)
                          entry: entry.sentenceCase,
                      },
                      initialValue: selectTab,
                      onChanged: (values) {
                        setState(() {
                          selectTab = values;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  switch (selectTab) {
                    'wiki' =>
                      ref.watch(danbooruWikiTagsProvider(tag)).maybeWhen(
                            data: (data) => data.isNotEmpty
                                ? _RelatedTagChips(
                                    tags: data,
                                    isSelected: widget.isSelected,
                                    onAdded: widget.onAdded,
                                    onRemoved: widget.onRemoved,
                                  )
                                : const Center(child: Text('No tags found')),
                            orElse: () => const Center(
                              child: SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                    _ => ref.watch(danbooruRelatedTagsProvider(tag)).maybeWhen(
                          data: (data) => _RelatedTagChips(
                            tags: data,
                            isSelected: widget.isSelected,
                            onAdded: widget.onAdded,
                            onRemoved: widget.onRemoved,
                          ),
                          orElse: () => const Center(
                            child: SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                  },
                ],
              ),
            ),
          ),
    );
  }
}

class _RelatedTagChips extends ConsumerWidget {
  const _RelatedTagChips({
    required this.tags,
    required this.isSelected,
    required this.onAdded,
    required this.onRemoved,
  });

  final List<Tag> tags;
  final bool Function(String tag) isSelected;
  final void Function(String tag) onAdded;
  final void Function(String tag) onRemoved;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 4,
      runSpacing: isDesktopPlatform() ? 4 : 0,
      children: tags.map((tag) {
        final selected = isSelected(tag.name);
        final colors = context.generateChipColors(
          ref.getTagColor(context, tag.category.name),
          ref.watch(settingsProvider),
        );

        return RawChip(
          selected: selected,
          showCheckmark: false,
          checkmarkColor: colors?.foregroundColor,
          visualDensity: VisualDensity.compact,
          selectedColor: colors?.backgroundColor,
          backgroundColor: selected
              ? colors?.backgroundColor
              : context.colorScheme.secondaryContainer,
          side: selected
              ? colors != null
                  ? BorderSide(
                      width: 1,
                      color: colors.borderColor,
                    )
                  : null
              : null,
          onSelected: (value) =>
              value ? onAdded(tag.name) : onRemoved(tag.name),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.screenWidth * 0.8,
            ),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: tag.name.replaceUnderscoreWithSpace(),
                style: TextStyle(
                  color: selected
                      ? colors?.foregroundColor
                      : context.colorScheme.onSecondaryContainer,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '  ${NumberFormat.compact().format(tag.postCount)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: context.themeMode.isLight
                          ? !selected
                              ? null
                              : Colors.white.withOpacity(0.85)
                          : Colors.grey.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
