// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/scaffolds/create_booru_config_scaffold2.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
        authTab: const DanbooruAuthConfigView(),
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
    final gestures = ref.watch(postGesturesConfigDataProvider);
    final hideDeleted = ref.watch(hideDeletedProvider(config));
    final imageDetailsQuality = ref.watch(imageDetailsQualityProvider(config));

    return DefaultBooruConfigSubmitButton(
      config: config,
      dataBuilder: () => data.copyWith(
        login: auth.login,
        apiKey: auth.apiKey,
        postGestures: () => gestures,
        deletedItemBehavior: hideDeleted
            ? BooruConfigDeletedItemBehavior.hide
            : BooruConfigDeletedItemBehavior.show,
        imageDetaisQuality: () => imageDetailsQuality,
      ),
      enable: auth.isValid,
    );
  }
}

class DanbooruAuthConfigView extends ConsumerWidget {
  const DanbooruAuthConfigView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DanbooruLoginField(),
          const SizedBox(height: 16),
          const DanbooruApiKeyField(),
          const SizedBox(height: 8),
          if (!isApple())
            Text(
              '*Log in to your account on the browser, visit My Account > API Key. Copy your key or create a new one if needed, ensuring all permissions are enabled for proper app functionality.',
              style: context.textTheme.titleSmall?.copyWith(
                color: context.theme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
