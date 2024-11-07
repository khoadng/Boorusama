// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'philomena_post.dart';

class CreatePhilomenaConfigPage extends StatelessWidget {
  const CreatePhilomenaConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: const PhilomenaAuthConfigView(),
      postDetailsResolution: const PhilomenaImageDetailsQualityProvider(),
      canSubmit: alwaysSubmit,
    );
  }
}

class PhilomenaAuthConfigView extends ConsumerWidget {
  const PhilomenaAuthConfigView({
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
          DefaultBooruApiKeyField(
            hintText: 'e.g: AC8gZrxKsDpWy3unU0jB',
          ),
          SizedBox(height: 8),
          DefaultBooruInstructionText(
            '*You can find your authentication token in your account settings in the browser',
          ),
        ],
      ),
    );
  }
}

class PhilomenaImageDetailsQualityProvider extends ConsumerWidget {
  const PhilomenaImageDetailsQualityProvider({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageDetailsQuality = ref.watch(editBooruConfigProvider(
      ref.watch(editBooruConfigIdProvider),
    ).select((value) => value.imageDetaisQuality));

    return CreateBooruImageDetailsResolutionOptionTile(
      value: imageDetailsQuality,
      items: PhilomenaPostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) => ref.editNotifier.updateImageDetailsQuality(value),
    );
  }
}
