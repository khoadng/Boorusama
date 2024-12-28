// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../foundation/toast.dart';
import '../../widgets/widgets.dart';

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
            keyboardType: TextInputType.url,
            controller: _ipController,
            decoration: const InputDecoration(
              labelText: 'IP address',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final ip = _ipController.text;

              if (ip.isEmpty) {
                showErrorToast(context, 'IP address cannot be empty');
                return;
              }

              if (!ip.contains(RegExp(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'))) {
                showErrorToast(context, 'Invalid IP address');
                return;
              }

              final uri = Uri.tryParse(_ipController.text);

              if (uri == null) {
                showErrorToast(context, 'Invalid IP address');
                return;
              }

              Navigator.of(context).pop(uri);
            },
            child: const Text('Import'),
          ),
        ],
      ),
    );
  }
}
