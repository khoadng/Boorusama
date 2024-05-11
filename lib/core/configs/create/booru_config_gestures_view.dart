// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/option_dropdown_button.dart';
import 'package:boorusama/widgets/warning_container.dart';

class BooruConfigGesturesView extends ConsumerWidget {
  const BooruConfigGesturesView({
    super.key,
    required this.postDetailsGestureActions,
    this.describePostDetailsAction,
  });

  final Set<String?> postDetailsGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postGesturesConfigTyped = ref.watch(postGesturesConfigDataProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const BooruConfigSettingsHeader(label: 'Image viewer'),
          WarningContainer(
            contentBuilder: (_) => const Text(
              'Images only, not applicable to videos.',
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.swipe_down').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.swipeDown,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewSwipeDown(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.double_tap').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.doubleTap,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewDoubleTap(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          //long press
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.long_press').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.longPress,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewLongPress(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),

          const Divider(thickness: 0.5, height: 32),
          const BooruConfigSettingsHeader(label: 'Image preview'),
          // tap
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.tap').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.tap,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewTap(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.long_press').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.longPress,
              onChanged: (value) {
                ref.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewLongPress(value),
                );
              },
              items: postDetailsGestureActions
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value)),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Override the default gestures for this profile, select "None" to keep the original behavior.',
            style: ref.context.textTheme.titleSmall?.copyWith(
              color: ref.context.theme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
