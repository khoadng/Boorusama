// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../config/types.dart';
import '../../../create/providers.dart';

class ProxyUsernameInput extends ConsumerWidget {
  const ProxyUsernameInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    return KurumiTextFormField(
      initialValue: proxySettings?.username,
      onChanged: (value) {
        ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(username: () => value),
        );
      },
      decoration: InputDecoration(
        labelText: context.t.booru.network.proxy.username,
        hintText: context.t.booru.network.proxy.username_hint,
      ),
    );
  }
}
