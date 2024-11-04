// Flutter imports:
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'widgets.dart';

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
        showInstructionWhen: !config.hasStrictSFW,
        customInstruction: RichText(
          text: TextSpan(
            style: context.textTheme.titleSmall?.copyWith(
              color: Theme.of(context).hintColor,
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
                  color: context.colorScheme.primary,
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
      hasRatingFilter: true,
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
      postDetailsResolution: const DanbooruImageDetailsQualityProvider(),
      miscOptions: const [
        DanbooruHideDeletedSwitch(),
        DanbooruHideBannedSwitch(),
      ],
      submitButton: const DanbooruBooruConfigSubmitButton(),
    );
  }
}

class DanbooruBooruConfigSubmitButton extends ConsumerWidget {
  const DanbooruBooruConfigSubmitButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);
    final auth = ref.watch(editBooruConfigProvider(editId)
        .select((value) => AuthConfigData.fromConfig(value)));

    return RawBooruConfigSubmitButton(
      enable: auth.isValid,
    );
  }
}
