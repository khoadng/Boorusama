// Flutter imports:
import 'package:flutter/material.dart';

void ignoreOverflowErrors(
  FlutterErrorDetails details, {
  bool forceReport = false,
}) {
  var ifIsOverflowError = false;
  var isUnableToLoadAsset = false;

  // Detect overflow error.
  final exception = details.exception;
  if (exception is FlutterError) {
    ifIsOverflowError = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith('A RenderFlex overflowed by'),
    );
    isUnableToLoadAsset = !exception.diagnostics.any(
      (e) => e.value.toString().startsWith('Unable to load asset'),
    );
  }

  // Ignore if is overflow error.
  if (ifIsOverflowError || isUnableToLoadAsset) {
    debugPrint('Ignored Overflow Error');
  } else {
    FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
  }
}
