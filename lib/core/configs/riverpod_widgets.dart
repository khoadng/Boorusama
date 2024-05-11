// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_passworld_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class DefaultImageDetailsQualityTile extends ConsumerWidget {
  const DefaultImageDetailsQualityTile({
    super.key,
    required this.config,
  });

  final BooruConfig config;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruGeneralPostDetailsResolutionOptionTile(
      value: ref.watch(defaultImageDetailsQualityProvider),
      onChanged: (value) => ref.updateImageDetailsQuality(value),
    );
  }
}

class RawBooruConfigSubmitButton extends ConsumerWidget {
  const RawBooruConfigSubmitButton({
    super.key,
    required this.config,
    required this.data,
    required this.enable,
    this.backgroundColor,
    this.child,
  });

  final bool enable;
  final BooruConfig config;
  final BooruConfigData data;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruSubmitButton(
      backgroundColor: backgroundColor,
      onSubmit: enable
          ? () {
              ref.read(booruConfigProvider.notifier).addOrUpdate(
                    config: config,
                    newConfig: data,
                  );

              context.navigator.pop();
            }
          : null,
      child: child,
    );
  }
}

class DefaultBooruSubmitButton extends ConsumerWidget {
  const DefaultBooruSubmitButton({
    super.key,
    required this.data,
  });

  final BooruConfigData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);

    return RawBooruConfigSubmitButton(
      config: config,
      data: data.copyWith(
        login: auth.login,
        apiKey: auth.apiKey,
      ),
      enable: auth.isValid && config.name.isNotEmpty,
    );
  }
}

class DefaultBooruRatingOptionsTile extends ConsumerWidget {
  const DefaultBooruRatingOptionsTile({
    super.key,
    this.options,
  });

  final Set<Rating>? options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);

    return CreateBooruRatingOptionsTile(
      config: config,
      initialGranularRatingFilters: ref.watch(granularRatingFilterProvider),
      value: ref.watch(ratingFilterProvider),
      onChanged: (value) =>
          value != null ? ref.updateRatingFilter(value) : null,
      onGranularRatingFiltersChanged: (value) =>
          ref.updateGranularRatingFilter(value),
      options: options,
    );
  }
}

class BooruConfigNameField extends ConsumerWidget {
  const BooruConfigNameField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruConfigNameField(
      text: ref.watch(configNameProvider),
      onChanged: (value) => ref.updateName(value),
    );
  }
}

class BooruConfigSubmitButton extends ConsumerWidget {
  const BooruConfigSubmitButton({
    super.key,
    required this.builder,
  });

  final Widget Function(BooruConfigData data) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(booruConfigDataProvider);
    final defaultImageDetailsQuality =
        ref.watch(defaultImageDetailsQualityProvider);
    final ratingFilter = ref.watch(ratingFilterProvider);
    final granularRatingFilter = ref.watch(granularRatingFilterProvider);
    final customDownloadFileNameFormat =
        ref.watch(customDownloadFileNameFormatProvider);
    final customBulkDownloadFileNameFormat =
        ref.watch(customBulkDownloadFileNameFormatProvider);
    final configName = ref.watch(configNameProvider);
    final defaultPreviewImageButtonAction =
        ref.watch(defaultPreviewImageButtonActionProvider);
    final gestures = ref.watch(postGesturesConfigDataProvider);

    return builder(data.copyWith(
      granularRatingFilter: () => granularRatingFilter,
      ratingFilter: ratingFilter,
      imageDetaisQuality: () => defaultImageDetailsQuality,
      customDownloadFileNameFormat: () => customDownloadFileNameFormat,
      customBulkDownloadFileNameFormat: () => customBulkDownloadFileNameFormat,
      defaultPreviewImageButtonAction: () => defaultPreviewImageButtonAction,
      postGestures: () => gestures,
      name: configName,
    ));
  }
}

class DefaultBooruApiKeyField extends ConsumerWidget {
  const DefaultBooruApiKeyField({
    super.key,
    this.hintText,
    this.labelText,
  });

  final String? hintText;
  final String? labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);

    return CreateBooruApiKeyField(
      text: apiKey,
      labelText: labelText,
      hintText: hintText ?? 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
      onChanged: ref.updateApiKey,
    );
  }
}

class DefaultBooruPasswordField extends ConsumerWidget {
  const DefaultBooruPasswordField({
    super.key,
    this.hintText,
  });

  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);

    return CreateBooruPasswordField(
      text: apiKey,
      onChanged: ref.updateApiKey,
    );
  }
}

class DefaultBooruLoginField extends ConsumerWidget {
  const DefaultBooruLoginField({
    super.key,
    this.hintText,
    this.labelText,
  });

  final String? hintText;
  final String? labelText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginProvider);

    return CreateBooruLoginField(
      text: login,
      labelText: labelText ?? 'booru.login_name_label'.tr(),
      hintText: hintText ?? 'e.g: my_login',
      onChanged: ref.updateLogin,
    );
  }
}

class DefaultBooruInstructionText extends StatelessWidget {
  const DefaultBooruInstructionText(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.textTheme.titleSmall?.copyWith(
        color: context.theme.hintColor,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class DefaultBooruAuthConfigView extends ConsumerWidget {
  const DefaultBooruAuthConfigView({
    super.key,
    this.instruction,
    this.showInstructionWhen = true,
  });

  final String? instruction;
  final bool showInstructionWhen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          const DefaultBooruLoginField(),
          const SizedBox(height: 16),
          const DefaultBooruApiKeyField(),
          const SizedBox(height: 8),
          if (showInstructionWhen && instruction != null)
            DefaultBooruInstructionText(
              instruction!,
            ),
        ],
      ),
    );
  }
}
