import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'chip.dart';

class KurumiDismissibleInfoContainer extends StatefulWidget {
  const KurumiDismissibleInfoContainer({
    required this.content,
    super.key,
    this.forceShow = false,
    this.colors,
    this.actions = const [],
    this.padding,
    this.buttonsPadding,
    this.closeSemanticLabel,
  });

  final Widget content;
  final bool forceShow;
  final KurumiChipColors? colors;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? buttonsPadding;
  final String? closeSemanticLabel;

  @override
  State<KurumiDismissibleInfoContainer> createState() =>
      _KurumiDismissibleInfoContainerState();
}

class _KurumiDismissibleInfoContainerState
    extends State<KurumiDismissibleInfoContainer> {
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
          constraints: BoxConstraints(
            maxWidth: small ? double.infinity : 700,
          ),
          child: Stack(
            children: [
              _buildContent(context),
              if (!widget.forceShow) _buildCloseButton(context),
            ],
          ),
        );

        return Row(children: [Flexible(child: content)]);
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = widget.colors;

    return Container(
      margin:
          widget.padding ??
          const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
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
      width: MediaQuery.widthOf(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: widget.content,
                ),
              ),
              Container(
                width: 20,
              ),
            ],
          ),
          Container(
            padding: widget.actions.isNotEmpty
                ? widget.buttonsPadding ??
                      const EdgeInsets.only(
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
  }

  Widget _buildCloseButton(BuildContext context) {
    void dismiss() {
      setState(() {
        _isDismissed = true;
      });
    }

    return Positioned(
      top: 8,
      right: 12,
      child: Semantics(
        button: true,
        enabled: true,
        label:
            widget.closeSemanticLabel ??
            MaterialLocalizations.of(context).closeButtonTooltip,
        onTap: dismiss,
        excludeSemantics: true,
        child: IconButton(
          icon: Icon(
            Symbols.close,
            color: Theme.of(context).colorScheme.onError,
          ),
          onPressed: dismiss,
        ),
      ),
    );
  }
}
