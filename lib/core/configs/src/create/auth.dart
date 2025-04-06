// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../foundation/toast.dart';
import '../../../theme.dart';
import '../booru_config.dart';
import 'cookie_access_webview_page.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';

class DefaultCookieAuthConfigSection extends ConsumerWidget {
  const DefaultCookieAuthConfigSection({
    required this.loginUrl,
    required this.onGetCookies,
    super.key,
  });

  final String? loginUrl;
  final void Function(List<Cookie> cookies) onGetCookies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final passHash = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.passHash),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Cookie Auth',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Provide this information so the app can access more content. Note that if you change your password or something looks wrong after some time, try to login again.',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
        ),
        if (passHash == null)
          _buildLoginButton(ref, context, config: config)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLoginStatus(ref, context, config),
            ],
          ),
      ],
    );
  }

  Widget _buildLoginStatus(
    WidgetRef ref,
    BuildContext context,
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
                  _openBrowser(ref, context, config);
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

  void _openBrowser(WidgetRef ref, BuildContext context, BooruConfig config) {
    if (loginUrl == null) {
      showErrorToast(context, 'Login URL for this booru is not available');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CookieAccessWebViewPage(
          url: loginUrl!,
          onGet: onGetCookies,
        ),
      ),
    );
  }

  Widget _buildLoginButton(
    WidgetRef ref,
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
              _openBrowser(ref, context, config);
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

class DefaultBooruAuthConfigView extends ConsumerWidget {
  const DefaultBooruAuthConfigView({
    super.key,
    this.instruction,
    this.showInstructionWhen = true,
    this.customInstruction,
  });

  final String? instruction;
  final Widget? customInstruction;
  final bool showInstructionWhen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruLoginField(),
          const SizedBox(height: 16),
          const DefaultBooruApiKeyField(),
          const SizedBox(height: 8),
          if (showInstructionWhen)
            if (customInstruction != null)
              customInstruction!
            else if (instruction != null)
              DefaultBooruInstructionText(
                instruction!,
              )
            else
              const SizedBox.shrink(),
        ],
      ),
    );
  }
}
