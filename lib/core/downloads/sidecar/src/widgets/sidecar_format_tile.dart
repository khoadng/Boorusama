// Package imports:
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';
import 'package:kurumi/material.dart';

// Project imports:
import '../../../../settings/data.dart';
import '../../../../settings/widgets.dart';
import '../types/sidecar_format.dart';

class SidecarFormatTile extends StatelessWidget {
  const SidecarFormatTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.allowDefault = false,
  }) : assert(
         allowDefault || value != null,
         'A format is required when the default option is disabled.',
       );

  final SidecarFormat? value;
  final ValueChanged<SidecarFormat?> onChanged;
  final bool allowDefault;

  @override
  Widget build(BuildContext context) {
    final t = context.t.settings.download.sidecar;
    return SettingAnchor(
      id: SettingsIndex.downloads.sidecar.id,
      child: KurumiSettingsTile<String>(
        title: Text(SettingsIndex.downloads.sidecar.title(context)),
        subtitle: Text(t.description),
        selectedOption: value?.name ?? 'default',
        items: [
          if (allowDefault) 'default',
          ...SidecarFormat.values.map((format) => format.name),
        ],
        onChanged: (value) =>
            onChanged(value == 'default' ? null : SidecarFormat.parse(value)),
        optionBuilder: (value) => Text(switch (value) {
          'default' => context.t.generic.kDefault,
          'off' => t.off,
          'tags' => t.tags,
          'json' => t.json,
          _ => throw StateError('Unknown metadata option: $value'),
        }),
      ),
    );
  }
}
