// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/shimmie2.dart';
import 'package:coreutils/coreutils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/config/types.dart';
import '../../../core/configs/create/create.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/configs/network/widgets.dart';
import '../../../core/widgets/booru_version_chip.dart';
import '../../../foundation/html.dart';
import '../../../foundation/path.dart';
import '../extensions/providers.dart';

class CreateShimmie2ConfigPage extends ConsumerWidget {
  const CreateShimmie2ConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: const Shimmie2AuthConfigView(),
      version: ref
          .watch(
            shimmie2VersionProvider(
              ref.watch(initialBooruConfigProvider).url,
            ),
          )
          .maybeWhen(
            data: (version) => version != null
                ? BooruVersionChip(
                    version: version,
                  )
                : null,
            orElse: () => null,
          ),
      canSubmit: alwaysSubmit,
    );
  }
}

class Shimmie2AuthConfigView extends ConsumerStatefulWidget {
  const Shimmie2AuthConfigView({
    super.key,
  });

  @override
  ConsumerState<Shimmie2AuthConfigView> createState() =>
      _Shimmie2AuthConfigViewState();
}

class _Shimmie2AuthConfigViewState
    extends ConsumerState<Shimmie2AuthConfigView> {
  late final loginController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    loginController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(initialBooruConfigProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruLoginField(),
          const SizedBox(height: 16),
          const DefaultBooruApiKeyField(
            hintText: 'e.g: AC8gZrxKsDpWy3unU0jB',
          ),
          const Shimmie2UserApiKeyExtDisclaimer(),
          _ViewDocsButton(config: config),
          AdvancedAuthSection(
            loginController: loginController,
            getLoginUrl: () => join(config.url, 'user_admin', 'login'),
            onGetCookies: (cookies) {
              if (cookies.isEmpty) return;

              final cookieList = cookies.cast<Cookie>();

              final filtered = cookieList
                  .where(
                    (e) =>
                        e.name == Shimmie2Cookies.username ||
                        e.name == Shimmie2Cookies.session,
                  )
                  .toList();

              if (filtered.isEmpty) return;

              final cookiesString = filtered.cookieMap.entries
                  .map((e) => '${e.key}=${e.value}')
                  .join('; ');

              final username = filtered.getCookieValue(
                Shimmie2Cookies.username,
              );

              ref.editNotifier.updatePassHash(cookiesString);

              if (username != null && username.isNotEmpty) {
                ref.editNotifier.updateLogin(username);
              }
            },
          ),
        ],
      ),
    );
  }
}

class Shimmie2UserApiKeyExtDisclaimer extends StatelessWidget {
  const Shimmie2UserApiKeyExtDisclaimer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final style = AppHtml.hintStyle(colorScheme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: AppHtml(
        data: context.t.booru.api_key_instructions.shimmie2.user_api_key_notice,
        style: {
          ...style,
          'b': style['b']!.copyWith(textDecoration: TextDecoration.none),
        },
      ),
    );
  }
}

class Shimmie2BooruUrlField extends ConsumerWidget {
  const Shimmie2BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final editId = ref.watch(editBooruConfigIdProvider);
    final notifier = ref.watch(editBooruConfigProvider(editId).notifier);
    final style = AppHtml.hintStyle(colorScheme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateBooruSiteUrlField(
          text: config.url,
          onChanged: (value) => notifier.updateUrl(value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          child: AppHtml(
            data: context
                .t
                .booru
                .api_key_instructions
                .shimmie2
                .danbooru_api_extension_notice,
            style: {
              ...style,
              'b': style['b']!.copyWith(textDecoration: TextDecoration.none),
            },
          ),
        ),
        _ViewDocsButton(config: config),
      ],
    );
  }
}

class _ViewDocsButton extends StatelessWidget {
  const _ViewDocsButton({
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
        ),
      ),
      onPressed: () {
        launchUrlString(join(config.url, 'ext_doc'));
      },
      child: Text(
        context.t.booru.api_key_instructions.shimmie2.view_extension_docs,
      ),
    );
  }
}

class Shimmie2UnknownBooruWidgetsBuilder extends StatelessWidget {
  const Shimmie2UnknownBooruWidgetsBuilder({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const UnknownBooruWidgetsBuilder(
      urlField: Shimmie2BooruUrlField(),
      httpProtocolField: HttpProtocolOptionTile(),
      loginField: DefaultBooruLoginField(),
      apiKeyField: Column(
        children: [
          DefaultBooruApiKeyField(),
        ],
      ),
    );
  }
}
