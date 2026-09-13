// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/data.dart';
import '../../../../settings/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';

class EnableProxySwitch extends ConsumerWidget {
  const EnableProxySwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    return SettingAnchor(
      id: SettingsIndex.network.proxy.id,
      child: KurumiSwitchListTile(
        contentPadding: const EdgeInsets.only(left: 4),
        title: Text(
          SettingsIndex.network.proxy.title(context),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        value: proxySettings?.enable ?? false,
        onChanged: (value) => ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(enable: value),
        ),
      ),
    );
  }
}
