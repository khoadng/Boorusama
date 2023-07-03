// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_site_url_field.dart';
import 'package:boorusama/boorus/core/pages/boorus/widgets/create_booru_submit_button.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/widgets/widgets.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    required this.url,
  });

  final bool setCurrentBooruOnSubmit;
  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);
    final allowSubmit = ref.watch(booruAllowSubmitProvider);

    return GestureDetector(
      onTap: () => context.focusScope.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: context.navigator.pop,
            icon: const Icon(Icons.close),
          ),
        ),
        body: SingleChildScrollView(
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
              WarningContainer(
                  contentBuilder: (context) => const Text(
                        'booru.add_random_booru_warning',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ).tr()),
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
                  trailing: OptionDropDownButton<BooruEngine?>(
                    value: engine,
                    onChanged: (value) {
                      ref.read(booruEngineProvider.notifier).state = value;
                    },
                    items: BooruEngine.values
                        .map((value) => DropdownMenuItem<BooruEngine>(
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
                      onChanged: (value) => ref
                          .read(booruConfigNameProvider.notifier)
                          .state = value,
                      labelText: 'booru.config_name_label'.tr(),
                    ),
                    const SizedBox(height: 16),
                    CreateBooruSiteUrlField(
                      text: url,
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
                        ref.read(booruRatingFilterProvider.notifier).state =
                            value;
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
        ),
      ),
    );
  }
}
