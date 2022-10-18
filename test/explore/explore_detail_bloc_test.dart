// Package imports:
import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/explore/explore_detail_bloc.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/time_scale.dart';

void main() {
  group('[explore detail test]', () {
    blocTest<ExploreDetailBloc, ExploreDetailState>(
      'time scale changed',
      seed: () => ExploreDetailState(scale: TimeScale.day, date: DateTime(1)),
      build: () => ExploreDetailBloc(),
      act: (bloc) =>
          bloc.add(const ExploreDetailTimeScaleChanged(TimeScale.month)),
      expect: () => [
        ExploreDetailState.initial()
            .copyWith(scale: TimeScale.month, date: DateTime(1)),
      ],
    );

    blocTest<ExploreDetailBloc, ExploreDetailState>(
      'date changed',
      seed: () => ExploreDetailState(scale: TimeScale.day, date: DateTime(1)),
      build: () => ExploreDetailBloc(),
      act: (bloc) => bloc.add(ExploreDetailDateChanged(DateTime(1, 2))),
      expect: () => [
        ExploreDetailState.initial()
            .copyWith(scale: TimeScale.day, date: DateTime(1, 2)),
      ],
    );
  });
}
