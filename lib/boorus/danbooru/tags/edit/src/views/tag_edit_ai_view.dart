// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/theme.dart';
import '../../../../../../core/theme/providers.dart';
import '../../../../../../core/widgets/widgets.dart';
import '../../../../../../foundation/platform.dart';
import '../../../ai/providers.dart';

class TagEditAITagView extends ConsumerStatefulWidget {
  const TagEditAITagView({
    required this.onRemoved,
    required this.onAdded,
    required this.isSelected,
    required this.postId,
    super.key,
  });

  final int postId;
  final void Function(String tag) onRemoved;
  final void Function(String tag) onAdded;
  final bool Function(String tag) isSelected;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagEditAITagViewState();
}

class _TagEditAITagViewState extends ConsumerState<TagEditAITagView> {
  @override
  Widget build(BuildContext context) {
    final tagAsync = ref.watch(danbooruAITagsProvider(widget.postId));

    return SingleChildScrollView(
      child: Column(
        children: [
          WarningContainer(
            title: 'Warning',
            contentBuilder: (context) {
              return Text(
                'The suggested tags are generated by AI, please check them carefully before submitting.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              );
            },
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: tagAsync.maybeWhen(
              data: (tags) => Wrap(
                spacing: 4,
                runSpacing: isDesktopPlatform() ? 4 : 0,
                children: tags.map((d) {
                  final tag = d.tag;
                  final colors = ref.watch(
                    chipColorsFromTagStringProvider(
                      (ref.watchConfigAuth, tag.category.name),
                    ),
                  );
                  final selected = widget.isSelected(tag.name);

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
                            color: selected
                                ? colors.borderColor
                                : Colors.transparent,
                          )
                        : null,
                    onSelected: (value) => value
                        ? widget.onAdded(tag.name)
                        : widget.onRemoved(tag.name),
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
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            TextSpan(
                              text: '  ${d.score}%',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 11,
                                    color: Theme.of(context).brightness.isLight
                                        ? !selected
                                              ? null
                                              : Colors.white.withValues(
                                                  alpha: 0.85,
                                                )
                                        : Theme.of(
                                            context,
                                          ).colorScheme.hintColor,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              orElse: () => const Center(
                child: CircularProgressIndicator.adaptive(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
