import 'package:equatable/equatable.dart';

class LogCaptureOptions extends Equatable {
  const LogCaptureOptions({required this.includeSensitiveDetails});

  static const defaults = LogCaptureOptions(includeSensitiveDetails: false);

  final bool includeSensitiveDetails;

  LogCaptureOptions copyWith({bool? includeSensitiveDetails}) =>
      LogCaptureOptions(
        includeSensitiveDetails:
            includeSensitiveDetails ?? this.includeSensitiveDetails,
      );

  @override
  List<Object?> get props => [includeSensitiveDetails];
}
