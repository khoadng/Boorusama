// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../core/configs/create.dart';
import '../../core/foundation/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../gelbooru/configs/widgets.dart';

class CreateGelbooruV2ConfigPage extends StatelessWidget {
  const CreateGelbooruV2ConfigPage({
    required this.url,
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;
  final String url;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      //FIXME: hotfix to have custom auth view for rule34.xxx
      authTab: url.contains('rule34.xxx')
          ? const GelbooruV2AuthRequiredAuthView()
          : const GelbooruV2AuthView(),
      searchTab: const DefaultBooruConfigSearchView(
        hasRatingFilter: true,
      ),
      imageViewerTab: const BooruConfigViewerView(
        autoLoadNotes: DefaultAutoFetchNotesSwitch(),
      ),
    );
  }
}

class GelbooruV2AuthView extends ConsumerStatefulWidget {
  const GelbooruV2AuthView({super.key});

  @override
  ConsumerState<GelbooruV2AuthView> createState() => _GelbooruAuthViewState();
}

class _GelbooruAuthViewState extends ConsumerState<GelbooruV2AuthView> {
  late final loginController = TextEditingController(
    text: ref.read(
      editBooruConfigProvider(ref.read(editBooruConfigIdProvider))
          .select((value) => value.login),
    ),
  );
  late final apiKeyController = TextEditingController(
    text: ref.read(
      editBooruConfigProvider(ref.read(editBooruConfigIdProvider))
          .select((value) => value.apiKey),
    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          const DefaultBooruInstructionText(
            '*Log in to your account on the browser, visit My Account > Options > API Access Credentials. Check if it is there. If not, the site does not support credentials, and you can ignore this.',
          ),
        ],
      ),
    );
  }
}

class GelbooruV2AuthRequiredAuthView extends ConsumerStatefulWidget {
  const GelbooruV2AuthRequiredAuthView({super.key});

  @override
  ConsumerState<GelbooruV2AuthRequiredAuthView> createState() =>
      _GelbooruV2AuthRequiredAuthViewState();
}

class _GelbooruV2AuthRequiredAuthViewState
    extends ConsumerState<GelbooruV2AuthRequiredAuthView> {
  late final loginController = TextEditingController(
    text: ref.read(
      editBooruConfigProvider(ref.read(editBooruConfigIdProvider))
          .select((value) => value.login),
    ),
  );
  late final apiKeyController = TextEditingController(
    text: ref.read(
      editBooruConfigProvider(ref.read(editBooruConfigIdProvider))
          .select((value) => value.apiKey),
    ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
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
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.hintColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
              children: [
                const TextSpan(
                  text: '*Log in to your account in the browser and visit ',
                ),
                TextSpan(
                  text: 'My Account > Options > API Access Credentials',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchExternalUrlString(
                        'https://rule34.xxx/index.php?page=account&s=options',
                      );
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(
                  text:
                      '. If you see empty API key like "&api_key=&user_id=<your_id>", tick "Generate New Key?" and click the "Save" button at the very bottom to generate a new API key. Otherwise, copy the key and paste it into the field above. You can also copy the whole string from the "API Access Credentials" section and choose "Paste from clipboard" button below.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 4),
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
