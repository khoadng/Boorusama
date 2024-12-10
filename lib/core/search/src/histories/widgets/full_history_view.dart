// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:animated_list_plus/transitions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../../foundation/animations.dart';
import '../../../../foundation/display.dart';
import '../../../../router.dart';
import '../../../../theme.dart';
import '../../search_page/widgets/booru_search_bar.dart';
import '../providers.dart';
import '../search_history.dart';
import 'search_history_section.dart';

void goToSearchHistoryPage(
  BuildContext context, {
  required Function() onClear,
  required Function(SearchHistory history) onRemove,
  required Function(SearchHistory history) onTap,
}) {
  showMaterialModalBottomSheet(
    context: context,
    settings: const RouteSettings(
      name: RouterPageConstant.searchHistories,
    ),
    duration: AppDurations.bottomSheet,
    builder: (context) => FullHistoryPage(
      onClear: onClear,
      onRemove: onRemove,
      onTap: onTap,
      scrollController: ModalScrollController.of(context),
    ),
  );
}

class FullHistoryPage extends ConsumerStatefulWidget {
  const FullHistoryPage({
    super.key,
    required this.onClear,
    required this.onRemove,
    required this.onTap,
    this.scrollController,
  });

  final Function() onClear;
  final Function(SearchHistory history) onRemove;
  final Function(SearchHistory history) onTap;
  final ScrollController? scrollController;

  @override
  ConsumerState<FullHistoryPage> createState() => _FullHistoryPageState();
}

class _FullHistoryPageState extends ConsumerState<FullHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(searchHistoryProvider.notifier).resetFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('search.history.history').tr(),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: const Text('Are you sure?').tr(),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('generic.action.cancel').tr(),
                  ),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onClear();
                    },
                    child: const Text('generic.action.ok').tr(),
                  ),
                ],
              ),
            ),
            child: const Text('search.history.clear').tr(),
          ),
        ],
      ),
      body: FullHistoryView(
        scrollController: widget.scrollController,
        onHistoryTap: (value) => widget.onTap(value),
        onHistoryRemoved: (value) => widget.onRemove(value),
      ),
    );
  }
}

class FullHistoryView extends ConsumerWidget {
  const FullHistoryView({
    super.key,
    required this.onHistoryTap,
    required this.onHistoryRemoved,
    this.scrollController,
    this.useAppbar = true,
  });

  final ValueChanged<SearchHistory> onHistoryTap;
  final void Function(SearchHistory item) onHistoryRemoved;
  final bool useAppbar;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: BooruSearchBar(
            onChanged: (value) =>
                ref.read(searchHistoryProvider.notifier).filterHistories(value),
          ),
        ),
        ref.watch(searchHistoryProvider).maybeWhen(
              data: (histories) => Expanded(
                child: ImplicitlyAnimatedList(
                  items: histories.filteredHistories,
                  controller: scrollController,
                  areItemsTheSame: (oldItem, newItem) => oldItem == newItem,
                  insertDuration: const Duration(milliseconds: 250),
                  removeDuration: const Duration(milliseconds: 250),
                  itemBuilder: (context, animation, history, index) =>
                      SizeFadeTransition(
                    sizeFraction: 0.7,
                    curve: Curves.easeInOut,
                    animation: animation,
                    child: ListTile(
                      key: ValueKey(history.query),
                      title: SearchHistoryQueryWidget(history: history),
                      subtitle: DateTooltip(
                        date: history.createdAt,
                        child: Text(
                          history.createdAt
                              .fuzzify(locale: Localizations.localeOf(context)),
                        ),
                      ),
                      onTap: () {
                        onHistoryTap(history);
                      },
                      contentPadding: kPreferredLayout.isDesktop
                          ? const EdgeInsets.symmetric(
                              horizontal: 12,
                            )
                          : null,
                      minTileHeight: kPreferredLayout.isDesktop ? 0 : null,
                      trailing: IconButton(
                        onPressed: () => onHistoryRemoved(history),
                        icon: Icon(
                          Symbols.close,
                          color: Theme.of(context).colorScheme.hintColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
      ],
    );
  }
}
