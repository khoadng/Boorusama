// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';
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

    return BooruTextFormField(
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
      decoration: const InputDecoration(
        labelText: 'Port (*)',
        hintText: '8080',
      ),
    );
  }
}
