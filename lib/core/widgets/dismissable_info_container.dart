// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/html.dart';
import '../themes/colors/providers.dart';

class DismissableInfoContainer extends StatefulWidget {
  const DismissableInfoContainer({
    required this.content,
    super.key,
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
  State<DismissableInfoContainer> createState() =>
      _DismissableInfoContainerState();
}

class _DismissableInfoContainerState extends State<DismissableInfoContainer> {
  var _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final small = constraints.maxWidth < 700;

        final content = Container(
          constraints: small
              ? null
              : const BoxConstraints(
                  maxWidth: 700,
                ),
          child: Stack(
            children: [
              _buildContent(),
              if (!widget.forceShow) _buildCloseButton(),
            ],
          ),
        );

        return small
            ? content
            : Row(
                children: [
                  content,
                ],
              );
      },
    );
  }

  Widget _buildContent() {
    return Consumer(
      builder: (_, ref, _) {
        final colors = ref
            .watch(booruChipColorsProvider)
            .fromColor(widget.mainColor ?? Colors.grey);

        return Container(
          margin:
              widget.padding ??
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
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: AppHtml(
                        style: {
                          'body': Style(
                            color: colors?.foregroundColor,
                          ),
                        },
                        data: widget.content,
                      ),
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
        );
      },
    );
  }

  Widget _buildCloseButton() {
    return Positioned(
      top: 8,
      right: 12,
      child: IconButton(
        icon: Icon(
          Symbols.close,
          color: Theme.of(context).colorScheme.onError,
        ),
        onPressed: () {
          setState(() {
            _isDismissed = true;
          });
        },
      ),
    );
  }
}
