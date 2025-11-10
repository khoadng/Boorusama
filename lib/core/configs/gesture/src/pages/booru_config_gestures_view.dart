// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../themes/theme/types.dart';
import '../../../../widgets/widgets.dart';
import '../../../config/types.dart';
import '../../../create/providers.dart';
import '../types/actions.dart';
import '../types/post_gesture_config.dart';
import '../widgets/booru_config_settings_header.dart';

class DefaultBooruConfigGesturesView extends ConsumerWidget {
  const DefaultBooruConfigGesturesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const BooruConfigGesturesView(
      previewGestureActions: kDefaultGestureActions,
      fullviewGestureActions: kDefaultFullviewActions,
    );
  }
}

class BooruConfigGesturesView extends ConsumerWidget {
  const BooruConfigGesturesView({
    required this.fullviewGestureActions,
    required this.previewGestureActions,
    super.key,
    this.describePostDetailsAction,
  });

  final Set<String?> fullviewGestureActions;
  final Set<String?> previewGestureActions;
  final String Function(String? action)? describePostDetailsAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postGesturesConfigTyped = ref.watch(
      editBooruConfigProvider(
        ref.watch(editBooruConfigIdProvider),
      ).select((value) => value.postGesturesConfigTyped),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BooruConfigSettingsHeader(
            label: context.t.settings.image_viewer.image_viewer,
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: Text(context.t.gestures.swipe_down),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.swipeDown,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewSwipeDown(value),
                );
              },
              items: fullviewGestureActions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value, context),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: Text(context.t.gestures.double_tap),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.doubleTap,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewDoubleTap(value),
                );
              },
              items: fullviewGestureActions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value, context),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          //long press
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: Text(context.t.gestures.long_press),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.fullview?.longPress,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
                  postGesturesConfigTyped?.withFulviewLongPress(value),
                );
              },
              items: fullviewGestureActions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value, context),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const Divider(thickness: 0.5, height: 32),
          BooruConfigSettingsHeader(
            label: context.t.settings.image_grid.image_grid,
          ),
          // tap
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: Text(context.t.gestures.tap),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.tap,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewTap(value),
                );
              },
              items: previewGestureActions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value, context),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            title: Text(context.t.gestures.long_press),
            trailing: OptionDropDownButton(
              alignment: AlignmentDirectional.centerStart,
              value: postGesturesConfigTyped?.preview?.longPress,
              onChanged: (value) {
                ref.editNotifier.updateGesturesConfigData(
                  postGesturesConfigTyped?.withPreviewLongPress(value),
                );
              },
              items: previewGestureActions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(
                        describePostDetailsAction != null
                            ? describePostDetailsAction!(value)
                            : describeDefaultGestureAction(value, context),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            context.t.booru.gestures.override_notice,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.hintColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
