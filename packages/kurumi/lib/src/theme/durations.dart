// Flutter imports:
import 'package:material_ui/material_ui.dart';

/// Shared motion and transient-feedback timings used by the app.
///
/// These values are kept unchanged during the migration so existing
/// interactions retain their current pacing.
abstract class KurumiDurations {
  static const Duration bottomSheet = Durations.medium2;

  static const extraLongToast = Duration(seconds: 6);
  static const longToast = Duration(seconds: 3);
  static const shortToast = Duration(seconds: 1);
}
