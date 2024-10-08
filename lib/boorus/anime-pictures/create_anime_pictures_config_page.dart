// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/configs/gelbooru_login_webview_page.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/toast.dart';

class CreateAnimePicturesConfigPage extends ConsumerWidget {
  const CreateAnimePicturesConfigPage({
    super.key,
    required this.config,
    this.backgroundColor,
    this.isNewConfig = false,
    this.initialTab,
  });

  final BooruConfig config;
  final Color? backgroundColor;
  final bool isNewConfig;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        initialTab: initialTab,
        authTab: AnimePicturesAuthView(),
        footer: isNewConfig
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: context.theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Symbols.info,
                      size: 16,
                      color: context.theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        "Bulk download and blacklist won't work for this booru.",
                        style: context.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }
}

class AnimePicturesAuthView extends ConsumerStatefulWidget {
  const AnimePicturesAuthView({super.key});

  @override
  ConsumerState<AnimePicturesAuthView> createState() =>
      _AnimePicturesAuthViewState();
}

class _AnimePicturesAuthViewState extends ConsumerState<AnimePicturesAuthView> {
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
            'Cookie Auth',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Provide this information so the app can access more content. Note that if you change your password or something looks wrong after some time, try to login again.',
            style: context.textTheme.titleSmall?.copyWith(
              color: context.theme.hintColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          ref.watch(authConfigDataProvider).passHash == null
              ? _buildLoginButton(context, config: config)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildLoginStatus(config),
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
                backgroundColor: context.colorScheme.secondaryContainer,
                onPressed: () {
                  _openBrowser(config);
                },
                label: const Text('Update'),
              ),
              const SizedBox(width: 8),
              RawChip(
                backgroundColor: context.colorScheme.secondaryContainer,
                onPressed: () {
                  ref.updatePassHash(null);
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
    final loginUrl = ref.read(booruProvider(config))?.getLoginUrl();

    if (loginUrl == null) {
      showErrorToast(context, 'Login URL for this booru is not available');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GelbooruLoginPage(
          url: loginUrl,
          onGet: (cookies) {
            if (cookies.isNotEmpty) {
              final filtered = cookies
                  .where((e) => e.name != 'animepictures_gdpr')
                  .where((e) => e.name != 'cf_clearance')
                  .where((e) => !e.name.startsWith('_ga'))
                  .toList();

              final cookiesString = filtered
                  .toSet()
                  .map((e) => '${e.name}=${e.value}')
                  .join('; ');

              ref.updatePassHash(cookiesString);

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
              backgroundColor: context.colorScheme.secondaryContainer,
            ),
            onPressed: () {
              _openBrowser(config);
            },
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
