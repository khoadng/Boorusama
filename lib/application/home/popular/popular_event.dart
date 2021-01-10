part of 'popular_bloc.dart';

@freezed
abstract class PopularEvent with _$PopularEvent {
  const factory PopularEvent.started() = _Started;
  const factory PopularEvent.refreshed() = _Refreshed;
  const factory PopularEvent.loadedMore() = _LoadedMore;
  const factory PopularEvent.timeChanged({
    @required DateTime date,
  }) = _TimeChanged;
  const factory PopularEvent.timeScaleChanged({
    @required TimeScale scale,
  }) = _TimeScaleChanged;
  const factory PopularEvent.timeForwarded() = _TimeForwarded;
  const factory PopularEvent.timeBackwarded() = _TimeBackwarded;
}
