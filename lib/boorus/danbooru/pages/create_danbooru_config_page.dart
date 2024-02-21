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
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/custom_download_file_name_section.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class CreateDanbooruConfigPage extends ConsumerStatefulWidget {
  const CreateDanbooruConfigPage({
    super.key,
    this.backgroundColor,
    required this.config,
  });

  final Color? backgroundColor;
  final BooruConfig config;

  @override
  ConsumerState<CreateDanbooruConfigPage> createState() =>
      _CreateDanbooruConfigPageState();
}

class _CreateDanbooruConfigPageState
    extends ConsumerState<CreateDanbooruConfigPage> {
  late var login = widget.config.login ?? '';
  late var apiKey = widget.config.apiKey ?? '';
  late var ratingFilter = widget.config.ratingFilter;
  late var hideDeleted =
      widget.config.deletedItemBehavior == BooruConfigDeletedItemBehavior.hide;
  late String? customDownloadFileNameFormat =
      widget.config.customDownloadFileNameFormat;
  late var customBulkDownloadFileNameFormat =
      widget.config.customBulkDownloadFileNameFormat;
  late var imageDetaisQuality = widget.config.imageDetaisQuality;
  late var granularRatingFilters = widget.config.granularRatingFilters;

  @override
  Widget build(BuildContext context) {
    return CreateBooruConfigScaffold(
      backgroundColor: widget.backgroundColor,
      config: widget.config,
      tabsBuilder: (context) => {
        'Authentication': _buildAuthTab(),
        'Download': _buildDownloadTab(),
        'Misc': _buildMiscTab(),
      },
      allowSubmit: allowSubmit,
      submit: submit,
    );
  }

  Widget _buildMiscTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          CreateBooruRatingOptionsTile(
            config: widget.config,
            initialGranularRatingFilters: granularRatingFilters,
            value: ratingFilter,
            onChanged: (value) =>
                value != null ? setState(() => ratingFilter = value) : null,
            onGranularRatingFiltersChanged: (value) =>
                setState(() => granularRatingFilters = value),
          ),
          const SizedBox(height: 16),
          CreateBooruImageDetailsResolutionOptionTile(
            value: imageDetaisQuality,
            items: PostQualityType.values.map((e) => e.stringify()).toList(),
            onChanged: (value) => setState(() => imageDetaisQuality = value),
          ),
          const SizedBox(height: 16),
          CreateBooruHideDeletedSwitch(
              value: hideDeleted,
              onChanged: (value) => setState(() => hideDeleted = value),
              subtitle: const Text(
                'Hide low-quality images, some decent ones might also be hidden.',
              )),
        ],
      ),
    );
  }

  Widget _buildDownloadTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomDownloadFileNameSection(
            config: widget.config,
            format: customDownloadFileNameFormat,
            onIndividualDownloadChanged: (value) =>
                setState(() => customDownloadFileNameFormat = value),
            onBulkDownloadChanged: (value) =>
                setState(() => customBulkDownloadFileNameFormat = value),
          ),
        ],
      ),
    );
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
              style: context.textTheme.titleSmall!.copyWith(
                color: context.theme.hintColor,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }

  void submit(CreateConfigData data) {
    final config = AddNewBooruConfig(
      login: login,
      apiKey: apiKey,
      booru: widget.config.booruType,
      booruHint: widget.config.booruType,
      configName: data.configName,
      hideDeleted: hideDeleted,
      ratingFilter: ratingFilter,
      url: widget.config.url,
      customDownloadFileNameFormat: customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: customBulkDownloadFileNameFormat,
      imageDetaisQuality: imageDetaisQuality,
      granularRatingFilters: granularRatingFilters,
    );

    ref
        .read(booruConfigProvider.notifier)
        .addOrUpdate(config: widget.config, newConfig: config);

    context.navigator.pop();
  }

  bool allowSubmit(CreateConfigData data) {
    if (data.configName.isEmpty) return false;

    return (login.isNotEmpty && apiKey.isNotEmpty) ||
        (login.isEmpty && apiKey.isEmpty);
  }
}
