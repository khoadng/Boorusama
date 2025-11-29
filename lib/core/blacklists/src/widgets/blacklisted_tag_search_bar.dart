// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../search/search/widgets.dart';

class BlacklistedTagSearchBar extends StatefulWidget {
  const BlacklistedTagSearchBar({
    required this.controller,
    required this.onSearch,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSearch;

  @override
  State<BlacklistedTagSearchBar> createState() =>
      _BlacklistedTagSearchBarState();
}

class _BlacklistedTagSearchBarState extends State<BlacklistedTagSearchBar> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 12,
            ),
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: ValueListenableBuilder(
              valueListenable: widget.controller,
              builder: (context, controller, child) => BooruSearchBar(
                focus: _focusNode,
                controller: widget.controller,
                leading: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Symbols.search),
                ),
                trailing: controller.text.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Symbols.clear),
                          onTap: () {
                            widget.controller.clear();
                            widget.onSearch();
                          },
                        ),
                      )
                    : const SizedBox.shrink(),
                onChanged: (value) {
                  widget.onSearch();
                },
                onSubmitted: (value) {
                  widget.onSearch();
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
