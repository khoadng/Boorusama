// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:booru_clients/core.dart' as c;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../core/configs/auth/widgets.dart';
import '../../../core/configs/create/providers.dart';
import '../../../core/configs/create/widgets.dart';
import '../../../core/configs/search/widgets.dart';
import '../../../core/configs/viewer/widgets.dart';
import '../../../foundation/url_launcher.dart';
import '../../gelbooru/configs/_internal_widgets.dart';
import 'internal_widgets.dart';

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
      authTab: GelbooruV2AuthView(
        authConfig: c.GelbooruV2Config.siteCapabilities(url)?.auth,
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

class GelbooruV2AuthView extends ConsumerStatefulWidget {
  const GelbooruV2AuthView({
    this.authConfig,
    super.key,
  });

  final c.AuthConfig? authConfig;

  @override
  ConsumerState<GelbooruV2AuthView> createState() => _GelbooruAuthViewState();
}

class _GelbooruAuthViewState extends ConsumerState<GelbooruV2AuthView> {
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
    final authConfig = widget.authConfig;
    final instructionsText = switch (authConfig?.instructionsKey) {
      final String key when key.isNotEmpty => context.t[key],
      _ => context.t.booru.api_key_instructions.variants_2,
    };
    final hasAuthConfig = authConfig != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          GelbooruV2LoginField(
            controller: loginController,
          ),
          const SizedBox(height: 16),
          GelbooruV2ApiKeyField(
            controller: apiKeyController,
          ),
          const SizedBox(height: 8),
          DefaultBooruInstructionHtmlText(
            instructionsText,
            onApiLinkTap: switch (authConfig?.apiKeyUrl) {
              final String apiKeyUrl when apiKeyUrl.isNotEmpty => () {
                launchExternalUrlString(apiKeyUrl);
              },
              _ => null,
            },
          ),

          if (hasAuthConfig) ...[
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
          ],
        ],
      ),
    );
  }
}
