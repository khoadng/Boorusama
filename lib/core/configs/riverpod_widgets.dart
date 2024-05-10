// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_config_name_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_post_details_resolution_option_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'providers.dart';

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

class DefaultBooruConfigSubmitButton extends ConsumerWidget {
  const DefaultBooruConfigSubmitButton({
    super.key,
    required this.config,
    required this.dataBuilder,
    required this.enable,
  });

  final bool enable;
  final BooruConfig config;
  final BooruConfigData Function() dataBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CreateBooruSubmitButton(
      onSubmit: enable
          ? () {
              final data = dataBuilder();

              ref
                  .read(booruConfigProvider.notifier)
                  .addOrUpdateUsingBooruConfigData(
                    config: config,
                    newConfig: data,
                  );

              context.navigator.pop();
            }
          : null,
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
  });

  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);

    return CreateBooruApiKeyField(
      text: apiKey,
      hintText: hintText ?? 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
      onChanged: ref.updateApiKey,
    );
  }
}

class DefaultBooruLoginField extends ConsumerWidget {
  const DefaultBooruLoginField({
    super.key,
    this.hintText,
  });

  final String? hintText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final login = ref.watch(loginProvider);

    return CreateBooruLoginField(
      text: login,
      labelText: 'booru.login_name_label'.tr(),
      hintText: hintText ?? 'e.g: my_login',
      onChanged: ref.updateLogin,
    );
  }
}

class DefaultBooruWarningText extends StatelessWidget {
  const DefaultBooruWarningText(
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
