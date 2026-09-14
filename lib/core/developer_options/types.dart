// Package imports:
import 'package:equatable/equatable.dart';

class DeveloperOptions extends Equatable {
  const DeveloperOptions({
    required this.automaticMediaLoadingEnabled,
  });

  static const defaults = DeveloperOptions(
    automaticMediaLoadingEnabled: true,
  );

  final bool automaticMediaLoadingEnabled;

  DeveloperOptions copyWith({
    bool? automaticMediaLoadingEnabled,
  }) => DeveloperOptions(
    automaticMediaLoadingEnabled:
        automaticMediaLoadingEnabled ?? this.automaticMediaLoadingEnabled,
  );

  @override
  List<Object?> get props => [automaticMediaLoadingEnabled];
}
