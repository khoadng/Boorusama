import 'package:equatable/equatable.dart';

class LogOptions extends Equatable {
  const LogOptions({required this.redactSensitiveDetails});

  static const defaults = LogOptions(redactSensitiveDetails: false);

  final bool redactSensitiveDetails;

  LogOptions copyWith({bool? redactSensitiveDetails}) => LogOptions(
    redactSensitiveDetails:
        redactSensitiveDetails ?? this.redactSensitiveDetails,
  );

  @override
  List<Object?> get props => [redactSensitiveDetails];
}
