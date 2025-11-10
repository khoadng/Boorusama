// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
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
import '../gelbooru.dart';
import '_internal_widgets.dart';
import 'api_key_verify_dialog.dart';

const _kGelbooruSpecificGestureActions = {
  kToggleFavoriteAction,
};

const _kGelbooruPreviewGestureActions = {
  ...kDefaultGestureActions,
  ..._kGelbooruSpecificGestureActions,
};

const _kGelbooruFullviewGestureActions = {
  ...kDefaultFullviewActions,
  ..._kGelbooruSpecificGestureActions,
};

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
        previewGestureActions: _kGelbooruPreviewGestureActions,
        fullviewGestureActions: _kGelbooruFullviewGestureActions,
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
          BasicAuthSection(
            titleText: context.t.booru.authentication.gelbooru.basic_auth,
            descriptionText:
                context.t.booru.authentication.gelbooru.basic_auth_description,
            loginController: loginController,
            apiKeyController: apiKeyController,
            loginField: GelbooruLoginField(
              controller: loginController,
            ),
            apiKeyField: GelbooruApiKeyField(
              controller: apiKeyController,
            ),
            instructionsText: context.t.booru.api_key_instructions.variants_5,
            apiKeyUrl: getGelbooruProfileUrl(config.url),
            pasteButton: GelbooruConfigPasteFromClipboardButton(
              login: loginController,
              apiKey: apiKeyController,
            ),
            verifyButton: VerifyApiKeyButton(
              loginController: loginController,
              apiKeyController: apiKeyController,
              onVerify: () {
                showAdaptiveDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => ApiKeyVerifyDialog(
                    login: loginController.text,
                    apiKey: apiKeyController.text,
                    config: config,
                  ),
                );
              },
            ),
          ),
          AdvancedAuthSection(
            loginController: loginController,
            getLoginUrl: () => ref.read(gelbooruProvider).getLoginUrl(),
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
