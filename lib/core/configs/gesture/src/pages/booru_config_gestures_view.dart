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
          _GestureConfigTile(
            label: context.t.gestures.swipe_down,
            value: postGesturesConfigTyped?.fullview?.swipeDown,
            onChanged: (value) {
              ref.editNotifier.updateGesturesConfigData(
                postGesturesConfigTyped?.withFulviewSwipeDown(value),
              );
            },
            actions: fullviewGestureActions,
            describeAction: describePostDetailsAction,
          ),
          _GestureConfigTile(
            label: context.t.gestures.double_tap,
            value: postGesturesConfigTyped?.fullview?.doubleTap,
            onChanged: (value) {
              ref.editNotifier.updateGesturesConfigData(
                postGesturesConfigTyped?.withFulviewDoubleTap(value),
              );
            },
            actions: fullviewGestureActions,
            describeAction: describePostDetailsAction,
          ),
          _GestureConfigTile(
            label: context.t.gestures.long_press,
            value: postGesturesConfigTyped?.fullview?.longPress,
            onChanged: (value) {
              ref.editNotifier.updateGesturesConfigData(
                postGesturesConfigTyped?.withFulviewLongPress(value),
              );
            },
            actions: fullviewGestureActions,
            describeAction: describePostDetailsAction,
          ),

          const Divider(thickness: 0.5, height: 32),
          BooruConfigSettingsHeader(
            label: context.t.settings.image_grid.image_grid,
          ),
          _GestureConfigTile(
            label: context.t.gestures.tap,
            value: postGesturesConfigTyped?.preview?.tap,
            onChanged: (value) {
              ref.editNotifier.updateGesturesConfigData(
                postGesturesConfigTyped?.withPreviewTap(value),
              );
            },
            actions: previewGestureActions,
            describeAction: describePostDetailsAction,
          ),
          _GestureConfigTile(
            label: context.t.gestures.long_press,
            value: postGesturesConfigTyped?.preview?.longPress,
            onChanged: (value) {
              ref.editNotifier.updateGesturesConfigData(
                postGesturesConfigTyped?.withPreviewLongPress(value),
              );
            },
            actions: previewGestureActions,
            describeAction: describePostDetailsAction,
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

class _GestureConfigTile extends StatelessWidget {
  const _GestureConfigTile({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.actions,
    this.describeAction,
  });

  final String label;
  final String? value;
  final void Function(String?) onChanged;
  final Set<String?> actions;
  final String Function(String? action)? describeAction;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      title: Text(label),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 160,
        ),
        child: OptionDropDownButton<String?>(
          value: value,
          alignment: AlignmentDirectional.bottomStart,
          onChanged: onChanged,
          items: actions
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(
                    describeAction != null
                        ? describeAction!(value)
                        : describeDefaultGestureAction(value, context),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
