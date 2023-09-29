// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_site_url_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
    required this.url,
  });

  final bool setCurrentBooruOnSubmit;
  final String url;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Material(
        color: backgroundColor,
        child: Stack(
          children: [
            _buildBody(context, ref),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: context.navigator.pop,
                icon: const Icon(Icons.close),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
  ) {
    final engine = ref.watch(booruEngineProvider);
    final allowSubmit = ref.watch(booruAllowSubmitProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            child: Text(
              'booru.add_booru_source_title',
              style: context.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w900),
            ).tr(),
          ),
          const SizedBox(height: 8),
          const Divider(
            thickness: 2,
            endIndent: 16,
            indent: 16,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: ListTile(
              title: const Text('booru.booru_engine_input_label').tr(),
              trailing: OptionDropDownButton(
                value: engine,
                onChanged: (value) {
                  ref.read(booruEngineProvider.notifier).state = value;
                },
                items: BooruType.values
                    .where((e) => e != BooruType.unknown)
                    .sorted((a, b) => a.stringify().compareTo(b.stringify()))
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.stringify()),
                        ))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CreateBooruLoginField(
                  onChanged: (value) =>
                      ref.read(booruConfigNameProvider.notifier).state = value,
                  labelText: 'booru.config_name_label'.tr(),
                ),
                const SizedBox(height: 16),
                CreateBooruSiteUrlField(
                  text: url,
                ),
                const SizedBox(height: 16),
                Text(
                  'Advanced options (optional)',
                  style: context.textTheme.titleMedium,
                ),
                Text(
                  '*These options only be used if the site allows it.',
                  style: context.textTheme.titleSmall!.copyWith(
                    color: context.theme.hintColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),
                CreateBooruLoginField(
                  labelText: 'booru.login_name_label'.tr(),
                  onChanged: (value) =>
                      ref.read(booruLoginProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),
                CreateBooruApiKeyField(
                  onChanged: (value) =>
                      ref.read(booruApiKeyProvider.notifier).state = value,
                ),
                const SizedBox(height: 16),
                CreateBooruRatingOptionsTile(
                  onChanged: (value) {
                    if (value == null) return;
                    ref.read(booruRatingFilterProvider.notifier).state = value;
                  },
                ),
                const SizedBox(height: 16),
                CreateBooruSubmitButton(
                  onSubmit: allowSubmit
                      ? () {
                          context.navigator.pop();
                          ref
                              .read(booruConfigProvider.notifier)
                              .addFromAddBooruConfig(
                                newConfig:
                                    ref.read(newbooruConfigProvider(url)),
                                setAsCurrent: setCurrentBooruOnSubmit,
                              );
                        }
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
