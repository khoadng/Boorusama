// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/configs/create/create.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

class DefaultBooruConfigGesturesView extends ConsumerWidget {
  const DefaultBooruConfigGesturesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return BooruConfigGesturesView(
      postDetailsGestureActions: kDefaultGestureActions,
    );
  }
}

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
    final postGesturesConfigTyped = ref.watch(
        editBooruConfigProvider(ref.watch(editBooruConfigIdProvider))
            .select((value) => value.postGesturesConfigTyped));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BooruConfigSettingsHeader(
              label: 'settings.image_viewer.image_viewer'.tr()),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: const Text('gestures.swipe_down').tr(),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.swipeDown,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
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
                ref.editNotifier.updateGesturesConfigData(
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
                ref.editNotifier.updateGesturesConfigData(
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
                ref.editNotifier.updateGesturesConfigData(
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
                ref.editNotifier.updateGesturesConfigData(
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
              color: ref.context.colorScheme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
