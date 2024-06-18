// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

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
    final customDownloadLocation = ref.watch(customDownloadLocationProvider);
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
      customDownloadLocation: () => customDownloadLocation,
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
    this.isPassword = false,
  });

  final String? hintText;
  final String? labelText;
  final bool isPassword;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiKey = ref.watch(apiKeyProvider);

    return CreateBooruApiKeyField(
      text: apiKey,
      labelText: isPassword ? 'booru.password_label'.tr() : null,
      hintText: hintText ?? 'e.g: o6H5u8QrxC7dN3KvF9D2bM4p',
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
        fontSize: 12,
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
    this.customInstruction,
  });

  final String? instruction;
  final Widget? customInstruction;
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
          if (showInstructionWhen)
            if (customInstruction != null)
              customInstruction!
            else if (instruction != null)
              DefaultBooruInstructionText(
                instruction!,
              )
            else
              const SizedBox.shrink(),
        ],
      ),
    );
  }
}

class CreateBooruConfigGranularRatingOptions extends ConsumerStatefulWidget {
  const CreateBooruConfigGranularRatingOptions({
    super.key,
    required this.config,
    this.initialValues,
    this.onChanged,
    this.singleSelection = false,
    this.options,
  });

  final BooruConfig config;
  final Set<Rating>? initialValues;
  final Set<Rating>? options;
  final void Function(Set<Rating>? value)? onChanged;
  final bool singleSelection;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CreateBooruConfigGranularRatingOptionsState();
}

class _CreateBooruConfigGranularRatingOptionsState
    extends ConsumerState<CreateBooruConfigGranularRatingOptions> {
  late Set<Rating>? granularRatingFilters = widget.initialValues;

  @override
  Widget build(BuildContext context) {
    final options = widget.options ??
        ref
            .watchBooruBuilder(widget.config)
            ?.granularRatingOptionsBuilder
            ?.call();

    if (options == null) {
      return const SizedBox.shrink();
    }

    return Wrap(
      children: [
        ...options.map(
          (e) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
                label: Text(e.toFullString()),
                selected: granularRatingFilters?.contains(e) ?? false,
                onSelected: (value) {
                  setState(
                    () {
                      if (widget.singleSelection) {
                        granularRatingFilters = {e};
                      } else {
                        if (granularRatingFilters == null) {
                          granularRatingFilters = {e};
                        } else {
                          if (value) {
                            granularRatingFilters!.add(e);
                          } else {
                            granularRatingFilters!.remove(e);
                          }
                        }
                      }

                      widget.onChanged?.call(granularRatingFilters);
                    },
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }
}

class CreateBooruRatingOptionsTile extends StatelessWidget {
  const CreateBooruRatingOptionsTile({
    super.key,
    required this.config,
    required this.onChanged,
    this.value,
    this.initialGranularRatingFilters,
    this.options,
    this.onGranularRatingFiltersChanged,
    this.singleSelection = false,
  });

  final BooruConfig config;
  final void Function(BooruConfigRatingFilter? value) onChanged;
  final BooruConfigRatingFilter? value;

  final Set<Rating>? initialGranularRatingFilters;
  final Set<Rating>? options;
  final void Function(Set<Rating>? value)? onGranularRatingFiltersChanged;

  final bool singleSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          title: const Text('booru.content_filtering_label').tr(),
          trailing: OptionDropDownButton(
            alignment: AlignmentDirectional.centerStart,
            value: value ?? BooruConfigRatingFilter.none,
            onChanged: (value) {
              onChanged.call(value);

              if (value != BooruConfigRatingFilter.custom) {
                onGranularRatingFiltersChanged?.call(null);
              }
            },
            items: BooruConfigRatingFilter.values
                .map((value) => DropdownMenuItem(
                      value: value,
                      child: Text(value.getFilterRatingTerm()),
                    ))
                .toList(),
          ),
        ),
        if (value == BooruConfigRatingFilter.custom) ...[
          Text(
            'Choose ${singleSelection ? 'a rating' : 'rating(s)'} that you want to exclude from the search.',
            style: context.textTheme.bodySmall?.copyWith(
              color: context.theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          CreateBooruConfigGranularRatingOptions(
            singleSelection: singleSelection,
            config: config,
            initialValues: initialGranularRatingFilters,
            options: options,
            onChanged: (value) => onGranularRatingFiltersChanged?.call(value),
          ),
        ],
      ],
    );
  }
}
