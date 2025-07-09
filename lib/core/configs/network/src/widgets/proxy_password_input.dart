// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../widgets/booru_text_form_field.dart';
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

    return BooruTextFormField(
      initialValue: proxySettings?.password,
      onChanged: (value) {
        ref.editNotifier.updateProxySettings(
          proxySettings?.copyWith(password: () => value),
        );
      },
      decoration: const InputDecoration(
        labelText: 'Password',
        hintText: 'password (optional)',
      ),
    );
  }
}
