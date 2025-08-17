// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/create/widgets.dart';
import '../../../core/configs/auth/widgets.dart';

class CreateSankakuConfigPage extends ConsumerWidget {
  const CreateSankakuConfigPage({
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
      authTab: const SankakuAuthConfigView(),
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
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 24),
          DefaultBooruLoginField(),
          SizedBox(height: 16),
          DefaultBooruApiKeyField(
            isPassword: true,
            hintText: 'Your password',
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
