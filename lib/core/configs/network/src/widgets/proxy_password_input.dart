// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/data.dart';
import '../../../../settings/widgets.dart';
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

    return SettingAnchor(
      id: SettingsIndex.network.proxyPassword.id,
      child: KurumiTextFormField(
        initialValue: proxySettings?.password,
        onChanged: (value) {
          ref.editNotifier.updateProxySettings(
            proxySettings?.copyWith(password: () => value),
          );
        },
        decoration: InputDecoration(
          labelText: SettingsIndex.network.proxyPassword.title(
            context,
          ),
          hintText: context.t.booru.network.proxy.password_hint,
        ),
      ),
    );
  }
}
