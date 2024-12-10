// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../dart.dart';
import '../../../../foundation/display.dart';
import '../../../../utils/flutter_utils.dart';
import '../../../theme.dart';

typedef HiddenData = ({
  String name,
  int count,
  bool active,
});

const _tagThreshold = 30;

class PostListConfigurationHeader extends StatefulWidget {
  const PostListConfigurationHeader({
    super.key,
    required this.tags,
    required this.onChanged,
    required this.hiddenCount,
    required this.onClosed,
    required this.onDisableAll,
    required this.onEnableAll,
    required this.postCount,
    this.trailing,
    this.hasBlacklist = false,
    this.initiallyExpanded = false,
    this.axis = Axis.horizontal,
    this.onExpansionChanged,
  });

  final List<HiddenData>? tags;
  final void Function(String tag, bool value) onChanged;
  final VoidCallback onClosed;
  final Widget? trailing;
  final VoidCallback onDisableAll;
  final VoidCallback onEnableAll;
  final int? hiddenCount;
  final bool hasBlacklist;
  final bool initiallyExpanded;
  final Axis axis;
  final int postCount;
  final void Function(bool value)? onExpansionChanged;

  @override
  State<PostListConfigurationHeader> createState() =>
      _PostListConfigurationHeaderState();
}

class _PostListConfigurationHeaderState
    extends State<PostListConfigurationHeader> {
  late var hiddenTags = widget.tags;
  late var expanded = widget.initiallyExpanded;

  bool? get allTagsHidden => hiddenTags?.every((e) => !e.active);

  @override
  void didUpdateWidget(covariant PostListConfigurationHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.tags != oldWidget.tags) {
      setState(() {
        hiddenTags = widget.tags;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.axis == Axis.horizontal && expanded
          ? Theme.of(context).colorScheme.surface
          : Colors.transparent,
      elevation: widget.axis == Axis.horizontal && expanded ? null : 0,
      shadowColor: widget.axis == Axis.horizontal && expanded
          ? null
          : Colors.transparent,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          listTileTheme: ListTileTheme.of(context).copyWith(
            contentPadding: EdgeInsets.only(left: widget.hasBlacklist ? 6 : 0),
            horizontalTitleGap: 0,
            minVerticalPadding: 0,
            visualDensity: const ShrinkVisualDensity(),
          ),
        ),
        child: widget.hasBlacklist
            ? ExpansionTile(
                initiallyExpanded: expanded,
                leading: Column(
                  children: [
                    const Spacer(),
                    !expanded
                        ? const Icon(Symbols.keyboard_arrow_right)
                        : const Icon(Symbols.keyboard_arrow_down),
                    const Spacer(),
                  ],
                ),
                controlAffinity: ListTileControlAffinity.leading,
                trailing: widget.axis == Axis.horizontal && expanded
                    ? IconButton(
                        onPressed: widget.onClosed,
                        icon: const Icon(Symbols.close),
                      )
                    : null,
                onExpansionChanged: (value) => {
                  setState(() {
                    expanded = value;
                    widget.onExpansionChanged?.call(value);
                  }),
                },
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    return Row(
                      children: [
                        const SizedBox(width: 8),
                        const Text('blacklisted_tags.blacklisted_header_title')
                            .tr(),
                        if (constraints.maxWidth > 250)
                          const SizedBox(width: 8),
                        if (widget.hiddenCount != null)
                          if (widget.hiddenCount! > 0)
                            if (constraints.maxWidth > 250)
                              Chip(
                                padding: EdgeInsets.zero,
                                visualDensity: const ShrinkVisualDensity(),
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                label: Text(
                                  '${widget.hiddenCount} of ${widget.postCount}',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                        const Spacer(),
                        expanded
                            ? const SizedBox.shrink()
                            : FittedBox(
                                child: widget.trailing,
                              ),
                      ],
                    );
                  },
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (hiddenTags != null)
                    _buildTags()
                  else
                    const SizedBox(
                      height: 36,
                      width: 36,
                    ),
                ],
              )
            : ListTile(
                minVerticalPadding: 0,
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    if (widget.axis == Axis.horizontal)
                      Text(
                        '${widget.postCount} Posts',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    const Spacer(),
                    FittedBox(
                      child: widget.trailing,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildTags() {
    final tags = [
      for (final tag in hiddenTags!)
        _BadgedChip(
          label: tag.name.replaceAll('_', ' '),
          count: tag.count,
          active: tag.active,
          onChanged: (value) => widget.onChanged(tag.name, value),
        ),
    ];

    final tagsNonPaginated = [
      ...tags,
      if (allTagsHidden != null)
        ActionChip(
          visualDensity: const ShrinkVisualDensity(),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 0.7,
          ),
          shape: StadiumBorder(
            side: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 0.7,
            ),
          ),
          label: allTagsHidden!
              ? const Text('blacklisted_tags.reenable_all').tr()
              : const Text('blacklisted_tags.disable_all').tr(),
          onPressed: allTagsHidden! ? widget.onEnableAll : widget.onDisableAll,
        ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: kPreferredLayout.isMobile ? 8 : 0,
      ),
      child: widget.axis == Axis.horizontal
          ? Builder(
              builder: (context) {
                // if more than threshold tags, paginate
                if (tags.length > _tagThreshold) {
                  return _TagPages(
                    allTags: tags,
                    threshold: _tagThreshold,
                    allTagsHidden: allTagsHidden ?? false,
                    onEnableAll: widget.onEnableAll,
                    onDisableAll: widget.onDisableAll,
                  );
                } else {
                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: tagsNonPaginated,
                  );
                }
              },
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tag in tagsNonPaginated)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: tag,
                  ),
              ],
            ),
    );
  }
}

final _currentPageProvider = StateProvider<int>((ref) => 1);

class _TagPages extends ConsumerWidget {
  const _TagPages({
    required this.allTags,
    required this.threshold,
    required this.allTagsHidden,
    required this.onEnableAll,
    required this.onDisableAll,
  });

  final List<Widget> allTags;
  final int threshold;
  final bool allTagsHidden;
  final void Function() onEnableAll;
  final void Function() onDisableAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(_currentPageProvider);
    final tags =
        allTags.skip((currentPage - 1) * threshold).take(threshold).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: tags,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: allTagsHidden ? onEnableAll : onDisableAll,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
              ),
              child: Text(
                allTagsHidden
                    ? 'blacklisted_tags.reenable_all'
                    : 'blacklisted_tags.disable_all',
              ).tr(),
            ),
          ],
        ),
        PageSelector(
          pageInput: false,
          currentPage: currentPage,
          totalResults: allTags.length,
          itemPerPage: threshold,
          onPrevious: () {
            final page = currentPage - 1;
            ref.read(_currentPageProvider.notifier).state = page;
          },
          onNext: () {
            final page = currentPage + 1;
            ref.read(_currentPageProvider.notifier).state = page;
          },
          onPageSelect: (page) =>
              ref.read(_currentPageProvider.notifier).state = page,
        ),
      ],
    );
  }
}

class _BadgedChip extends StatelessWidget {
  const _BadgedChip({
    required this.label,
    required this.count,
    required this.active,
    required this.onChanged,
  });

  final int count;
  final bool active;
  final String label;
  final void Function(bool value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Badge(
      offset: switch (count.digitCount()) {
        < 2 => const Offset(0, -4),
        2 => const Offset(-4, -4),
        3 => const Offset(-8, -4),
        _ => const Offset(-12, -4),
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      label: Text(
        count.toString(),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: ChoiceChip(
        showCheckmark: false,
        visualDensity: const ShrinkVisualDensity(),
        selected: active,
        side: BorderSide(
          color: active
              ? Theme.of(context).colorScheme.hintColor
              : Colors.transparent,
          width: 0.7,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        label: Text(label),
        onSelected: (value) => onChanged(value),
      ),
    );
  }
}
