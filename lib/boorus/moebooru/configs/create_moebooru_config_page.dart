// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/create.dart';
import 'widgets.dart';

class CreateMoebooruConfigPage extends ConsumerWidget {
  const CreateMoebooruConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: const MoebooruAuthConfigView(),
      searchTab: const DefaultBooruConfigSearchView(
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
