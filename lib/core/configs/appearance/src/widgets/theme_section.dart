// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../theme/theme_configs.dart';
import '../../../../widgets/widgets.dart';
import '../types/enums.dart';
import 'theme_list_tile.dart';

class ThemeSection extends StatelessWidget {
  const ThemeSection({
    required this.theme,
    required this.onThemeUpdated,
    super.key,
  });

  final ThemeConfigs? theme;
  final void Function(ThemeConfigs? theme) onThemeUpdated;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SwitchListTile(
              title: const Text('Turn on'),
              subtitle: const Text(
                "Override the global theme using this profile's theme",
              ),
              value: theme?.enable ?? false,
              onChanged: (value) => onThemeUpdated(
                theme?.copyWith(enable: value),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            GrayedOut(
              grayedOut: theme?.enable != true,
              child: ThemeListTile(
                updateMethod: ThemeUpdateMethod.saveAndUpdateLater,
                colorSettings: theme?.colors,
                onThemeUpdated: (colors) {
                  onThemeUpdated(
                    ThemeConfigs(
                      colors: colors,
                      enable: true,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
