// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../../../create/providers.dart';
import '../providers/blacklist_configs_notifier.dart';
import '../types/blacklist_combination_mode.dart';

class CombinationModeSelector extends ConsumerWidget {
  const CombinationModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(editBooruConfigIdProvider);
    final selectedMode = ref.watch(
      blacklistConfigsProvider(id).select(
        (e) => BlacklistCombinationMode.fromString(e.combinationMode),
      ),
    );

    return SettingsSelector(
      title: context.t.booru.search.blacklist_combine_mode.title,
      value: selectedMode,
      items: kBlacklistCombinationModes,
      itemBuilder: (mode) => switch (mode) {
        BlacklistCombinationMode.merge =>
          context.t.booru.search.blacklist_combine_mode.merge,
        BlacklistCombinationMode.replace =>
          context.t.booru.search.blacklist_combine_mode.replace,
      },
      subtitleBuilder: (mode) => switch (mode) {
        BlacklistCombinationMode.merge =>
          context.t.booru.search.blacklist_combine_mode.merge_description,
        BlacklistCombinationMode.replace =>
          context.t.booru.search.blacklist_combine_mode.replace_description,
      },
      onChanged: (value) {
        ref.read(blacklistConfigsProvider(id).notifier).changeMode(value);
      },
    );
  }
}
