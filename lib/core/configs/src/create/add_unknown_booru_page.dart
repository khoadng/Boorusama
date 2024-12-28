// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path/path.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import '../../../../../core/widgets/widgets.dart';
import '../../../boorus/booru/booru.dart';
import '../../../theme.dart';
import '../booru_config.dart';
import '../data/booru_config_data.dart';
import '../manage/booru_config_provider.dart';
import 'providers.dart';
import 'riverpod_widgets.dart';
import 'types.dart';
import 'widgets.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
  });

  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);
    final theme = Theme.of(context);

    return Material(
      color: backgroundColor,
      child: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.viewPaddingOf(context).top,
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Text(
                    'Select a booru engine to continue',
                    style: theme.textTheme.headlineSmall!
                        .copyWith(fontWeight: FontWeight.w900),
                  ),
                ),
                const Divider(
                  thickness: 2,
                  endIndent: 16,
                  indent: 16,
                ),
                const InvalidBooruWarningContainer(),
                const UnknownConfigBooruSelector(),
                const BooruConfigNameField(),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const BooruUrlField(),
                      if (engine != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (engine != BooruType.hydrus)
                        Text(
                          'Advanced options (optional)',
                          style: theme.textTheme.titleMedium,
                        ),
                      if (engine != BooruType.hydrus)
                        const DefaultBooruInstructionText(
                          '*These options only be used if the site allows it.',
                        ),
                      //FIXME: make this part of the config customisable
                      if (engine != BooruType.hydrus)
                        const SizedBox(height: 16),
                      if (engine != BooruType.hydrus)
                        const DefaultBooruLoginField(),
                      const SizedBox(height: 16),
                      const DefaultBooruApiKeyField(),
                      const SizedBox(height: 16),
                      const UnknownBooruSubmitButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.viewPaddingOf(context).top,
            right: 8,
            child: IconButton(
              onPressed: Navigator.of(context).pop,
              icon: const Icon(Symbols.close),
            ),
          ),
        ],
      ),
    );
  }
}

final _targetConfigToValidateProvider =
    StateProvider.autoDispose<BooruConfigAuth?>((ref) {
  return null;
});

final _validateConfigProvider = FutureProvider.autoDispose<bool?>((ref) async {
  final config = ref.watch(_targetConfigToValidateProvider);
  if (config == null) return null;
  final result = await ref.watch(booruSiteValidatorProvider(config).future);
  return result;
});

class UnknownBooruSubmitButton extends ConsumerWidget {
  const UnknownBooruSubmitButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editId = ref.watch(editBooruConfigIdProvider);
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(
      editBooruConfigProvider(editId)
          .select((value) => AuthConfigData.fromConfig(value)),
    );
    final configName = ref
        .watch(editBooruConfigProvider(editId).select((value) => value.name));
    final url = ref.watch(_siteUrlProvider(config));
    final engine = ref.watch(booruEngineProvider);

    final isValid = engine != null &&
        //FIXME: make this check customisable
        (engine == BooruType.hydrus ? auth.apiKey.isNotEmpty : auth.isValid) &&
        configName.isNotEmpty;

    return ref.watch(_validateConfigProvider).when(
          data: (value) => value != null
              ? BooruConfigDataProvider(
                  builder: (data) => CreateBooruSubmitButton(
                    fill: true,
                    backgroundColor: value ? Colors.green : null,
                    onSubmit: isValid
                        ? () {
                            ref.read(booruConfigProvider.notifier).addOrUpdate(
                                  id: editId,
                                  newConfig: data.copyWith(
                                    booruIdHint: () => engine.toBooruId(),
                                  ),
                                );

                            Navigator.of(context).pop();
                          }
                        : null,
                    child: value
                        ? const Text('booru.config_booru_confirm').tr()
                        : const Text('Verify'),
                  ),
                )
              : _buildVerifyButton(isValid, ref, engine, url, auth),
          loading: () => CreateBooruSubmitButton(
            fill: true,
            backgroundColor: Theme.of(context).colorScheme.hintColor,
            onSubmit: null,
            child: const Center(
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (err, _) =>
              _buildVerifyButton(isValid, ref, engine, url, auth),
        );
  }

  Widget _buildVerifyButton(
    bool isValid,
    WidgetRef ref,
    BooruType? engine,
    String? url,
    AuthConfigData auth,
  ) {
    return CreateBooruSubmitButton(
      fill: true,
      onSubmit: isValid && engine != null
          ? () {
              ref.read(_targetConfigToValidateProvider.notifier).state =
                  BooruConfig.defaultConfig(
                booruType: engine,
                url: url!,
                customDownloadFileNameFormat: null,
              )
                      .copyWith(
                        login: auth.login,
                        apiKey: auth.apiKey,
                      )
                      .auth;
            }
          : null,
      child: const Text('Verify'),
    );
  }
}

class InvalidBooruWarningContainer extends ConsumerWidget {
  const InvalidBooruWarningContainer({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return ref.watch(_validateConfigProvider).maybeWhen(
          orElse: () => const SizedBox(),
          data: (value) => value == false
              ? WarningContainer(
                  title: 'Empty results',
                  contentBuilder: (context) => Text(
                    'The app cannot find any posts with this engine. Please try with another one.',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ),
                  ),
                )
              : const SizedBox(),
          error: (error, st) => Stack(
            children: [
              WarningContainer(
                title: 'Error',
                contentBuilder: (context) => Text(
                  'It seems like the site is not running on the selected engine. Please try with another one.',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
  }
}

final _siteUrlProvider = StateProvider.autoDispose
    .family<String?, BooruConfig>((ref, config) => config.url);

class BooruUrlField extends ConsumerWidget {
  const BooruUrlField({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(initialBooruConfigProvider);
    final engine = ref.watch(booruEngineProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CreateBooruSiteUrlField(
          text: config.url,
          onChanged: (value) =>
              ref.read(_siteUrlProvider(config).notifier).state = value,
        ),
        if (engine == BooruType.shimmie2)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            child: RichText(
              text: TextSpan(
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                children: const [
                  TextSpan(text: 'The app requires the '),
                  TextSpan(
                    text: 'Danbooru Client API',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: ' extension to be installed on the site to function.',
                  ),
                ],
              ),
            ),
          ),
        if (engine == BooruType.shimmie2)
          TextButton(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            onPressed: () {
              launchUrlString(join(config.url, 'ext_doc'));
            },
            child: const Text('View extension documentation'),
          ),
      ],
    );
  }
}

final booruEngineProvider =
    StateProvider.autoDispose<BooruType?>((ref) => null);

class UnknownConfigBooruSelector extends ConsumerWidget {
  const UnknownConfigBooruSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);

    return Padding(
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
              .where(
                (e) =>
                    e != BooruType.unknown &&
                    e != BooruType.gelbooru &&
                    e != BooruType.animePictures,
              )
              .sorted((a, b) => a.stringify().compareTo(b.stringify()))
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.stringify()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
