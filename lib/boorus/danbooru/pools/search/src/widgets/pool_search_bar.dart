// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../core/search/search/widgets.dart';
import '../providers.dart';

class PoolSearchBar extends ConsumerWidget {
  const PoolSearchBar({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(danbooruPoolQueryProvider);

    return BooruSearchBar(
      leading: IconButton(
        splashRadius: 16,
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(
          Symbols.arrow_back,
        ),
      ),
      controller: controller,
      autofocus: true,
      trailing: query != null && query.isNotEmpty
          ? IconButton(
              onPressed: () {
                controller.clear();
                ref.read(danbooruPoolQueryProvider.notifier).state = '';
              },
              icon: const Icon(Symbols.close),
            )
          : const SizedBox.shrink(),
      onChanged: (value) =>
          ref.read(danbooruPoolQueryProvider.notifier).state = value,
      onSubmitted: (value) {
        ref.read(danbooruPoolSearchModeProvider.notifier).state =
            PoolSearchMode.result;
      },
      hintText: context.t.pool.search.hint,
      onTap: () => ref.read(danbooruPoolSearchModeProvider.notifier).state =
          PoolSearchMode.suggestion,
    );
  }
}
