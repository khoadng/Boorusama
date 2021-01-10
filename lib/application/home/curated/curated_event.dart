part of 'curated_bloc.dart';

@freezed
abstract class CuratedEvent with _$CuratedEvent {
  const factory CuratedEvent.started() = _Started;
  const factory CuratedEvent.refreshed() = _Refreshed;
  const factory CuratedEvent.loadedMore() = _LoadedMore;
  const factory CuratedEvent.timeChanged({
    @required DateTime date,
  }) = _TimeChanged;
  const factory CuratedEvent.timeScaleChanged({
    @required TimeScale scale,
  }) = _TimeScaleChanged;
  const factory CuratedEvent.timeForwarded() = _TimeForwarded;
  const factory CuratedEvent.timeBackwarded() = _TimeBackwarded;
}
