// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import 'providers.dart';
import 'search_history.dart';
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
        title: const Text('search.history.history').tr(),
        actions: [
          TextButton(
            onPressed: () => showDialog(
              context: context,
              routeSettings: const RouteSettings(name: 'clear_all_history'),
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
                  Consumer(
                    builder: (_, ref, __) {
                      final notifier =
                          ref.watch(searchHistoryProvider.notifier);

                      return FilledButton(
                        onPressed: () {
                          notifier.clearHistories();
                          Navigator.of(context).pop();
                        },
                        child: const Text('generic.action.ok').tr(),
                      );
                    },
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
        onHistoryTap: (value) => widget.onTap(context, value),
      ),
    );
  }
}
