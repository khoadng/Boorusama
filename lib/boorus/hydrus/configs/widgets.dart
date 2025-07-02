// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/create.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/widgets/widgets.dart';

class CreateHydrusConfigPage extends ConsumerWidget {
  const CreateHydrusConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      authTab: const HydrusAuthConfigView(),
      backgroundColor: backgroundColor,
      initialTab: initialTab,
      canSubmit: apiKeyRequired,
    );
  }
}

class HydrusAuthConfigView extends ConsumerWidget {
  const HydrusAuthConfigView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruApiKeyField(
            labelText: 'API access key',
          ),
          const SizedBox(height: 8),
          WarningContainer(
            title: 'Warning',
            contentBuilder: (context) => const Text(
              "It is recommended to not make any changes to Hydrus's services while using the app, you might see unexpected behavior.",
            ),
          ),
        ],
      ),
    );
  }
}
