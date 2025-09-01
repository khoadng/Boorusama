// Flutter imports:
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
          _ => describeDefaultGestureAction(action, context),
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
                context.t.booru.authentication.gelbooru.basic_auth,
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
            context.t.booru.authentication.gelbooru.basic_auth_description,
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
          DefaultBooruInstructionHtmlText(
            context.t.booru.api_key_instructions.variants_5,
            onApiLinkTap: () {
              launchExternalUrlString(getGelbooruProfileUrl(config.url));
            },
          ),
          const SizedBox(height: 12),
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
            context.t.booru.authentication.gelbooru.advanced_auth,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.t.booru.authentication.gelbooru.advanced_auth_description,
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
                  title: context
                      .t
                      .booru
                      .authentication
                      .gelbooru
                      .fav_button_tooltip_title,
                  contentBuilder: (context) => Text(
                    context
                        .t
                        .booru
                        .authentication
                        .gelbooru
                        .fav_button_tooltip_description,
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
            context.t.auth.logged_in,
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
                label: Text(
                  context.t.auth.relogin,
                ),
              ),
              const SizedBox(width: 8),
              RawChip(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.secondaryContainer,
                onPressed: () {
                  ref.editNotifier.updatePassHash(null);
                },
                label: Text(
                  context.t.auth.clear_credentials,
                ),
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
              context.t.generic.action.verify,
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
