// Package imports:
import 'package:kurumi/material.dart';

abstract interface class CrashReportWriter {
  Future<void> save(BuildContext context, String data);
}
