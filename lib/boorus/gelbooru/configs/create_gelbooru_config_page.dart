// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'widgets.dart';

class CreateGelbooruConfigPage extends ConsumerWidget {
  const CreateGelbooruConfigPage({
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
        authTab: const GelbooruAuthView(),
        hasDownloadTab: true,
        hasRatingFilter: true,
        tabsBuilder: (context) => {},
        submitButtonBuilder: (data) =>
            GelbooruBooruConfigSubmitButton(data: data),
      ),
    );
  }
}

class GelbooruAuthView extends ConsumerStatefulWidget {
  const GelbooruAuthView({super.key});

  @override
  ConsumerState<GelbooruAuthView> createState() => _GelbooruAuthViewState();
}

class _GelbooruAuthViewState extends ConsumerState<GelbooruAuthView> {
  late final loginController = TextEditingController(
    text: ref.read(loginProvider),
  );
  late final apiKeyController = TextEditingController(
    text: ref.read(apiKeyProvider),
  );

  @override
  void dispose() {
    super.dispose();
    loginController.dispose();
    apiKeyController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          GelbooruLoginField(
            controller: loginController,
          ),
          const SizedBox(height: 16),
          GelbooruApiKeyField(
            controller: apiKeyController,
          ),
          const SizedBox(height: 8),
          Text(
            '*Log in to your account on the browser, visit My Account > Options > API Access Credentials and fill the values manually.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'or',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GelbooruConfigPasteFromClipboardButton(
                login: loginController,
                apiKey: apiKeyController,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GelbooruBooruConfigSubmitButton extends ConsumerWidget {
  const GelbooruBooruConfigSubmitButton({
    super.key,
    required this.data,
  });

  final BooruConfigData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);

    return DefaultBooruConfigSubmitButton(
      config: config,
      dataBuilder: () => data.copyWith(
        login: auth.login,
        apiKey: auth.apiKey,
      ),
      enable: auth.isValid,
    );
  }
}
