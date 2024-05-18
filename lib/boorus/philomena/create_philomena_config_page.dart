// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/configs/providers.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'philomena_post.dart';

class CreatePhilomenaConfigPage extends StatelessWidget {
  const CreatePhilomenaConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
  });

  final BooruConfig config;
  final Color? backgroundColor;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        authTab: const PhilomenaAuthConfigView(),
        postDetailsResolution: const PhilomenaImageDetailsQualityProvider(),
        submitButtonBuilder: (data) => PhilomenaConfigSubmitButton(data: data),
      ),
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
    final config = ref.watch(initialBooruConfigProvider);
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return CreateBooruImageDetailsResolutionOptionTile(
      value: imageDetailsQuality,
      items: PhilomenaPostQualityType.values.map((e) => e.stringify()).toList(),
      onChanged: (value) =>
          ref.read(imageDetailsQualityProvider(config).notifier).state = value,
    );
  }
}

class PhilomenaConfigSubmitButton extends ConsumerWidget {
  const PhilomenaConfigSubmitButton({
    super.key,
    required this.data,
  });

  final BooruConfigData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return RawBooruConfigSubmitButton(
      config: config,
      data: data.copyWith(
        apiKey: auth.apiKey,
        imageDetaisQuality: () => imageDetailsQuality,
      ),
      enable: true,
    );
  }
}
