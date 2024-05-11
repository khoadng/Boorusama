// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';

class CreateSankakuConfigPage extends ConsumerWidget {
  const CreateSankakuConfigPage({
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
        authTab: const SankakuAuthConfigView(),
        hasDownloadTab: true,
      ),
    );
  }
}

class SankakuAuthConfigView extends ConsumerWidget {
  const SankakuAuthConfigView({
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
          DefaultBooruLoginField(),
          SizedBox(height: 16),
          DefaultBooruApiKeyField(
            isPassword: true,
            hintText: '',
          ),
          SizedBox(height: 8),
          DefaultBooruInstructionText(
            '*Without login credentials, some features may not work.',
          ),
        ],
      ),
    );
  }
}
