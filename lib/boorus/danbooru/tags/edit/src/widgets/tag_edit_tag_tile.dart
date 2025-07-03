// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../../../../foundation/display.dart';

class TagEditTagTile extends StatefulWidget {
  const TagEditTagTile({
    required this.onTap,
    required this.onDeleted,
    required this.title,
    super.key,
  });

  final void Function() onTap;
  final void Function() onDeleted;
  final Widget title;

  @override
  State<TagEditTagTile> createState() => _TagEditTagTileState();
}

class _TagEditTagTileState extends State<TagEditTagTile> {
  final hover = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hover.value = true;
      },
      onExit: (_) {
        hover.value = false;
      },
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: widget.title,
              ),
              ValueListenableBuilder(
                valueListenable: hover,
                builder: (_, value, child) =>
                    !kPreferredLayout.isMobile && !value
                        ? const SizedBox(
                            height: 32,
                          )
                        : child!,
                child: IconButton(
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: widget.onDeleted,
                  icon: Icon(
                    Symbols.close,
                    size: kPreferredLayout.isDesktop ? 16 : 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
