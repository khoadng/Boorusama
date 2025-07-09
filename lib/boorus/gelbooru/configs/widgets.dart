// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/configs/gesture/gesture.dart';
import '../../../core/configs/gesture/widgets.dart';
import '../../../core/configs/search/widgets.dart';
import '../../../core/configs/viewer/widgets.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../foundation/toast.dart';
import '../../../foundation/url_launcher.dart';
import '../gelbooru.dart';
import '_internal_widgets.dart';
import 'api_key_verify_dialog.dart';

class CreateGelbooruConfigPage extends ConsumerWidget {
  const CreateGelbooruConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      backgroundColor: backgroundColor,
      initialTab: initialTab,
      authTab: const GelbooruAuthView(),
      gestureTab: BooruConfigGesturesView(
        postDetailsGestureActions: const {
          ...kDefaultGestureActions,
          kToggleFavoriteAction,
        },
        describePostDetailsAction: (action) => switch (action) {
          kToggleFavoriteAction => 'Toggle favorite',
          _ => describeDefaultGestureAction(action),
        },
      ),
      searchTab: const DefaultBooruConfigSearchView(
        hasRatingFilter: true,
      ),
      imageViewerTab: const BooruConfigViewerView(
        autoLoadNotes: DefaultAutoFetchNotesSwitch(),
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
    text: ref.read(
      editBooruConfigProvider(
        ref.read(editBooruConfigIdProvider),
      ).select((value) => value.login),
    ),
  );
  late final apiKeyController = TextEditingController(
    text: ref.read(
      editBooruConfigProvider(
        ref.read(editBooruConfigIdProvider),
      ).select((value) => value.apiKey),
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
    final config = ref.watch(initialBooruConfigProvider);
    final passHash = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.passHash),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Basic Auth (required)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              _VerifyApiKeyButton(
                loginController: loginController,
                apiKeyController: apiKeyController,
                config: config,
              ),
            ],
          ),
          Text(
            'Providing this information gives the app read access to your account. This is required by Gelbooru as of 06/2025.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
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
                  text: '*Log in to your account in the browser, visit ',
                ),
                TextSpan(
                  text: 'My Account > Options > API Access Credentials',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launchExternalUrlString(
                        getGelbooruProfileUrl(config.url),
                      );
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const TextSpan(
                  text: ' and fill in the values manually.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Advanced Auth (optional)',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Providing this information allows you to edit your favorites and provides write access to your account. Note that if you change your password, you will need to log in again.',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (passHash == null)
            _buildLoginButton(context, config: config)
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildLoginStatus(config),
                const SizedBox(height: 8),
                WarningContainer(
                  margin: EdgeInsets.zero,
                  title: 'About the heart button state'.hc,
                  contentBuilder: (context) => Text(
                    "There is no way to check if an image has already been favorited. Although you can see the visual indicator after favoriting an image, it will reset when you restart the app. Don't worry, your favorites are still saved on the website."
                        .hc,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildLoginStatus(
    BooruConfig config,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Logged in'.hc,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              RawChip(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                onPressed: () {
                  _openBrowser(config);
                },
                label: Text('Update'.hc),
              ),
              const SizedBox(width: 8),
              RawChip(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                onPressed: () {
                  ref.editNotifier.updatePassHash(null);
                },
                label: Text('Clear'.hc),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openBrowser(BooruConfig config) {
    final loginUrl = ref.read(gelbooruProvider).getLoginUrl();

    if (loginUrl == null) {
      showErrorToast(context, 'Login URL for this booru is not available');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'cookie_access_web_view'),
        builder: (context) => CookieAccessWebViewPage(
          url: loginUrl,
          onGet: (cookies) {
            if (cookies.isNotEmpty) {
              final pashHash = cookies.firstWhereOrNull(
                (e) => e.name == 'pass_hash',
              );
              final uid = cookies.firstWhereOrNull((e) => e.name == 'user_id');

              if (pashHash != null) {
                ref.editNotifier.updatePassHash(
                  pashHash.value,
                );
                if (uid != null) {
                  ref.editNotifier.updateLogin(uid.value);
                  loginController.text = uid.value;
                }
              } else {
                showErrorToast(context, 'No hashed password found');
              }

              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    BuildContext context, {
    required BooruConfig config,
    String? title,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            onPressed: () {
              _openBrowser(config);
            },
            child: Text(
              title ?? 'Login with Browser',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerifyApiKeyButton extends StatelessWidget {
  const _VerifyApiKeyButton({
    required this.loginController,
    required this.apiKeyController,
    required this.config,
  });

  final TextEditingController loginController;
  final TextEditingController apiKeyController;
  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return MultiValueListenableBuilder2(
      first: loginController,
      second: apiKeyController,
      builder: (context, login, apiKey) {
        final isEnabled = login.text.isNotEmpty && apiKey.text.isNotEmpty;
        final colorScheme = Theme.of(context).colorScheme;

        return GestureDetector(
          onTap: isEnabled
              ? () {
                  showAdaptiveDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => ApiKeyVerifyDialog(
                      login: login.text,
                      apiKey: apiKey.text,
                      config: config,
                    ),
                  );
                }
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isEnabled
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
            ),
            child: Text(
              'Verify',
              style: TextStyle(
                fontWeight: isEnabled ? FontWeight.w600 : FontWeight.w500,
                color: isEnabled
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
        );
      },
    );
  }
}
