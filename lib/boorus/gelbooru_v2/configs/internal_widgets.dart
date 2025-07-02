// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';

class GelbooruV2ApiKeyField extends ConsumerWidget {
  const GelbooruV2ApiKeyField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruApiKeyField(
      controller: controller,
      hintText:
          'e.g. 2e89f79b593ed40fd8641235f002221374e50d6343d3afe1687fc70decae58dcf',
      onChanged: ref.editNotifier.updateApiKey,
    );
  }
}

class GelbooruV2LoginField extends ConsumerWidget {
  const GelbooruV2LoginField({
    required this.controller,
    super.key,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruLoginField(
      controller: controller,
      labelText: 'User ID',
      hintText: 'e.g. 1234567',
      onChanged: ref.editNotifier.updateLogin,
    );
  }
}
