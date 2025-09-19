// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../../foundation/toast.dart';
import '../../../../theme.dart';
import '../../../../widgets/widgets.dart';
import '../../../config.dart';
import '../../../create/providers.dart';
import '../pages/cookie_access_webview_page.dart';

class AdvancedAuthSection extends ConsumerWidget {
  const AdvancedAuthSection({
    required this.loginController,
    required this.getLoginUrl,
    this.onCookiesReceived,
    super.key,
    this.showWarningContainer = false,
    this.warningTitle,
    this.warningDescription,
  });

  final TextEditingController loginController;
  final String? Function() getLoginUrl;
  final void Function(List<dynamic> cookies)? onCookiesReceived;
  final bool showWarningContainer;
  final String? warningTitle;
  final String? warningDescription;

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
          _buildLoginButton(context, ref, config: config)
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLoginStatus(context, ref, config),
              if (showWarningContainer &&
                  warningTitle != null &&
                  warningDescription != null) ...[
                const SizedBox(height: 8),
                WarningContainer(
                  margin: EdgeInsets.zero,
                  title: warningTitle,
                  contentBuilder: (context) => Text(warningDescription!),
                ),
              ],
            ],
          ),
      ],
    );
  }

  Widget _buildLoginStatus(
    BuildContext context,
    WidgetRef ref,
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
                  _openBrowser(context, ref, config);
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

  void _openBrowser(
    BuildContext context,
    WidgetRef ref,
    BooruConfig config,
  ) {
    final loginUrl = getLoginUrl();

    if (loginUrl == null || loginUrl.isEmpty) {
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
              final passHash = cookies.firstWhereOrNull(
                (e) => e.name == 'pass_hash',
              );
              final uid = cookies.firstWhereOrNull((e) => e.name == 'user_id');

              if (passHash != null) {
                ref.editNotifier.updatePassHash(
                  passHash.value,
                );
                if (uid != null) {
                  ref.editNotifier.updateLogin(uid.value);
                  loginController.text = uid.value;
                }
                onCookiesReceived?.call(cookies);
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
    BuildContext context,
    WidgetRef ref, {
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
              _openBrowser(context, ref, config);
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
