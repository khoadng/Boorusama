part of 'most_viewed_bloc.dart';

@freezed
abstract class MostViewedEvent with _$MostViewedEvent {
  const factory MostViewedEvent.started() = _Started;
  const factory MostViewedEvent.refreshed() = _Refreshed;
  const factory MostViewedEvent.timeChanged({
    @required DateTime date,
  }) = _TimeChanged;
  const factory MostViewedEvent.timeForwarded() = _TimeForwarded;
  const factory MostViewedEvent.timeBackwarded() = _TimeBackwarded;
}
