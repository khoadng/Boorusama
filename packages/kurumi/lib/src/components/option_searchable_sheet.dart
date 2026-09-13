import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:material_ui/material_ui.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../foundation/platform.dart';

class KurumiOptionSearchableSheet<T extends Object> extends StatefulWidget {
  const KurumiOptionSearchableSheet({
    required this.items,
    required this.onFilter,
    required this.itemBuilder,
    required this.searchHint,
    super.key,
    this.areItemsTheSame,
    this.title,
    this.scrollController,
  });

  final String? title;
  final String searchHint;
  final List<T> items;
  final List<T> Function(String query) onFilter;
  final Widget Function(BuildContext context, T option) itemBuilder;
  final bool Function(T oldItem, T newItem)? areItemsTheSame;
  final ScrollController? scrollController;

  @override
  State<KurumiOptionSearchableSheet<T>> createState() =>
      _KurumiOptionSearchableSheetState<T>();
}

class _KurumiOptionSearchableSheetState<T extends Object>
    extends State<KurumiOptionSearchableSheet<T>> {
  late var items = widget.items;
  late final scrollController = widget.scrollController ?? ScrollController();

  @override
  void dispose() {
    super.dispose();
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.title != null) ...[
              const SizedBox(height: 24),
              Semantics(
                header: true,
                child: Text(
                  widget.title!,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            TextField(
              onChanged: (value) => setState(() {
                items = widget.onFilter(value);
              }),
              decoration: InputDecoration(
                hintText: widget.searchHint,
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ImplicitlyAnimatedList<T>(
                      items: items,
                      itemBuilder: (context, animation, item, i) =>
                          widget.itemBuilder(context, item),
                      areItemsTheSame:
                          widget.areItemsTheSame ??
                          (oldItem, newItem) => oldItem == newItem,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KurumiOptionSingleSearchableField<T extends Object>
    extends StatelessWidget {
  const KurumiOptionSingleSearchableField({
    required this.value,
    required this.optionValueBuilder,
    required this.onTap,
    super.key,
    this.backgroundColor,
    this.semanticLabel,
  });

  final T value;
  final String Function(T option) optionValueBuilder;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final label = optionValueBuilder(value);

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: kurumiIsDesktopPlatform() ? 4 : 8,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                const FaIcon(
                  FontAwesomeIcons.caretDown,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
