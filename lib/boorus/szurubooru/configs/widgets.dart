// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/configs/create/widgets.dart';
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/search/widgets.dart';

class CreateSzurubooruConfigPage extends ConsumerWidget {
  const CreateSzurubooruConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      searchTab: const DefaultBooruConfigSearchView(
        hasRatingFilter: true,
      ),
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: const SzurubooruAuthConfigView(),
    );
  }
}

class SzurubooruAuthConfigView extends ConsumerWidget {
  const SzurubooruAuthConfigView({
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
          const DefaultBooruLoginField(
            labelText: 'Username',
            hintText: 'e.g: my_username',
          ),
          const SizedBox(height: 16),
          const DefaultBooruApiKeyField(
            labelText: 'Token',
            hintText: 'e.g: aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee',
          ),
          const SizedBox(height: 8),
          DefaultBooruInstructionHtmlText(
            context.t.booru.api_key_instructions.variants_4,
          ),
        ],
      ),
    );
  }
}
