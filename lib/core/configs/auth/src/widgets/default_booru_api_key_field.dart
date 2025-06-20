// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../create/providers.dart';
import '../../widgets.dart';

class DefaultBooruApiKeyField extends ConsumerWidget {
  const DefaultBooruApiKeyField({
    super.key,
    this.hintText,
    this.labelText,
    this.isPassword = false,
  });

  final String? hintText;
  final String? labelText;
  final bool isPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.apiKey),
    );

    return CreateBooruApiKeyField(
      text: apiKey,
      labelText: isPassword ? 'booru.password_label'.tr() : labelText,
      hintText: hintText ?? 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
      onChanged: ref.editNotifier.updateApiKey,
    );
  }
}
