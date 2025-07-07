// Flutter imports:
import 'package:flutter/material.dart';

class FileDetailTile extends StatelessWidget {
  const FileDetailTile({
    required this.title,
    super.key,
    this.valueLabel,
    this.value,
    this.valueTrailing,
  }) : assert(
         valueLabel != null || value != null,
         'valueLabel or value must be provided',
       );

  final String title;
  final String? valueLabel;
  final Widget? value;
  final Widget? valueTrailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      visualDensity: VisualDensity.compact,
      leading: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: LayoutBuilder(
        builder: (context, constrainst) => Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: const BorderRadius.all(Radius.circular(4)),
          ),
          width: constrainst.maxWidth * 0.55,
          child:
              value ??
              (valueLabel != null
                  ? valueTrailing != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildValue(context),
                              const Spacer(),
                              valueTrailing!,
                            ],
                          )
                        : _buildValue(context)
                  : null),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context) {
    return Text(
      valueLabel!,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSecondaryContainer,
        fontSize: 14,
      ),
    );
  }
}
