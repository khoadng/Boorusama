// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../posts/rating/rating.dart';
import '../../../../widgets/option_dropdown_button.dart';
import '../../../config/types.dart';

class CreateBooruRatingOptionsTile extends StatelessWidget {
  const CreateBooruRatingOptionsTile({
    required this.config,
    required this.onChanged,
    super.key,
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
          title: Text(context.t.booru.content_filtering_label),
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
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.getFilterRatingTerm()),
                  ),
                )
                .toList(),
          ),
        ),
        if (value == BooruConfigRatingFilter.custom) ...[
          Text(
            'Choose ${singleSelection ? 'a rating' : 'rating(s)'} that you want to exclude from the search.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
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
    required this.config,
    super.key,
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
    final options =
        widget.options ??
        ref
            .watch(booruBuilderProvider(widget.config.auth))
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

                      widget.onChanged?.call(granularRatingFilters?.toSet());
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
