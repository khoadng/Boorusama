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
              labelText: 'IP address'.hc,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final ip = _ipController.text;

              if (ip.isEmpty) {
                showErrorToast(context, 'IP address cannot be empty'.hc);
                return;
              }

              // check for port
              if (!ip.contains(RegExp(r':\d{1,5}'))) {
                showErrorToast(context, 'IP address must contain a port'.hc);
                return;
              }

              final address = ip.startsWith('http://') ? ip : 'http://$ip';

              final uri = Uri.tryParse(address);

              if (uri == null) {
                showErrorToast(context, 'Invalid IP address'.hc);
                return;
              }

              Navigator.of(context).pop(uri);
            },
            child: Text('Import'.hc),
          ),
        ],
      ),
    );
  }
}
