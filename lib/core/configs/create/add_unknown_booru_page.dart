// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:url_launcher/url_launcher_string.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class AddUnknownBooruPage extends ConsumerWidget {
  const AddUnknownBooruPage({
    super.key,
    required this.url,
    this.setCurrentBooruOnSubmit = false,
    this.backgroundColor,
  });

  final String url;
  final bool setCurrentBooruOnSubmit;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(booruEngineProvider);

    return ProviderScope(
      overrides: [
        initialBooruConfigProvider.overrideWithValue(
          BooruConfig.defaultConfig(
            booruType: BooruType.unknown,
            url: url,
            customDownloadFileNameFormat: null,
          ),
        ),
      ],
      child: Material(
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
                      style: context.textTheme.headlineSmall!
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
                            style: context.textTheme.titleMedium,
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
                onPressed: context.navigator.pop,
                icon: const Icon(Symbols.close),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final _targetConfigToValidateProvider =
    StateProvider.autoDispose<BooruConfig?>((ref) {
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
    final data = ref.watch(booruConfigDataProvider);
    final config = ref.watch(initialBooruConfigProvider);
    final auth = ref.watch(authConfigDataProvider);
    final configName = ref.watch(configNameProvider);
    final url = ref.watch(_siteUrlProvider(config));
    final engine = ref.watch(booruEngineProvider);

    final isValid = engine != null &&
        //FIXME: make this check customisable
        (engine == BooruType.hydrus ? auth.apiKey.isNotEmpty : auth.isValid) &&
        configName.isNotEmpty;

    return ref.watch(_validateConfigProvider).when(
          data: (value) => value != null && value
              ? CreateBooruSubmitButton(
                  fill: true,
                  backgroundColor: value ? Colors.green : null,
                  onSubmit: isValid
                      ? () {
                          final finalData = data.copyWith(
                            name: configName,
                            booruIdHint: () => engine.toBooruId(),
                            login: auth.login,
                            apiKey: auth.apiKey,
                            url: url,
                          );

                          ref.read(booruConfigProvider.notifier).addOrUpdate(
                                config: config,
                                newConfig: finalData,
                              );

                          context.navigator.pop();
                        }
                      : null,
                  child: value == true
                      ? const Text('booru.config_booru_confirm').tr()
                      : const Text('Verify'),
                )
              : _buildVerifyButton(isValid, ref, engine, url, auth),
          loading: () => const CreateBooruSubmitButton(
            fill: true,
            backgroundColor: Colors.grey,
            onSubmit: null,
            child: Center(
              child: SizedBox(
                height: 12,
                width: 12,
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          error: (err, _) => _buildVerifyButton(
            isValid,
            ref,
            engine,
            url,
            auth,
            forceRefresh: true,
          ),
        );
  }

  Widget _buildVerifyButton(
    bool isValid,
    WidgetRef ref,
    BooruType? engine,
    String? url,
    AuthConfigData auth, {
    bool forceRefresh = false,
  }) {
    return CreateBooruSubmitButton(
      fill: true,
      onSubmit: isValid && engine != null
          ? () {
              final notifier =
                  ref.read(_targetConfigToValidateProvider.notifier);

              if (forceRefresh) {
                notifier.state = null;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                notifier.state = BooruConfig.defaultConfig(
                  booruType: engine,
                  url: url!,
                  customDownloadFileNameFormat: null,
                ).copyWith(
                  login: auth.login,
                  apiKey: auth.apiKey,
                );
              });
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
    return ref.watch(_validateConfigProvider).maybeWhen(
          orElse: () => const SizedBox(),
          data: (value) => value == false
              ? WarningContainer(
                  title: 'Empty results',
                  contentBuilder: (context) => Text(
                    'The app cannot find any posts with this engine. Please try with another one.',
                    style: TextStyle(
                      color: context.colorScheme.onSurface,
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
                    color: context.colorScheme.onSurface,
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
                style: context.textTheme.titleSmall?.copyWith(
                  color: context.theme.hintColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                children: [
                  const TextSpan(text: 'The app requires the '),
                  TextSpan(
                    text: 'Danbooru Client API',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                      text:
                          ' extension to be installed on the site to function.'),
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
              .where((e) =>
                  e != BooruType.unknown &&
                  e != BooruType.gelbooru &&
                  e != BooruType.animePictures)
              .sorted((a, b) => a.stringify().compareTo(b.stringify()))
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.stringify()),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
