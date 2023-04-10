// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import '../../../../core/application/common.dart';

class TrendingTagState extends Equatable {
  const TrendingTagState({
    required this.tags,
    required this.status,
  });

  factory TrendingTagState.initial() => const TrendingTagState(
        tags: null,
        status: LoadStatus.initial,
      );

  final List<Search>? tags;
  final LoadStatus status;

  TrendingTagState copyWith({
    List<Search>? Function()? tags,
    LoadStatus? status,
  }) =>
      TrendingTagState(
        tags: tags != null ? tags() : this.tags,
        status: status ?? this.status,
      );

  @override
  List<Object?> get props => [tags, status];
}

class TrendingTagCubit extends Cubit<TrendingTagState> {
  TrendingTagCubit(
    this.popularSearchRepository,
    this.excludedTags,
  ) : super(TrendingTagState.initial());
  final PopularSearchRepository popularSearchRepository;
  final Set<String> excludedTags;

  Future<void> getTags() async {
    await tryAsync<List<Search>>(
      action: () => popularSearchRepository.getSearchByDate(DateTime.now()),
      onFailure: (stackTrace, error) =>
          emit(state.copyWith(status: LoadStatus.failure)),
      onUnknownFailure: (stackTrace, error) =>
          emit(state.copyWith(status: LoadStatus.failure)),
      onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
      onSuccess: (searches) async {
        if (searches.isEmpty) {
          searches = await popularSearchRepository.getSearchByDate(
            DateTime.now().subtract(const Duration(days: 1)),
          );
        }

        final filtered =
            searches.where((s) => !excludedTags.contains(s.keyword)).toList();

        emit(state.copyWith(
          tags: () => filtered,
          status: LoadStatus.success,
        ));
      },
    );
  }
}
