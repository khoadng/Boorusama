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
import '../../../core/configs/gesture/types.dart';
import '../../../core/configs/gesture/widgets.dart';
import '../../../core/configs/search/widgets.dart';
import '../../../core/configs/viewer/widgets.dart';
import '../../gelbooru/configs/_internal_widgets.dart';
import 'internal_widgets.dart';

const _kGelbooruV2SpecificGestureActions = {
  kToggleFavoriteAction,
};

const _kGelbooruV2PreviewGestureActions = {
  ...kDefaultGestureActions,
  ..._kGelbooruV2SpecificGestureActions,
};

const _kGelbooruV2FullviewGestureActions = {
  ...kDefaultFullviewActions,
  ..._kGelbooruV2SpecificGestureActions,
};

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
        authConfig: c.GelbooruV2Config.siteCapabilities(url).auth,
      ),
      gestureTab: BooruConfigGesturesView(
        previewGestureActions: _kGelbooruV2PreviewGestureActions,
        fullviewGestureActions: _kGelbooruV2FullviewGestureActions,
        describePostDetailsAction: (action) => switch (action) {
          kToggleFavoriteAction => context.t.post.action.toggle_favorite,
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

class GelbooruV2AuthView extends ConsumerStatefulWidget {
  const GelbooruV2AuthView({
    this.authConfig,
    super.key,
  });

  final c.AuthConfig? authConfig;

  @override
  ConsumerState<GelbooruV2AuthView> createState() => _GelbooruV2AuthViewState();
}

class _GelbooruV2AuthViewState extends ConsumerState<GelbooruV2AuthView> {
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
    final passHash = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.passHash),
    );
    final authRequired = authConfig?.required ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BasicAuthSection(
            titleText: authRequired
                ? context.t.booru.authentication.gelbooru.basic_auth
                : null,
            descriptionText: null,
            loginController: loginController,
            apiKeyController: apiKeyController,
            loginField: GelbooruV2LoginField(
              controller: loginController,
            ),
            apiKeyField: GelbooruV2ApiKeyField(
              controller: apiKeyController,
            ),
            instructionsText: instructionsText,
            apiKeyUrl: switch (authConfig?.apiKeyUrl) {
              final String apiKeyUrl when apiKeyUrl.isNotEmpty => apiKeyUrl,
              _ => null,
            },
            pasteButton: authRequired
                ? GelbooruConfigPasteFromClipboardButton(
                    login: loginController,
                    apiKey: apiKeyController,
                  )
                : null,
          ),
          if (authConfig?.loginUrl case final loginUrl?)
            AdvancedAuthSection(
              loginController: loginController,
              getLoginUrl: () => loginUrl,
              showWarningContainer: passHash != null,
              warningTitle: context
                  .t
                  .booru
                  .authentication
                  .gelbooru
                  .fav_button_tooltip_title,
              warningDescription: context
                  .t
                  .booru
                  .authentication
                  .gelbooru
                  .fav_button_tooltip_description,
            ),
        ],
      ),
    );
  }
}
