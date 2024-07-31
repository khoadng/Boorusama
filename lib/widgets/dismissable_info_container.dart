// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/foundation/theme.dart';

class DismissableInfoContainer extends ConsumerStatefulWidget {
  const DismissableInfoContainer({
    super.key,
    required this.content,
    this.forceShow = false,
    this.mainColor,
    this.actions = const [],
    this.padding,
  });

  final String content;
  final bool forceShow;
  final Color? mainColor;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<DismissableInfoContainer> createState() =>
      _DismissableInfoContainerState();
}

class _DismissableInfoContainerState
    extends ConsumerState<DismissableInfoContainer> {
  var _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.generateChipColors(
      widget.mainColor ?? Colors.grey,
      ref.watch(settingsProvider),
    );

    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        Container(
          margin: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(4)),
            color: colors?.backgroundColor,
            border: colors != null
                ? Border.all(
                    color: colors.borderColor,
                    width: 1,
                  )
                : null,
          ),
          width: MediaQuery.sizeOf(context).width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Html(
                      style: {
                        'body': Style(
                          color: colors?.foregroundColor,
                        ),
                      },
                      data: widget.content,
                    ),
                  ),
                  Container(
                    width: 20,
                  ),
                ],
              ),
              Container(
                padding: widget.actions.isNotEmpty
                    ? const EdgeInsets.only(
                        left: 4,
                        bottom: 8,
                      )
                    : null,
                child: OverflowBar(
                  children: widget.actions,
                ),
              ),
            ],
          ),
        ),
        if (!widget.forceShow)
          Positioned(
              top: 8,
              right: 12,
              child: IconButton(
                icon: Icon(
                  Symbols.close,
                  color: context.colorScheme.onError,
                ),
                onPressed: () {
                  setState(() {
                    _isDismissed = true;
                  });
                },
              )),
      ],
    );
  }
}
