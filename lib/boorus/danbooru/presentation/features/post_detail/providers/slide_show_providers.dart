// Package imports:
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hooks_riverpod/all.dart';

part 'slide_show_providers.freezed.dart';

@freezed
abstract class SlideShowConfiguration with _$SlideShowConfiguration {
  const factory SlideShowConfiguration({
    @required int interval,
    @required bool skipAnimation,
  }) = _SlideShowConfiguration;
}

final slideShowConfigurationStateProvider =
    StateProvider<SlideShowConfiguration>((ref) {
  return SlideShowConfiguration(interval: 4, skipAnimation: false);
});
