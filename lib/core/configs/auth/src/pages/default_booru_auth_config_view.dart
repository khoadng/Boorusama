// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../widgets/default_booru_api_key_field.dart';
import '../widgets/default_booru_instruction_text.dart';
import '../widgets/default_booru_login_field.dart';

class DefaultBooruAuthConfigView extends ConsumerWidget {
  const DefaultBooruAuthConfigView({
    super.key,
    this.instruction,
    this.showInstructionWhen = true,
    this.customInstruction,
  });

  final String? instruction;
  final Widget? customInstruction;
  final bool showInstructionWhen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruLoginField(),
          const SizedBox(height: 16),
          const DefaultBooruApiKeyField(),
          const SizedBox(height: 8),
          if (showInstructionWhen)
            if (customInstruction != null)
              customInstruction!
            else if (instruction != null)
              DefaultBooruInstructionText(
                instruction!,
              )
            else
              const SizedBox.shrink(),
        ],
      ),
    );
  }
}
