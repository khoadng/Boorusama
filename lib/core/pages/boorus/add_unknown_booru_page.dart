// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_api_key_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_login_field.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_rating_options_tile.dart';
import 'package:boorusama/core/pages/boorus/widgets/create_booru_site_url_field.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'widgets/create_booru_config_name_field.dart';

class AddUnknownBooruPage extends ConsumerStatefulWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
    required this.config,
  });

  final bool setCurrentBooruOnSubmit;
  final BooruConfig config;
  final Color? backgroundColor;

  @override
  ConsumerState<AddUnknownBooruPage> createState() =>
      _AddUnknownBooruPageState();
}

class _AddUnknownBooruPageState extends ConsumerState<AddUnknownBooruPage> {
  late BooruConfig config = widget.config;
  Object? error;
  bool? isValidSite;
  bool verifying = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(booruConfigNameProvider.notifier).state = config.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(booruLoginProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          isValidSite = null;
        });
      }
    });

    ref.listen(booruApiKeyProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          isValidSite = null;
        });
      }
    });

    ref.listen(booruEngineProvider, (previous, next) {
      if (previous != next) {
        setState(() {
          isValidSite = null;
        });
      }
    });

    return SafeArea(
      child: Material(
        color: widget.backgroundColor,
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
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Text(
              'Select a booru engine to continue',
              style: context.textTheme.headlineSmall!
                  .copyWith(fontWeight: FontWeight.w900),
            ),
          ),
          const Divider(
            thickness: 2,
            endIndent: 16,
            indent: 16,
          ),
          if (error != null)
            Stack(
              children: [
                WarningContainer(
                    contentBuilder: (context) => Text(
                        'This configuration is invalid. Please check again. \n\nError: $error')),
                Positioned(
                  top: 6,
                  right: 6,
                  child: IconButton(
                    onPressed: () => setState(() {
                      error = null;
                      isValidSite = null;
                    }),
                    icon: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: ListTile(
              title: const Text('booru.booru_engine_input_label').tr(),
              trailing: OptionDropDownButton(
                alignment: AlignmentDirectional.centerStart,
                value: engine,
                onChanged: (value) {
                  ref.read(booruEngineProvider.notifier).state = value;
                },
                items: BooruType.values
                    .where((e) =>
                        e != BooruType.unknown && e != BooruType.gelbooru)
                    .sorted((a, b) => a.stringify().compareTo(b.stringify()))
                    .map((value) => DropdownMenuItem(
                          value: value,
                          child: Text(value.stringify()),
                        ))
                    .toList(),
              ),
            ),
          ),
          CreateBooruConfigNameField(
            text: config.name,
            onChanged: (value) =>
                ref.read(booruConfigNameProvider.notifier).state = value,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CreateBooruSiteUrlField(
                  text: config.url,
                  onChanged: (value) => setState(() {
                    config = config.copyWith(url: value);
                    isValidSite = null;
                  }),
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
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: isValidSite.toOption().fold(
                          () => context.colorScheme.primary,
                          (value) => value ? Colors.green : Colors.red,
                        ),
                  ),
                  onPressed:
                      !allowSubmit || verifying ? null : () => onSubmit(engine),
                  child: verifying
                      ? const Text('Verifying...')
                      : isValidSite ?? false
                          ? const Text('booru.config_booru_confirm').tr()
                          : const Text('Verify'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void onSubmit(BooruType? engine) async {
    if (isValidSite == null) {
      final asyncFuture =
          ref.read(booruSiteValidatorProvider(BooruConfig.defaultConfig(
        booruType: engine!,
        url: config.url,
        customDownloadFileNameFormat: null,
      ).copyWith(
        login: ref.read(booruLoginProvider),
        apiKey: ref.read(booruApiKeyProvider),
      )).future);

      try {
        final value = await asyncFuture;

        if (mounted) {
          setState(() {
            isValidSite = value;
            error = null;
          });
        }
      } catch (err) {
        if (mounted) {
          setState(() {
            isValidSite = null;
            error = err;
          });
        }
      }
    } else if (isValidSite != null && isValidSite!) {
      context.navigator.pop();
      ref.read(booruConfigProvider.notifier).addFromAddBooruConfig(
            newConfig: ref.read(newbooruConfigProvider(config.url)),
            setAsCurrent: widget.setCurrentBooruOnSubmit,
          );
    }
  }
}
