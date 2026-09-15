// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../config/types.dart';
import '../../../create/providers.dart';

class ProxyPasswordInput extends ConsumerWidget {
  const ProxyPasswordInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    return KurumiTextFormField(
      initialValue: proxySettings?.password,
      onChanged: (value) {
        ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(password: () => value),
        );
      },
      decoration: InputDecoration(
        labelText: context.t.booru.network.proxy.password,
        hintText: context.t.booru.network.proxy.password_hint,
      ),
    );
  }
}
