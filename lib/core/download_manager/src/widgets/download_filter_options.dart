// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../widgets/choice_option_selector_list.dart';
import '../l10n.dart';
import '../providers/internal_providers.dart';
import '../types/download_filter.dart';

class DownloadFilterOptions extends ConsumerWidget {
  const DownloadFilterOptions({
    required this.scrollController,
    required this.filter,
    super.key,
  });

  final String? filter;
  final AutoScrollController? scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(downloadFilterProvider(filter));
    return ChoiceOptionSelectorList(
      scrollController: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      searchable: false,
      options: kFilterOptions,
      hasNullOption: false,
      optionLabelBuilder: (value) => value.localize(context),
      onSelected: (value) {
        if (value == null) return;

        ref.read(downloadFilterProvider(filter).notifier).state = value;
      },
      selectedOption: selectedFilter,
    );
  }
}
