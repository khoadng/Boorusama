part of 'post_curated_bloc.dart';

@freezed
abstract class PostCuratedEvent with _$PostCuratedEvent {
  const factory PostCuratedEvent.requested({
    @required DateTime date,
    @required TimeScale scale,
    @required int page,
  }) = _Requested;
  const factory PostCuratedEvent.moreRequested({
    @required DateTime date,
    @required TimeScale scale,
    @required int page,
  }) = _MoreRequested;
}
