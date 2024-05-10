// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/platform.dart';
import 'providers.dart';
import 'widgets.dart';

class CreateDanbooruConfigPage extends StatelessWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
    this.isNewConfig = false,
  });

  final Color? backgroundColor;
  final BooruConfig config;
  final bool isNewConfig;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWith((ref) => config),
      ],
      child: CreateBooruConfigScaffold(
        isNewConfig: isNewConfig,
        backgroundColor: backgroundColor,
        authTab: DefaultBooruAuthConfigView(
          showInstructionWhen: !isApple(),
          instruction:
              '*Log in to your account on the browser, visit My Account > API Key. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
        ),
        hasDownloadTab: true,
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
        tabsBuilder: (context) => {},
        miscOptions: const [
          DanbooruHideDeletedSwitch(),
        ],
        submitButtonBuilder: (data) => DanbooruBooruConfigSubmitButton(
          data: data,
        ),
      ),
    );
  }
}

class DanbooruBooruConfigSubmitButton extends ConsumerWidget {
  const DanbooruBooruConfigSubmitButton({
    super.key,
    required this.data,
  });

  final BooruConfigData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);
    final hideDeleted = ref.watch(hideDeletedProvider(config));
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return DefaultBooruConfigSubmitButton(
      config: config,
      dataBuilder: () => data.copyWith(
        login: auth.login,
        apiKey: auth.apiKey,
        deletedItemBehavior: hideDeleted
            ? BooruConfigDeletedItemBehavior.hide
            : BooruConfigDeletedItemBehavior.show,
        imageDetaisQuality: () => imageDetailsQuality,
      ),
      enable: auth.isValid,
    );
  }
}
