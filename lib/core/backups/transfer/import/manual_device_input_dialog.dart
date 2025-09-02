// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

// Project imports:
import '../../../../foundation/toast.dart';
import '../../../widgets/widgets.dart';

class ManualDeviceInputDialog extends StatefulWidget {
  const ManualDeviceInputDialog({
    super.key,
  });

  @override
  State<ManualDeviceInputDialog> createState() =>
      _ManualDeviceInputDialogState();
}

class _ManualDeviceInputDialogState extends State<ManualDeviceInputDialog> {
  final _ipController = TextEditingController();

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BooruDialog(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          BooruTextField(
            autofocus: true,
            keyboardType: TextInputType.url,
            controller: _ipController,
            decoration: InputDecoration(
              labelText:
                  context.t.settings.backup_and_restore.receive_data.ip_address,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final ip = _ipController.text;

              if (ip.isEmpty) {
                showErrorToast(
                  context,
                  context
                      .t
                      .settings
                      .backup_and_restore
                      .receive_data
                      .errors
                      .not_empty,
                );
                return;
              }

              // check for port
              if (!ip.contains(RegExp(r':\d{1,5}'))) {
                showErrorToast(
                  context,
                  context
                      .t
                      .settings
                      .backup_and_restore
                      .receive_data
                      .errors
                      .port_required,
                );
                return;
              }

              final address = ip.startsWith('http://') ? ip : 'http://$ip';

              final uri = Uri.tryParse(address);

              if (uri == null) {
                showErrorToast(
                  context,
                  context
                      .t
                      .settings
                      .backup_and_restore
                      .receive_data
                      .errors
                      .invalid,
                );
                return;
              }

              Navigator.of(context).pop(uri);
            },
            child: Text(context.t.settings.backup_and_restore.import),
          ),
        ],
      ),
    );
  }
}
