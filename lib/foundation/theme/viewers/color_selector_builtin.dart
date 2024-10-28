// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'widgets.dart';

class BuiltInColorSelector extends StatelessWidget {
  const BuiltInColorSelector({
    super.key,
    required this.onSchemeChanged,
    required this.currentScheme,
  });

  final void Function(ColorSettings? color) onSchemeChanged;
  final ColorSettings? currentScheme;

  @override
  Widget build(BuildContext context) {
    final colorScheme = getSchemeFromPredefined(currentScheme?.name) ??
        getSchemeFromPredefined(preDefinedColorSettings.first.name);

    if (colorScheme == null) {
      return Center(
        child: Text('Error: Color scheme not found'),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Column(
        children: [
          Wrap(
            runSpacing: 8,
            children: [
              ...preDefinedColorSettings.map((e) {
                final selected = e.name == currentScheme?.name;
                final cs = getSchemeFromPredefined(e.name);

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: PreviewColorContainer(
                    primary: cs?.primary ?? Colors.transparent,
                    onSurface: cs?.onSurface ?? colorScheme.onSurface,
                    onTap: () {
                      onSchemeChanged(e);
                    },
                    selected: selected,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
