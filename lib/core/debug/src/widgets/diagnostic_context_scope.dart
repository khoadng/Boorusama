import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../foundation/networking.dart';
import '../providers/providers.dart';

class DiagnosticContextScope extends ConsumerWidget {
  const DiagnosticContextScope({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(currentConnectivityProvider, (previous, next) {
      next.whenOrNull(
        data: (transports) {
          final value = transports.map((transport) => transport.name).join(',');
          final logger = ref.read(appLoggerProvider);
          logger.updateReportContext({'networkTransports': value});
          logger.info(
            'Connectivity',
            'observed transports=$value vpnRoute=unknown',
          );
        },
        error: (error, stack) {
          final logger = ref.read(appLoggerProvider);
          logger.updateReportContext({'networkTransports': 'unknown'});
          logger.info(
            'Connectivity',
            'observation failed type=${error.runtimeType}',
          );
        },
      );
    });
    return child;
  }
}
