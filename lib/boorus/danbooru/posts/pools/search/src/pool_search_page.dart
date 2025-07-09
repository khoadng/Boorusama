// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'providers.dart';
import 'views/pool_search_result_view.dart';
import 'views/pool_search_suggestion_view.dart';
import 'widgets/pool_search_bar.dart';

class PoolSearchPage extends ConsumerStatefulWidget {
  const PoolSearchPage({super.key});

  @override
  ConsumerState<PoolSearchPage> createState() => _PoolSearchPageState();
}

class _PoolSearchPageState extends ConsumerState<PoolSearchPage> {
  final textEditingController = TextEditingController();

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(danbooruPoolSearchModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: PoolSearchBar(controller: textEditingController),
      ),
      body: switch (mode) {
        PoolSearchMode.suggestion => PoolSearchSuggestionView(
          textEditingController: textEditingController,
        ),
        PoolSearchMode.result => const PoolSearchResultView(),
      },
    );
  }
}
