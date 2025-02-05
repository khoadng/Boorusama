import 'package:equatable/equatable.dart';

abstract class MigrationEvent extends Equatable {
  MigrationEvent({
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final DateTime timestamp;

  @override
  List<Object?> get props => [timestamp];
}

class MigrationStartedEvent extends MigrationEvent {
  MigrationStartedEvent({
    required this.fromVersion,
    required this.targetVersion,
    required this.totalSteps,
    super.timestamp,
  });

  final int fromVersion;
  final int targetVersion;
  final int totalSteps;

  @override
  List<Object?> get props => [
        ...super.props,
        fromVersion,
        targetVersion,
        totalSteps,
      ];
}

class MigrationStepEvent extends MigrationEvent {
  MigrationStepEvent({
    required this.version,
    required this.currentStep,
    required this.totalSteps,
  });

  final int version;
  final int currentStep;
  final int totalSteps;

  @override
  List<Object?> get props => [
        ...super.props,
        version,
        currentStep,
        totalSteps,
      ];
}

class MigrationCompletedEvent extends MigrationEvent {
  MigrationCompletedEvent({
    required this.finalVersion,
    required this.duration,
  });

  final int finalVersion;
  final Duration duration;

  @override
  List<Object?> get props => [
        ...super.props,
        finalVersion,
        duration,
      ];
}

class MigrationFailedEvent extends MigrationEvent {
  MigrationFailedEvent({
    required this.version,
    required this.error,
  });

  final int version;
  final String error;

  @override
  List<Object?> get props => [
        ...super.props,
        version,
        error,
      ];
}

abstract class ProgressListener {
  void onEvent(MigrationEvent event);
}

class MigrationProgressListener implements ProgressListener {
  MigrationProgressListener({
    required Function(MigrationEvent event) onEvent,
  }) : _onEvent = onEvent;

  final void Function(MigrationEvent event) _onEvent;

  @override
  void onEvent(MigrationEvent event) {
    _onEvent(event);
  }
}
