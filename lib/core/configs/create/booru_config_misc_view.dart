// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';

class BooruConfigMiscView extends ConsumerWidget {
  const BooruConfigMiscView({
    super.key,
    required this.hasRatingFilter,
    required this.postDetailsGestureActions,
    required this.postPreviewQuickActionButtonActions,
    required this.describePostPreviewQuickAction,
    this.describePostDetailsAction,
    this.miscOptions,
    required this.config,
    this.postDetailsResolution,
  });

  final BooruConfig config;
  final bool hasRatingFilter;
  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  final Set<String?> postPreviewQuickActionButtonActions;
  final String Function(String? action)? describePostPreviewQuickAction;

  final List<Widget>? miscOptions;
  final Widget? postDetailsResolution;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text("Thumbnail's button"),
            subtitle: const Text(
              'Change the default button at the right bottom of the thumbnail.',
            ),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: ref.watch(defaultPreviewImageButtonActionProvider),
              onChanged: (value) =>
                  ref.updateDefaultPreviewImageButtonAction(value),
              items: postPreviewQuickActionButtonActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostPreviewQuickAction != null
                            ? describePostPreviewQuickAction!(value)
                            : describeImagePreviewQuickAction(value)),
                      ))
                  .toList(),
            ),
          ),
          if (hasRatingFilter) ...[
            const DefaultBooruRatingOptionsTile(),
          ],
          if (postDetailsResolution != null)
            postDetailsResolution!
          else
            DefaultImageDetailsQualityTile(config: config),
          if (miscOptions != null) ...miscOptions!,
        ],
      ),
    );
  }
}
