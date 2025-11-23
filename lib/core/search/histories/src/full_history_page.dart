// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import 'providers.dart';
import 'types/search_history.dart';
import 'widgets/full_history_view.dart';

class FullHistoryPage extends ConsumerStatefulWidget {
  const FullHistoryPage({
    required this.onTap,
    super.key,
    this.scrollController,
  });

  final Function(BuildContext context, SearchHistory history) onTap;
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
        title: Text(context.t.search.history.history),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              routeSettings: const RouteSettings(name: 'clear_all_history'),
              builder: (context) => AlertDialog(
                content: Text('Are you sure?'.hc),
                actions: [
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(context.t.generic.action.cancel),
                  ),
                  Consumer(
                    builder: (_, ref, _) {
                      final notifier = ref.watch(
                        searchHistoryProvider.notifier,
                      );

                      return FilledButton(
                        onPressed: () {
                          notifier.clearHistories();
                          Navigator.of(context).pop();
                        },
                        child: Text(context.t.generic.action.ok),
                      );
                    },
                  ),
                ],
              ),
            ),
            child: Text(context.t.search.history.clear),
          ),
        ],
      ),
      body: FullHistoryView(
        scrollController: widget.scrollController,
        onHistoryTap: (value) => widget.onTap(context, value),
      ),
    );
  }
}
