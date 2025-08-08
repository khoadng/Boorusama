// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/utils/flutter_utils.dart';
import '../../../../../foundation/utils/int_utils.dart';
import '../../../../theme/app_theme.dart';
import 'post_grid_controller.dart';

final _currentPageProvider = StateProvider<int>((ref) => 1);
const _tagThreshold = 30;

class BlacklistControls extends StatelessWidget {
  const BlacklistControls({
    required this.hiddenTags,
    required this.onChanged,
    required this.onEnableAll,
    required this.onDisableAll,
    required this.axis,
    super.key,
  });

  final List<HiddenData>? hiddenTags;
  final void Function(String tag, bool value) onChanged;
  final VoidCallback onEnableAll;
  final VoidCallback onDisableAll;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    if (hiddenTags == null) {
      return const SizedBox(
        height: 36,
        width: 36,
      );
    }

    final tags = [
      for (final tag in hiddenTags!)
        _BadgedChip(
          label: tag.name.replaceAll('_', ' '),
          count: tag.count,
          active: tag.active,
          onChanged: (value) => onChanged(tag.name, value),
        ),
    ];

    final allTagsHidden = hiddenTags?.every((e) => !e.active);

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
          label: allTagsHidden
              ? Text(context.t.blacklisted_tags.reenable_all)
              : Text(context.t.blacklisted_tags.disable_all),
          onPressed: allTagsHidden ? onEnableAll : onDisableAll,
        ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: kPreferredLayout.isMobile ? 4 : 0,
        bottom: 12,
      ),
      child: axis == Axis.horizontal
          ? Builder(
              builder: (context) {
                // if more than threshold tags, paginate
                if (tags.length > _tagThreshold) {
                  return _TagPages(
                    allTags: tags,
                    threshold: _tagThreshold,
                    allTagsHidden: allTagsHidden ?? false,
                    onEnableAll: onEnableAll,
                    onDisableAll: onDisableAll,
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
    final tags = allTags
        .skip((currentPage - 1) * threshold)
        .take(threshold)
        .toList();
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
                    ? context.t.blacklisted_tags.reenable_all
                    : context.t.blacklisted_tags.disable_all,
              ),
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
            _setPage(page, ref);
          },
          onNext: () {
            final page = currentPage + 1;
            _setPage(page, ref);
          },
          onPageSelect: (page) {
            _setPage(page, ref);
          },
        ),
      ],
    );
  }

  void _setPage(int page, WidgetRef ref) {
    // make sure page is within bounds
    final effectivePage = page.clamp(
      1,
      calculateTotalPage(allTags.length, threshold) ?? 1,
    );

    ref.read(_currentPageProvider.notifier).state = effectivePage;
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
    final colorScheme = Theme.of(context).colorScheme;

    return Badge(
      offset: switch (count.digitCount()) {
        < 2 => const Offset(0, -4),
        2 => const Offset(-4, -4),
        3 => const Offset(-8, -4),
        _ => const Offset(-12, -4),
      },
      backgroundColor: colorScheme.primary,
      label: Text(
        count.toString(),
        style: TextStyle(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: ChoiceChip(
        showCheckmark: false,
        visualDensity: const ShrinkVisualDensity(),
        selected: active,
        side: BorderSide(
          color: active ? colorScheme.hintColor : Colors.transparent,
          width: 0.7,
        ),
        backgroundColor: colorScheme.surface,
        label: Text(label),
        onSelected: (value) => onChanged(value),
      ),
    );
  }
}
