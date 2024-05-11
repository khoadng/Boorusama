// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class CreateSzurubooruConfigPage extends ConsumerWidget {
  const CreateSzurubooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    this.isNewConfig = false,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        authTab: const SzurubooruAuthConfigView(),
      ),
    );
  }
}

class SzurubooruAuthConfigView extends ConsumerWidget {
  const SzurubooruAuthConfigView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          DefaultBooruLoginField(
            labelText: 'Username',
            hintText: 'e.g: my_username',
          ),
          SizedBox(height: 16),
          DefaultBooruApiKeyField(
            labelText: 'Token',
            hintText: 'e.g: aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
          ),
          SizedBox(height: 8),
          DefaultBooruInstructionText(
            '*Log in to your account on the browser, visit Account > Login tokens. Copy your "Web Login Token" or create a new one if needed and paste it here. If you use the "Web Login Token", logout from the browser will make the token invalid.',
          ),
        ],
      ),
    );
  }
}
