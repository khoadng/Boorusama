// Flutter imports:
import 'package:flutter/widgets.dart';

abstract interface class ErrorReporter {
  void recordError(dynamic error, dynamic stackTrace);
  void recordFlutterFatalError(FlutterErrorDetails details);
  bool get isRemoteErrorReportingSupported;
}

class NoErrorReporter implements ErrorReporter {
  @override
  bool get isRemoteErrorReportingSupported => false;

  @override
  void recordError(error, stackTrace) {}

  @override
  void recordFlutterFatalError(FlutterErrorDetails details) {}
}
