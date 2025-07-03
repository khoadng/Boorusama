// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:intl/intl.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/tags/tag/tag.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/platform.dart';
import '../../../related/providers.dart';

class TagEditWikiView extends ConsumerStatefulWidget {
  const TagEditWikiView({
    required this.onRemoved,
    required this.onAdded,
    required this.isSelected,
    required this.tag,
    super.key,
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
        final colors = ref.watch(
          chipColorsFromTagStringProvider(
            (ref.watchConfigAuth, tag.category.name),
          ),
        );

        return RawChip(
          selected: selected,
          showCheckmark: false,
          checkmarkColor: colors?.foregroundColor,
          visualDensity: VisualDensity.compact,
          selectedColor: colors?.backgroundColor,
          backgroundColor: selected
              ? colors?.backgroundColor
              : Theme.of(context).colorScheme.surfaceContainer,
          side: colors != null
              ? BorderSide(
                  color: selected ? colors.borderColor : Colors.transparent,
                )
              : null,
          onSelected: (value) =>
              value ? onAdded(tag.name) : onRemoved(tag.name),
          label: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                text: tag.name.replaceAll('_', ' '),
                style: TextStyle(
                  color: selected
                      ? colors?.foregroundColor
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                children: [
                  TextSpan(
                    text: '  ${NumberFormat.compact().format(tag.postCount)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).brightness.isLight
                              ? !selected
                                  ? null
                                  : Colors.white.withValues(alpha: 0.85)
                              : Theme.of(context).colorScheme.hintColor,
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
