// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../core/boorus/booru/booru.dart';
import '../../../core/boorus/booru/providers.dart';
import '../../../core/configs/config.dart';
import '../../../core/configs/create.dart';
import '../../../core/foundation/toast.dart';
import '../../../core/foundation/url_launcher.dart';
import '../../../core/theme.dart';
import '../../../core/widgets/widgets.dart';
import '../gelbooru.dart';
import 'widgets.dart';

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
      searchTab: const DefaultBooruConfigSearchView(
        hasRatingFilter: true,
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
    final config = ref.watch(initialBooruConfigProvider);
    final passHash = ref.watch(
      editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
          .select((value) => value.passHash),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Basic Auth',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provide this information to view your favorites. This only provides read access to your account.',
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
                  text: '*Log in to your account on the browser, visit ',
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
                  text: ' and fill the values manually.',
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
            'Advanced Auth',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.hintColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provide this information allows you to edit your favorites. This provides write access to your account. Note that if you change your password, you need to log in again.',
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
                  title: "About the heart button's state",
                  contentBuilder: (context) => const Text(
                    "There is no way to check if an image has already been favorited. Although you can see the visual indicator after you've favorited an image, it will lose its state if you restart the app. Don't worry, your favorites are still there on the website.",
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
          const Text(
            'Logged in',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              RawChip(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                onPressed: () {
                  _openBrowser(config);
                },
                label: const Text('Update'),
              ),
              const SizedBox(width: 8),
              RawChip(
                backgroundColor:
                    Theme.of(context).colorScheme.secondaryContainer,
                onPressed: () {
                  ref.editNotifier.updatePassHash(null);
                },
                label: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openBrowser(BooruConfig config) {
    final loginUrl = ref.read(booruProvider(config.auth))?.getLoginUrl();

    if (loginUrl == null) {
      showErrorToast(context, 'Login URL for this booru is not available');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CookieAccessWebViewPage(
          url: loginUrl,
          onGet: (cookies) {
            if (cookies.isNotEmpty) {
              final pashHash =
                  cookies.firstWhereOrNull((e) => e.name == 'pass_hash');
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
