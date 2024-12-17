// Dart imports:
import 'dart:convert';

// Project imports:
import '../platform.dart';

String prettyPrintJson(dynamic json) {
  if (json == null) return '';

  if (json is Map<String, dynamic>) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }
  final jsonStr = json.toString();

  final jsonObj = json.decode(jsonStr);
  return const JsonEncoder.withIndent('  ').convert(jsonObj);
}

String wrapIntoJsonToCodeBlock(String json) {
  return '```json\n$json\n```';
}

String wrapIntoCodeBlock(String code) {
  return '```\n$code\n```';
}

extension StackTraceX on StackTrace {
  String prettyPrinted({int? maxFrames}) {
    Iterable<String> lines = toString().trimRight().split('\n');
    if (isWeb() && lines.isNotEmpty) {
      lines = lines.skipWhile((line) {
        return line.contains('StackTrace.current') ||
            line.contains('dart-sdk/lib/_internal') ||
            line.contains('dart:sdk_internal');
      });
    }
    if (maxFrames != null) {
      lines = lines.take(maxFrames);
    }

    return lines.join('\n');
  }
}
