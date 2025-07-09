// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
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

    return SwitchListTile(
      contentPadding: const EdgeInsets.only(left: 4),
      title: Text(
        'Proxy'.hc,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      value: proxySettings?.enable ?? false,
      onChanged: (value) => ref.editNotifier.updateProxySettings(
        proxySettings?.copyWith(enable: value),
      ),
    );
  }
}
