// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../widgets/widgets.dart';
import '../../../create/providers.dart';
import '../providers/blacklist_configs_notifier.dart';

class EnableAdditionalBlacklistSwitch extends ConsumerWidget {
  const EnableAdditionalBlacklistSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blacklistConfigs = ref.watch(
      blacklistConfigsProvider(ref.watch(editBooruConfigIdProvider)),
    );
    final notifier = ref.watch(
      blacklistConfigsProvider(ref.watch(editBooruConfigIdProvider)).notifier,
    );

    return BooruSwitchListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      title: Text(
        context.t.booru.search.enable_profile_specific_settings,
      ),
      value: blacklistConfigs.enable,
      onChanged: (value) => notifier.changeEnable(value),
    );
  }
}
