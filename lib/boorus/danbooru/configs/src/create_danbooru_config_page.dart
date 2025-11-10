// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../core/configs/auth/widgets.dart';
import '../../../../core/configs/config/types.dart';
import '../../../../core/configs/create/create.dart';
import '../../../../core/configs/create/providers.dart';
import '../../../../core/configs/create/widgets.dart';
import '../../../../core/configs/gesture/types.dart';
import '../../../../core/configs/gesture/widgets.dart';
import '../../../../core/configs/search/widgets.dart';
import '../../../../core/configs/viewer/widgets.dart';
import '../../../../foundation/url_launcher.dart';
import '../../users/user/types.dart';
import 'hide_deleted_switch.dart';
import 'providers.dart';

const _kDanbooruSpecificGestureActions = {
  kToggleFavoriteAction,
  kUpvoteAction,
  kDownvoteAction,
  kEditAction,
};

const _kDanbooruPreviewGestureActions = {
  ...kDefaultGestureActions,
  ..._kDanbooruSpecificGestureActions,
};

const _kDanbooruFullviewGestureActions = {
  ...kDefaultFullviewActions,
  ..._kDanbooruSpecificGestureActions,
};

class CreateDanbooruConfigPage extends ConsumerWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    this.initialTab,
  });

  final Color? backgroundColor;
  final String? initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final loginDetails = ref.watch(danbooruLoginDetailsProvider(config.auth));

    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: DefaultBooruAuthConfigView(
        showInstructionWhen: !loginDetails.hasStrictSFW,
        customInstruction: DefaultBooruInstructionHtmlText(
          context.t.booru.api_key_instructions.variants_3,
          onApiLinkTap: () {
            launchExternalUrlString(getDanbooruProfileUrl(config.url));
          },
        ),
      ),
      gestureTab: BooruConfigGesturesView(
        previewGestureActions: _kDanbooruPreviewGestureActions,
        fullviewGestureActions: _kDanbooruFullviewGestureActions,
        describePostDetailsAction: (action) => switch (action) {
          kToggleFavoriteAction => context.t.post.action.toggle_favorite,
          kUpvoteAction => context.t.post.action.upvote,
          kDownvoteAction => context.t.post.action.downvote,
          kEditAction => context.t.post.action.edit,
          _ => describeDefaultGestureAction(action, context),
        },
      ),
      imageViewerTab: const BooruConfigViewerView(
        postDetailsResolution: DanbooruImageDetailsQualityProvider(),
        autoLoadNotes: DefaultAutoFetchNotesSwitch(),
      ),
      searchTab: BooruConfigSearchView(
        hasRatingFilter: true,
        config: config.auth,
        extras: const [
          DanbooruHideDeletedSwitch(),
          DanbooruHideBannedSwitch(),
        ],
      ),
      canSubmit: validLoginAndApiKey,
    );
  }
}
