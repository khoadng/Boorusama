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

class ProxyPortInput extends ConsumerWidget {
  const ProxyPortInput({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proxySettings = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.proxySettingsTyped),
    );

    final initialValue = proxySettings?.port.toString() ?? '';

    return SettingAnchor(
      id: SettingsIndex.network.proxyPort.id,
      child: KurumiTextFormField(
        initialValue: initialValue == '0' ? '' : initialValue,
        onChanged: (value) {
          final port = int.tryParse(value);

          if (port == null) {
            return;
          }

          ref.editNotifier.updateProxySettings(
            proxySettings?.copyWith(port: port),
          );
        },
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: SettingsIndex.network.proxyPort.title(context),
          hintText: context.t.booru.network.proxy.port_hint,
        ),
      ),
    );
  }
}
