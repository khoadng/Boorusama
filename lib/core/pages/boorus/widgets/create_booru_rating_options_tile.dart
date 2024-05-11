// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

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
