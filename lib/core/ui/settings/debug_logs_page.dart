// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/utils.dart';

class DebugLogsPage extends ConsumerWidget {
  const DebugLogsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(debugLogsProvider);

    // Function to copy logs to clipboard
    void copyLogsToClipboard() {
      final StringBuffer buffer = StringBuffer();
      for (final log in logs) {
        buffer.write('[${log.serviceName}]: ${log.message}\n');
      }
      Clipboard.setData(ClipboardData(text: buffer.toString()));

      showSimpleSnackBar(
        context: context,
        content: const Text('Logs copied to clipboard'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: copyLogsToClipboard,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  log.dateTime.toString(),
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '[${log.serviceName}]: ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      TextSpan(
                        text: log.message,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
