// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../foundation/platform.dart';

class OptionTagsArenaController extends ChangeNotifier {
  final ValueNotifier<bool> editMode = ValueNotifier(false);

  void toggleEditMode() {
    editMode.value = !editMode.value;
    notifyListeners();
  }
}

class OptionTagsArena extends ConsumerStatefulWidget {
  const OptionTagsArena({
    required this.title,
    required this.children,
    super.key,
    this.titleTrailing,
    this.editable = true,
    this.controller,
  });

  final String title;
  final Widget? titleTrailing;
  final List<Widget> children;
  final bool editable;
  final OptionTagsArenaController? controller;

  @override
  ConsumerState<OptionTagsArena> createState() => _OptionTagsArenaState();
}

class _OptionTagsArenaState extends ConsumerState<OptionTagsArena> {
  late final controller = widget.controller ?? OptionTagsArenaController();

  @override
  void dispose() {
    if (widget.controller == null) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(),
        Wrap(
          spacing: 4,
          runSpacing: ref.watch(appPlatformProvider).isDesktop ? 4 : 0,
          children: widget.children,
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              widget.title.toUpperCase(),
              style: Kurumi.themeOf(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (widget.editable)
              ValueListenableBuilder(
                valueListenable: controller.editMode,
                builder: (context, editMode, child) {
                  return FilledButton(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      minimumSize: const Size(32, 32),
                      shape: const CircleBorder(),
                      backgroundColor: editMode
                          ? Kurumi.themeOf(context).colorScheme.primary
                          : Kurumi.themeOf(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                    ),
                    onPressed: () => controller.toggleEditMode(),
                    child: Icon(
                      editMode ? Symbols.check : Symbols.edit,
                      size: 16,
                      color: editMode
                          ? Kurumi.themeOf(context).colorScheme.onPrimary
                          : Kurumi.themeOf(
                              context,
                            ).colorScheme.onSurfaceVariant,
                      fill: 1,
                    ),
                  );
                },
              ),
          ],
        ),
        widget.titleTrailing ?? const SizedBox.shrink(),
      ],
    );
  }
}
