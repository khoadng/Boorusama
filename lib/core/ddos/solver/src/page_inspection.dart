import 'protection_diagnostics.dart';

/// Read once: the event and the solver's decision describe the same document.
Future<PageEvaluation> inspectChallengePage({
  required Future<String> Function() readSource,
  required PageEvaluator evaluate,
  required ProtectionCheck diagnostics,
}) async {
  final String source;
  try {
    source = await readSource();
  } catch (error) {
    diagnostics.record(
      ProtectionOperationFailed(
        ProtectionOperation.pageSource,
        error.runtimeType.toString(),
      ),
    );
    rethrow;
  }
  final result = evaluate(source);
  diagnostics.record(
    PageEvaluated(evaluation: result, length: source.length),
    sensitive: result.accepted ? null : ProtectionPageContents(source),
  );
  return result;
}
