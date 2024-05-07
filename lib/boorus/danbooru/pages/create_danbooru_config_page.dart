// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_hide_deleted_switch.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateDanbooruConfigPage extends ConsumerStatefulWidget {
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
  ConsumerState<CreateDanbooruConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateDanbooruConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var hideDeleted =
      widget.config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;
  late var imageDetaisQuality = widget.config.imageDetaisQuality;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
        isNewConfig: widget.isNewConfig,
        backgroundColor: widget.backgroundColor,
        config: widget.config,
        authTab: _buildAuthTab(),
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
        postDetailsResolution: CreateBooruImageDetailsResolutionOptionTile(
          value: imageDetaisQuality,
          items: PostQualityType.values.map((e) => e.stringify()).toList(),
          onChanged: (value) => setState(() => imageDetaisQuality = value),
        ),
        tabsBuilder: (context) => {},
        miscOptions: [
          CreateBooruHideDeletedSwitch(
            value: hideDeleted,
            onChanged: (value) => setState(() => hideDeleted = value),
            subtitle: const Text(
              'Hide low-quality images, some decent ones might also be hidden.',
            ),
          ),
        ],
        allowSubmit: allowSubmit,
        submit: null,
        useNewSubmitFlow: true,
        onSubmit: (data) => data.toBooruConfigDataFromInitialConfig(
              config: widget.config,
              login: login,
              apiKey: apiKey,
              hideDeleted: hideDeleted,
            ));
  }

  Widget _buildAuthTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          CreateBooruLoginField(
            text: login,
            labelText: 'booru.login_name_label'.tr(),
            hintText: 'e.g: my_login',
            onChanged: (value) => setState(() => login = value),
          ),
          const SizedBox(height: 16),
          CreateBooruApiKeyField(
            text: apiKey,
            hintText: 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
            onChanged: (value) => setState(() => apiKey = value),
          ),
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

  bool allowSubmit(CreateConfigData data) {
    if (data.configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
