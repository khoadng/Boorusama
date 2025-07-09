// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/configs/auth/widgets.dart';
import '../../../../core/configs/config.dart';
import '../../../../core/configs/create/create.dart';
import '../../../../core/configs/create/providers.dart';
import '../../../../core/configs/create/widgets.dart';
import '../../../../core/configs/gesture/gesture.dart';
import '../../../../core/configs/gesture/widgets.dart';
import '../../../../core/configs/search/widgets.dart';
import '../../../../core/configs/viewer/widgets.dart';
import '../../../../core/theme.dart';
import '../../../../foundation/url_launcher.dart';
import '../../users/user/user.dart';
import 'hide_deleted_switch.dart';

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

    return CreateBooruConfigScaffold(
      initialTab: initialTab,
      backgroundColor: backgroundColor,
      authTab: DefaultBooruAuthConfigView(
        showInstructionWhen: !config.auth.hasStrictSFW,
        customInstruction: RichText(
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
                text: 'My Account > API Key',
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchExternalUrlString(getDanbooruProfileUrl(config.url));
                  },
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const TextSpan(
                text:
                    '. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
              ),
            ],
          ),
        ),
      ),
      gestureTab: BooruConfigGesturesView(
        postDetailsGestureActions: const {
          ...kDefaultGestureActions,
          kToggleFavoriteAction,
          kUpvoteAction,
          kDownvoteAction,
          kEditAction,
        },
        describePostDetailsAction: (action) => switch (action) {
          kToggleFavoriteAction => 'Toggle favorite',
          kUpvoteAction => 'Upvote',
          kDownvoteAction => 'Downvote',
          kEditAction => 'Edit',
          _ => describeDefaultGestureAction(action),
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
