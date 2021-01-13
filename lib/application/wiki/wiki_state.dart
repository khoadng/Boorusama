part of 'wiki_state_notifier.dart';

@freezed
abstract class WikiState with _$WikiState {
  const factory WikiState.initial() = _Initial;
  const factory WikiState.loading() = _Loading;
  const factory WikiState.fetched({
    @required Wiki wiki,
  }) = _Fetched;
  const factory WikiState.error({
    @required String name,
    @required String message,
  }) = _Error;
}
