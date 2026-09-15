// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
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

    return KurumiSwitchListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      title: Text(
        context.t.booru.search.enable_profile_specific_settings,
      ),
      value: blacklistConfigs.enable,
      onChanged: (value) => notifier.changeEnable(value),
    );
  }
}
