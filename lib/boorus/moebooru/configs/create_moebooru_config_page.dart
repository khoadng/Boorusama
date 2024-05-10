// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'widgets.dart';

class CreateMoebooruConfigPage extends ConsumerWidget {
  const CreateMoebooruConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
  });

  final BooruConfig config;
  final Color? backgroundColor;
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
        authTab: const MoebooruAuthConfigView(),
        hasDownloadTab: true,
        hasRatingFilter: true,
      ),
    );
  }
}

class MoebooruAuthConfigView extends ConsumerStatefulWidget {
  const MoebooruAuthConfigView({
    super.key,
  });

  @override
  ConsumerState<MoebooruAuthConfigView> createState() =>
      _MoebooruAuthConfigViewState();
}

class _MoebooruAuthConfigViewState
    extends ConsumerState<MoebooruAuthConfigView> {
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruLoginField(),
          const SizedBox(height: 16),
          MoebooruPasswordField(
            controller: passwordController,
          ),
          const SizedBox(height: 8),
          MoebooruHashedPasswordField(
            passwordController: passwordController,
          ),
          const DefaultBooruInstructionText(
            'The app will use the hashed password to authenticate with the site. Your password will not be stored.',
          ),
        ],
      ),
    );
  }
}
