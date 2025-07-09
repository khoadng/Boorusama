// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../create/providers.dart';
import '../../widgets.dart';

class DefaultBooruLoginField extends ConsumerWidget {
  const DefaultBooruLoginField({
    super.key,
    this.hintText,
    this.labelText,
  });

  final String? hintText;
  final String? labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.login),
    );

    return CreateBooruLoginField(
      text: login,
      labelText: labelText ?? context.t.booru.login_name_label,
      hintText: hintText ?? 'e.g: my_login',
      onChanged: ref.editNotifier.updateLogin,
    );
  }
}
