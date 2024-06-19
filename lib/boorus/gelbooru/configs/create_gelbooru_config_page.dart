// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/gelbooru.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/toast.dart';
import 'package:boorusama/widgets/widgets.dart';
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
    final config = ref.watch(initialBooruConfigProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Text(
            'Basic Auth',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provide this information to view your favorites. This only provides read access to your account.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
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
              style: context.textTheme.titleSmall?.copyWith(
                color: context.theme.hintColor,
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
                          getGelbooruProfileUrl(config.url));
                    },
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Advanced Auth',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provide this information allows you to edit your favorites. This provides write access to your account. Note that if you change your password, you need to log in again.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          ref.watch(authConfigDataProvider).passHash == null
              ? _buildLoginButton(context)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: context.colorScheme.primary,
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
                                    context.colorScheme.secondaryContainer,
                                onPressed: _openBrowser,
                                label: const Text('Update'),
                              ),
                              const SizedBox(width: 8),
                              RawChip(
                                backgroundColor:
                                    context.colorScheme.secondaryContainer,
                                onPressed: () {
                                  ref.updatePassHash(null);
                                },
                                label: const Text('Clear'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  void _openBrowser() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GelbooruLoginPage(
          url: 'https://gelbooru.com/index.php?page=account&s=login&code=00',
          onGet: (cookies) {
            if (cookies.isNotEmpty) {
              final pashHash =
                  cookies.firstWhereOrNull((e) => e.name == 'pass_hash');
              final uid = cookies.firstWhereOrNull((e) => e.name == 'user_id');

              if (pashHash != null) {
                ref.updatePassHash(
                  pashHash.value,
                );
                if (uid != null) {
                  ref.updateLogin(uid.value);
                  loginController.text = uid.value;
                }
              } else {
                showErrorToast('No hashed password found');
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
    String? title,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colorScheme.secondaryContainer,
            ),
            onPressed: _openBrowser,
            child: Text(
              title ?? 'Login with Browser',
              style: TextStyle(
                color: context.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GelbooruLoginPage extends StatefulWidget {
  const GelbooruLoginPage({
    super.key,
    required this.url,
    required this.onGet,
  });

  final String url;
  final void Function(List<Cookie> cookies) onGet;

  @override
  State<GelbooruLoginPage> createState() => _GelbooruLoginPageState();
}

class _GelbooruLoginPageState extends State<GelbooruLoginPage> {
  final WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();

    controller.loadRequest(Uri.parse(widget.url));
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          _buildBanner('Press the button below after you logged in.'),
          FilledButton(
            onPressed: () async {
              final cookies =
                  await WebviewCookieManager().getCookies(widget.url);
              widget.onGet(cookies);
            },
            child: const Text('Access Cookie'),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(4)),
        border: Border.all(
          width: 1,
          color: Colors.white,
        ),
      ),
      width: MediaQuery.sizeOf(context).width,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
